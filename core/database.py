"""

ProjectPotato Database Module

Provides a process-safe DatabaseContext for services to access SQLite directly.
Designed to be used strictly as a context manager engine.

"""
import os
import sqlite3
import logging
from contextlib import contextmanager


class DatabaseContext:
	_db_path = os.getenv("PP_DB_PATH", "projectpotato.db")
	_local_connections = {}  # Tracks connections by (PID, read_only)

	@classmethod
	def initialize(cls, db_path=None):
		"""
		Optional initialization to override the default database path.
		"""
		if db_path:
			cls._db_path = db_path

	@classmethod
	def get_connection(cls, read_only=False):
		"""
		Gets a process-safe SQLite connection.
		Creates a new connection if the PID has changed (fork detection) or if one doesn't exist.
		"""
		pid = os.getpid()
		cache_key = (pid, read_only)
		
		# Fork Detection: Each process needs its own SQLite connection instance.
		# If the current PID + mode isn't in our local dictionary, create a fresh connection.
		if cache_key not in cls._local_connections:
			try:
				# Use URI mode to enforce read-only if requested by BotServices
				uri_path = f"file:{os.path.abspath(cls._db_path)}"
				if read_only:
					uri_path += "?mode=ro"
					
				# timeout=15.0 allows connections to wait up to 15s if the DB is temporarily locked by a write
				conn = sqlite3.connect(uri_path, uri=True, timeout=15.0)
				
				# sqlite3.Row provides dict-like access (equivalent to RealDictCursor)
				conn.row_factory = sqlite3.Row  
				
				# Enable Write-Ahead Logging (WAL) on the write connection for better multiprocess concurrency
				if not read_only:
					conn.execute("PRAGMA journal_mode=WAL;")
					conn.execute("PRAGMA synchronous=NORMAL;")
					
				cls._local_connections[cache_key] = conn
				logging.debug(f"[Database] SQLite Connection initialized for PID: {pid} (ReadOnly: {read_only})")
				
			except sqlite3.Error as e:
				logging.error(f"[Database] Connection failed for PID {pid}: {e}")
				raise

		return cls._local_connections[cache_key]

	@classmethod
	@contextmanager
	def cursor(cls, commit=False, read_only=False):
		"""
		Context manager for database operations.
		
		:param commit: If True, commits the transaction upon successful exit.
		:param read_only: If True, opens the DB in read-only mode to prevent lock contention.
		"""
		conn = None
		cur = None
		try:
			conn = cls.get_connection(read_only=read_only)
			cur = conn.cursor()
			
			yield cur
			
			if commit and not read_only:
				conn.commit()
				
		except Exception as e:
			if conn and not read_only:
				conn.rollback()
			logging.error(f"[Database] Query Error in PID {os.getpid()}: {e}")
			raise e
		finally:
			if cur:
				cur.close()
			# We do NOT close the connection here.
			# SQLite connections are lightweight but caching them per-process is faster.

	@classmethod
	def close_all(cls):
		"""Closes all cached connections for the current process (shutdown cleanup)."""
		pid = os.getpid()
		keys_to_remove = [k for k in cls._local_connections if k[0] == pid]
		
		for k in keys_to_remove:
			try:
				cls._local_connections[k].close()
			except Exception as e:
				logging.error(f"[Database] Error closing connection: {e}")
			del cls._local_connections[k]
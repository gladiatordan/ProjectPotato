#stdlib
from ctypes import ARRAY, c_uint32

#mylib
from . import structs


class Context:
	"""
	
	Class which is used to retrieve certain context structs in memory
	
	"""
	def __init__(self, api):
		self.api = api

	
	def _check_initialized(self):
		if not self.api.initialized:
			raise RuntimeError(f"API not initialized!")
		return True



class GameplayContext(Context):
	"""
	
	GameplayContext instance that actively retrieves fresh GameplayContext from game memory on every get()

	 :param api:	GWAPY instance
	
	"""
	def __init__(self, api):
		super().__init__(api)
		self.pmem = self.api.proc_memory

	def get_cxt(self) -> structs.GameplayContext:
		return self.pmem.memory_read(self.api.get_value("GameplayContext"), structs.GameplayContext)


class GameContext(Context):
	"""
	
	GameContext instance that actively retrieves fresh GameContext from game memory on every get()

	 :param api:	GWAPY instance
	
	"""
	def __init__(self, api):
		super().__init__(api)
		self.pmem = self.api.proc_memory

	def get_game_cxt(self) -> structs.GameContext:
		self._check_initialized()
		base_ptr = self.pmem.memory_read(self.pmem.memory_read(self.api.saved_values["BasePtr"])) # derefernce twice to get the actual thing
		base_context_ptr = self.pmem.memory_read(base_ptr)
		if not base_context_ptr:
			raise RuntimeError(f"Could not dereference base_ptr at addr -> {hex(base_ptr)}")
		
		game_context_ptr = self.pmem.memory_read(base_context_ptr + 0x6 * 4)
		if not game_context_ptr:
			raise RuntimeError(f"Could not dereference game_context_ptr at addr -> {hex(game_context_ptr)}")
		return self.pmem.memory_read_struct(game_context_ptr, structs.GameContext)
	
	def get_agent_cxt(self) -> structs.AgentContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().agent, structs.AgentContext)
	
	def get_map_cxt(self) -> structs.MapContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().map, structs.MapContext)
	
	def get_account_cxt(self) -> structs.AccountContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().account, structs.AccountContext)
	
	def get_world_cxt(self) -> structs.WorldContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().world, structs.WorldContext)
	
	def get_gadget_cxt(self) -> structs.GadgetContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().gadget, structs.GadgetContext)

	def get_guild_cxt(self) -> structs.GuildContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().guild, structs.GuildContext)
	
	def get_item_cxt(self) -> structs.ItemContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().items, structs.ItemContext)
	
	def get_party_cxt(self) -> structs.PartyContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().party, structs.PartyContext)
	
	def get_trade_cxt(self) -> structs.TradeContext:
		return self.pmem.memory_read_struct(self.get_game_cxt().trade, structs.TradeContext)


class WorldContext(Context):
	"""
	
	World Context instance that actively retrieves fresh WorldContext from game memory on every get()

	 :param api:	GWAPY instance
	
	"""
	def __init__(self, api):
		super().__init__(api)
		self.game_cxt = GameContext(api)
		self.pmem = self.api.proc_memory
	
	def get_world_cxt(self):
		return self.game_cxt.get_world_cxt()

	def get_merch_item_array(self):
		world = self.get_world_cxt()
		arr = ARRAY(c_uint32, world.merch_items.m_size)
		return self.pmem.memory_read_struct(world.merch_items.m_buffer, arr)
	
	def get_map_agents_array(self):
		return self.pmem.memory_read_gw_array(self.get_world_cxt().map_agents, structs.MapAgent)
	
	def get_party_allies_array(self):
		return self.pmem.memory_read_gw_array(self.get_world_cxt().party_allies, structs.PartyAlly)
	
	def get_party_effects_array(self):
		return self.pmem.memory_read_gw_array(self.get_world_cxt().party_effects, structs.AgentEffects)
	
	def get_quest_log(self):
		return self.pmem.memory_read_gw_array(self.get_world_cxt().quest_log, structs.QuestLog)
	
	def get_player_controlled_character(self):
		return self.pmem.memory_read(self.get_world_cxt().player_controlled_character, structs.PlayerControlledCharacter)
	
	def get_value(self, field: str):
		return getattr(self.get_world_cxt(), field)
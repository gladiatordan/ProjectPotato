from __future__ import annotations

from pathlib import Path

from Qt import QtWidgets, QtCore, QtGui


class TitleBar(QtWidgets.QFrame):
    def __init__(self, parent=None, version: str = "0.0.1"):
        super().__init__(parent)
        self._drag_pos = None
        self._version = version
        self._setup_ui()

    def _setup_ui(self):
        self.setObjectName("title_bar")
        self.setSizePolicy(QtWidgets.QSizePolicy.Policy.Expanding, QtWidgets.QSizePolicy.Policy.Fixed)

        layout = QtWidgets.QHBoxLayout(self)
        layout.setContentsMargins(14, 10, 14, 10)
        layout.setSpacing(12)

        self.left_spacer = QtWidgets.QWidget()
        self.left_spacer.setObjectName("title_bar_left_spacer")
        self.left_spacer.setFixedWidth(92)
        layout.addWidget(self.left_spacer)

        self.center_wrap = QtWidgets.QWidget()
        self.center_wrap.setObjectName("title_center_wrap")
        center_layout = QtWidgets.QHBoxLayout(self.center_wrap)
        center_layout.setContentsMargins(0, 0, 0, 0)
        center_layout.setSpacing(14)

        self.logo_label = QtWidgets.QLabel()
        self.logo_label.setObjectName("title_logo")
        self.logo_label.setAlignment(QtCore.Qt.AlignmentFlag.AlignCenter)
        self.logo_label.setFixedSize(280, 88)
        self.logo_label.setScaledContents(False)
        self._load_logo()

        self.version_label = QtWidgets.QLabel(f"Version {self._version}")
        self.version_label.setObjectName("title_version")
        self.version_label.setAlignment(QtCore.Qt.AlignmentFlag.AlignVCenter | QtCore.Qt.AlignmentFlag.AlignLeft)

        center_layout.addWidget(self.logo_label)
        center_layout.addWidget(self.version_label)
        layout.addWidget(self.center_wrap, 1, QtCore.Qt.AlignmentFlag.AlignCenter)

        self.controls = QtWidgets.QWidget()
        self.controls.setObjectName("title_controls")
        controls_layout = QtWidgets.QHBoxLayout(self.controls)
        controls_layout.setContentsMargins(0, 0, 0, 0)
        controls_layout.setSpacing(8)

        self.btn_minimize = QtWidgets.QPushButton("—")
        self.btn_minimize.setObjectName("btn_title_minimize")
        self.btn_minimize.setFixedSize(40, 32)
        self.btn_close = QtWidgets.QPushButton("✕")
        self.btn_close.setObjectName("btn_title_close")
        self.btn_close.setFixedSize(40, 32)

        controls_layout.addWidget(self.btn_minimize)
        controls_layout.addWidget(self.btn_close)
        layout.addWidget(self.controls, 0, QtCore.Qt.AlignmentFlag.AlignRight)

        self.btn_minimize.clicked.connect(self._handle_minimize)
        self.btn_close.clicked.connect(self._handle_close)

        QtCore.QTimer.singleShot(0, self._sync_spacer_width)

    def _load_logo(self):
        logo_path = Path(__file__).resolve().parent / "assets" / "projectpotato_logo.png"
        if not logo_path.exists():
            self.logo_label.setText("ProjectPotato")
            return

        pixmap = QtGui.QPixmap(str(logo_path))
        if pixmap.isNull():
            self.logo_label.setText("ProjectPotato")
            return

        scaled = pixmap.scaled(
            self.logo_label.size(),
            QtCore.Qt.AspectRatioMode.KeepAspectRatio,
            QtCore.Qt.TransformationMode.SmoothTransformation,
        )
        self.logo_label.setPixmap(scaled)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self._sync_spacer_width()
        if self.logo_label.pixmap() is not None:
            self._load_logo()

    def _sync_spacer_width(self):
        self.left_spacer.setFixedWidth(max(92, self.controls.sizeHint().width()))

    def _window(self):
        return self.window()

    def _handle_minimize(self):
        self._window().showMinimized()

    def _handle_close(self):
        self._window().close()

    def mousePressEvent(self, event):
        if event.button() == QtCore.Qt.MouseButton.LeftButton:
            top_left = self._window().frameGeometry().topLeft()
            self._drag_pos = event.globalPos() - top_left
            event.accept()
            return
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event):
        if self._drag_pos is not None and event.buttons() & QtCore.Qt.MouseButton.LeftButton:
            self._window().move(event.globalPos() - self._drag_pos)
            event.accept()
            return
        super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event):
        self._drag_pos = None
        super().mouseReleaseEvent(event)


class LauncherTab(QtWidgets.QWidget):
    action_requested = QtCore.Signal(dict)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()

    def setup_ui(self):
        main_layout = QtWidgets.QVBoxLayout(self)
        main_layout.setContentsMargins(10, 10, 10, 10)
        main_layout.setSpacing(10)

        self.surface = QtWidgets.QFrame()
        self.surface.setObjectName("launcher_surface")
        surface_layout = QtWidgets.QVBoxLayout(self.surface)
        surface_layout.setContentsMargins(14, 14, 14, 14)
        surface_layout.setSpacing(12)
        main_layout.addWidget(self.surface)

        self.splitter = QtWidgets.QSplitter(QtCore.Qt.Orientation.Vertical)
        self.splitter.setChildrenCollapsible(False)
        surface_layout.addWidget(self.splitter)

        top_widget = QtWidgets.QWidget()
        top_layout = QtWidgets.QVBoxLayout(top_widget)
        top_layout.setContentsMargins(0, 0, 0, 0)
        top_layout.setSpacing(10)

        self.table = QtWidgets.QTableWidget(0, 6)
        self.table.setObjectName("launcher_table")
        self.table.setAlternatingRowColors(True)
        self.table.setSelectionBehavior(QtWidgets.QAbstractItemView.SelectionBehavior.SelectRows)
        self.table.setSelectionMode(QtWidgets.QAbstractItemView.SelectionMode.SingleSelection)
        self.table.setShowGrid(False)
        self.table.setEditTriggers(QtWidgets.QAbstractItemView.EditTrigger.NoEditTriggers)
        self.table.setFocusPolicy(QtCore.Qt.FocusPolicy.NoFocus)
        self.table.verticalHeader().setVisible(False)
        self.table.setHorizontalHeaderLabels([
            "", "Account", "Inject DLLs", "Inject Mods", "Launch", "Update"
        ])
        header = self.table.horizontalHeader()
        header.setStretchLastSection(False)
        header.setSectionResizeMode(0, QtWidgets.QHeaderView.ResizeMode.Fixed)
        header.setSectionResizeMode(1, QtWidgets.QHeaderView.ResizeMode.Stretch)
        for idx in (2, 3, 4, 5):
            header.setSectionResizeMode(idx, QtWidgets.QHeaderView.ResizeMode.ResizeToContents)
        self.table.setColumnWidth(0, 38)
        self.table.itemChanged.connect(self.check_selection_state)
        top_layout.addWidget(self.table)

        btn_layout = QtWidgets.QHBoxLayout()
        btn_layout.setSpacing(10)
        self.btn_launch_sel = QtWidgets.QPushButton("Launch Selected")
        self.btn_launch_sel.setObjectName("btn_launch")
        self.btn_update_sel = QtWidgets.QPushButton("Update Selected")
        self.btn_update_sel.setObjectName("btn_tools")
        self.btn_settings = QtWidgets.QPushButton("Settings")
        self.btn_settings.setObjectName("btn_settings")

        self.btn_launch_sel.setEnabled(False)
        self.btn_update_sel.setEnabled(False)

        self.btn_launch_sel.clicked.connect(lambda: self.request_action("LAUNCH_SELECTED"))
        self.btn_update_sel.clicked.connect(lambda: self.request_action("UPDATE_SELECTED"))
        self.btn_settings.clicked.connect(lambda: self.request_action("OPEN_SETTINGS"))

        btn_layout.addWidget(self.btn_launch_sel)
        btn_layout.addWidget(self.btn_update_sel)
        btn_layout.addStretch()
        btn_layout.addWidget(self.btn_settings)
        top_layout.addLayout(btn_layout)

        self.splitter.addWidget(top_widget)

        self.console_log = QtWidgets.QTextEdit()
        self.console_log.setObjectName("console")
        self.console_log.setReadOnly(True)
        self.console_log.setPlaceholderText("Console output will appear here...")
        self.splitter.addWidget(self.console_log)
        self.splitter.setSizes([540, 220])

        self.add_account_row("Dan So Lo")

    def add_account_row(self, account_name):
        row = self.table.rowCount()
        self.table.insertRow(row)
        self.table.setRowHeight(row, 44)
        self.table.blockSignals(True)

        chk_item = QtWidgets.QTableWidgetItem()
        chk_item.setFlags(QtCore.Qt.ItemFlag.ItemIsUserCheckable | QtCore.Qt.ItemFlag.ItemIsEnabled)
        chk_item.setCheckState(QtCore.Qt.CheckState.Unchecked)
        self.table.setItem(row, 0, chk_item)

        account_item = QtWidgets.QTableWidgetItem(account_name)
        self.table.setItem(row, 1, account_item)
        self.table.setCellWidget(row, 2, self._create_centered_checkbox())
        self.table.setCellWidget(row, 3, self._create_centered_checkbox())

        btn_launch = QtWidgets.QPushButton("Launch")
        btn_launch.setObjectName("btn_primary")
        btn_launch.clicked.connect(lambda: self.request_action("LAUNCH", account_name))
        self.table.setCellWidget(row, 4, btn_launch)

        btn_update = QtWidgets.QPushButton("Update")
        btn_update.setObjectName("btn_tools")
        btn_update.setEnabled(False)
        btn_update.clicked.connect(lambda: self.request_action("UPDATE", account_name))
        self.table.setCellWidget(row, 5, btn_update)

        self.table.blockSignals(False)
        self.check_selection_state()

    def _create_centered_checkbox(self):
        widget = QtWidgets.QWidget()
        widget.setObjectName("table_checkbox_wrap")
        layout = QtWidgets.QHBoxLayout(widget)
        chk = QtWidgets.QCheckBox()
        layout.addWidget(chk)
        layout.setAlignment(QtCore.Qt.AlignmentFlag.AlignCenter)
        layout.setContentsMargins(0, 0, 0, 0)
        return widget

    def check_selection_state(self, item=None):
        any_checked = False
        for row in range(self.table.rowCount()):
            chk_item = self.table.item(row, 0)
            if chk_item and chk_item.checkState() == QtCore.Qt.CheckState.Checked:
                any_checked = True
                break
        self.btn_launch_sel.setEnabled(any_checked)
        self.btn_update_sel.setEnabled(any_checked)

    def request_action(self, action, account=None):
        payload = {"action": action}
        if action in ["LAUNCH_SELECTED", "UPDATE_SELECTED"]:
            selected_accounts = []
            for row in range(self.table.rowCount()):
                chk_item = self.table.item(row, 0)
                if chk_item and chk_item.checkState() == QtCore.Qt.CheckState.Checked:
                    acc_item = self.table.item(row, 1)
                    if acc_item:
                        selected_accounts.append(acc_item.text())
            payload["accounts"] = selected_accounts
        elif account:
            payload["account"] = account
        self.action_requested.emit(payload)


class PlaceholderTab(QtWidgets.QWidget):
    def __init__(self, title: str, body: str, parent=None):
        super().__init__(parent)
        layout = QtWidgets.QVBoxLayout(self)
        layout.setContentsMargins(10, 10, 10, 10)

        panel = QtWidgets.QFrame()
        panel.setObjectName("placeholder_surface")
        panel_layout = QtWidgets.QVBoxLayout(panel)
        panel_layout.setContentsMargins(24, 24, 24, 24)
        panel_layout.setSpacing(10)

        title_label = QtWidgets.QLabel(title)
        title_label.setObjectName("placeholder_title")
        body_label = QtWidgets.QLabel(body)
        body_label.setObjectName("placeholder_body")
        body_label.setWordWrap(True)

        panel_layout.addWidget(title_label)
        panel_layout.addWidget(body_label)
        panel_layout.addStretch()
        layout.addWidget(panel)


class MainWindow(QtWidgets.QMainWindow):
    def __init__(self, version="0.0.1"):
        super().__init__()
        self.version = version
        self.setWindowTitle(f"ProjectPotato (v{version})")
        self.resize(1220, 860)
        self.setMinimumSize(1080, 760)
        self.setWindowFlag(QtCore.Qt.WindowType.FramelessWindowHint, True)
        self.setAttribute(QtCore.Qt.WidgetAttribute.WA_TranslucentBackground, True)

        outer = QtWidgets.QWidget()
        outer_layout = QtWidgets.QVBoxLayout(outer)
        outer_layout.setContentsMargins(18, 18, 18, 18)
        outer_layout.setSpacing(0)
        self.setCentralWidget(outer)

        self.window_shell = QtWidgets.QFrame()
        self.window_shell.setObjectName("window_shell")
        shell_layout = QtWidgets.QVBoxLayout(self.window_shell)
        shell_layout.setContentsMargins(0, 0, 0, 0)
        shell_layout.setSpacing(0)
        outer_layout.addWidget(self.window_shell)

        self.title_bar = TitleBar(self, version=version)
        shell_layout.addWidget(self.title_bar)

        body = QtWidgets.QWidget()
        body_layout = QtWidgets.QVBoxLayout(body)
        body_layout.setContentsMargins(16, 0, 16, 16)
        body_layout.setSpacing(12)
        shell_layout.addWidget(body)

        self.tabs = QtWidgets.QTabWidget()
        self.tabs.setObjectName("main_tabs")
        self.tabs.setTabPosition(QtWidgets.QTabWidget.TabPosition.West)

        self.launcher_tab = LauncherTab()
        self.workers_tab = PlaceholderTab(
            "Workers",
            "Worker controls will live here. The placement is preserved, but the paneling and spacing are cleaned up so the tab reads like the rest of the launcher.",
        )

        self.tabs.addTab(self.launcher_tab, "Launcher")
        self.tabs.addTab(self.workers_tab, "Workers")
        body_layout.addWidget(self.tabs)

    def mousePressEvent(self, event):
        super().mousePressEvent(event)

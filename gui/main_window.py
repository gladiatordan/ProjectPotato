from Qt import QtWidgets, QtCore

class LauncherTab(QtWidgets.QWidget):
    action_requested = QtCore.Signal(dict)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()

    def setup_ui(self):
        layout = QtWidgets.QVBoxLayout(self)
        self.table = QtWidgets.QTableWidget(0, 7)
        self.table.setHorizontalHeaderLabels([
            "", "Account", "Inject DLLs", "Inject Mods", "Settings", "Launch", "Update"
        ])
        self.table.horizontalHeader().setSectionResizeMode(1, QtWidgets.QHeaderView.ResizeMode.Stretch)
        layout.addWidget(self.table)

        # Placeholder row for testing
        self.add_account_row("Dan So Lo")

    def add_account_row(self, account_name):
        row = self.table.rowCount()
        self.table.insertRow(row)

        chk_item = QtWidgets.QTableWidgetItem()
        chk_item.setFlags(QtCore.Qt.ItemFlag.ItemIsUserCheckable | QtCore.Qt.ItemFlag.ItemIsEnabled)
        chk_item.setCheckState(QtCore.Qt.CheckState.Unchecked)
        self.table.setItem(row, 0, chk_item)

        self.table.setItem(row, 1, QtWidgets.QTableWidgetItem(account_name))
        self.table.setCellWidget(row, 2, self._create_centered_checkbox())
        self.table.setCellWidget(row, 3, self._create_centered_checkbox())

        # Emits a signal to open settings (handled later)
        btn_settings = QtWidgets.QPushButton("Settings")
        btn_settings.clicked.connect(lambda: self.request_action("OPEN_SETTINGS", account_name))
        self.table.setCellWidget(row, 4, btn_settings)

        btn_launch = QtWidgets.QPushButton("Launch")
        btn_launch.clicked.connect(lambda: self.request_action("LAUNCH", account_name))
        self.table.setCellWidget(row, 5, btn_launch)

        btn_update = QtWidgets.QPushButton("Update")
        btn_update.setEnabled(False)
        btn_update.clicked.connect(lambda: self.request_action("UPDATE", account_name))
        self.table.setCellWidget(row, 6, btn_update)

    def _create_centered_checkbox(self):
        widget = QtWidgets.QWidget()
        layout = QtWidgets.QHBoxLayout(widget)
        chk = QtWidgets.QCheckBox()
        layout.addWidget(chk)
        layout.setAlignment(QtCore.Qt.AlignmentFlag.AlignCenter)
        layout.setContentsMargins(0, 0, 0, 0)
        return widget

    def request_action(self, action, account):
        self.action_requested.emit({"action": action, "account": account})


class MainWindow(QtWidgets.QMainWindow):
    def __init__(self, version="0.0.1"):
        super().__init__()
        self.setWindowTitle(f"ProjectPotato (v{version})")
        self.resize(1024, 768)

        central = QtWidgets.QWidget()
        self.setCentralWidget(central)
        layout = QtWidgets.QVBoxLayout(central)

        self.tabs = QtWidgets.QTabWidget()
        self.tabs.setTabPosition(QtWidgets.QTabWidget.TabPosition.West)
        
        self.launcher_tab = LauncherTab()
        self.workers_tab = QtWidgets.QWidget() # Placeholder for Workers Tab
        
        self.tabs.addTab(self.launcher_tab, "Launcher")
        self.tabs.addTab(self.workers_tab, "Workers")
        layout.addWidget(self.tabs)
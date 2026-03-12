from Qt import QtWidgets, QtCore

class LauncherTab(QtWidgets.QWidget):
    action_requested = QtCore.Signal(dict)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setup_ui()

    def setup_ui(self):
        # Main layout for the tab
        main_layout = QtWidgets.QVBoxLayout(self)

        # 1. Use a QSplitter for dynamic vertical sizing between the top and bottom sections
        self.splitter = QtWidgets.QSplitter(QtCore.Qt.Orientation.Vertical)
        main_layout.addWidget(self.splitter)

        # --- TOP SECTION (Table + Button Bar) ---
        top_widget = QtWidgets.QWidget()
        top_layout = QtWidgets.QVBoxLayout(top_widget)
        top_layout.setContentsMargins(0, 0, 0, 0)

        # Launcher Table (Section 1)
        self.table = QtWidgets.QTableWidget(0, 6)
        self.table.setHorizontalHeaderLabels([
            "", "Account", "Inject DLLs", "Inject Mods", "Launch", "Update"
        ])
        # Stretch the Account column dynamically
        self.table.horizontalHeader().setSectionResizeMode(1, QtWidgets.QHeaderView.ResizeMode.Stretch)
        # Hook up the itemChanged signal to track checkbox states
        self.table.itemChanged.connect(self.check_selection_state)
        top_layout.addWidget(self.table)

        # Button Bar (Section 2)
        btn_layout = QtWidgets.QHBoxLayout()
        self.btn_launch_sel = QtWidgets.QPushButton("Launch Selected")
        self.btn_update_sel = QtWidgets.QPushButton("Update Selected")
        self.btn_settings = QtWidgets.QPushButton("Settings")

        # Disabled by default
        self.btn_launch_sel.setEnabled(False)
        self.btn_update_sel.setEnabled(False)

        # Connect buttons
        self.btn_launch_sel.clicked.connect(lambda: self.request_action("LAUNCH_SELECTED"))
        self.btn_update_sel.clicked.connect(lambda: self.request_action("UPDATE_SELECTED"))
        self.btn_settings.clicked.connect(lambda: self.request_action("OPEN_SETTINGS"))

        btn_layout.addWidget(self.btn_launch_sel)
        btn_layout.addWidget(self.btn_update_sel)
        btn_layout.addStretch() # Pushes the settings button to the far right
        btn_layout.addWidget(self.btn_settings)
        top_layout.addLayout(btn_layout)

        # Add the constructed top widget to the splitter
        self.splitter.addWidget(top_widget)

        # --- BOTTOM SECTION (Console Log) ---
        # Console Log (Section 3)
        self.console_log = QtWidgets.QTextEdit()
        self.console_log.setReadOnly(True)
        self.console_log.setPlaceholderText("Console output will appear here...")
        
        # Add the console to the splitter
        self.splitter.addWidget(self.console_log)

        # Set default proportions for the splitter (e.g., 70% table/buttons, 30% console)
        self.splitter.setSizes([700, 300])

        # Placeholder row for testing
        self.add_account_row("Dan So Lo")

    def add_account_row(self, account_name):
        row = self.table.rowCount()
        self.table.insertRow(row)

        # Temporarily block signals so setting up checkboxes doesn't trigger our check_selection_state early
        self.table.blockSignals(True)

        chk_item = QtWidgets.QTableWidgetItem()
        chk_item.setFlags(QtCore.Qt.ItemFlag.ItemIsUserCheckable | QtCore.Qt.ItemFlag.ItemIsEnabled)
        chk_item.setCheckState(QtCore.Qt.CheckState.Unchecked)
        self.table.setItem(row, 0, chk_item)

        self.table.setItem(row, 1, QtWidgets.QTableWidgetItem(account_name))
        self.table.setCellWidget(row, 2, self._create_centered_checkbox())
        self.table.setCellWidget(row, 3, self._create_centered_checkbox())

        btn_launch = QtWidgets.QPushButton("Launch")
        btn_launch.clicked.connect(lambda: self.request_action("LAUNCH", account_name))
        self.table.setCellWidget(row, 4, btn_launch)

        btn_update = QtWidgets.QPushButton("Update")
        btn_update.setEnabled(False)
        btn_update.clicked.connect(lambda: self.request_action("UPDATE", account_name))
        self.table.setCellWidget(row, 5, btn_update)

        # Unblock signals and manually check state just in case
        self.table.blockSignals(False)
        self.check_selection_state()

    def _create_centered_checkbox(self):
        widget = QtWidgets.QWidget()
        layout = QtWidgets.QHBoxLayout(widget)
        chk = QtWidgets.QCheckBox()
        layout.addWidget(chk)
        layout.setAlignment(QtCore.Qt.AlignmentFlag.AlignCenter)
        layout.setContentsMargins(0, 0, 0, 0)
        return widget

    def check_selection_state(self, item=None):
        """Scans the table to see if any row is checked and toggles button states."""
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
        
        # If the action is for multiple selected items, gather them up
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
            # If it's an inline button for a specific row
            payload["account"] = account
            
        self.action_requested.emit(payload)


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
        self.workers_tab = QtWidgets.QWidget() # Placeholder
        
        self.tabs.addTab(self.launcher_tab, "Launcher")
        self.tabs.addTab(self.workers_tab, "Workers")
        layout.addWidget(self.tabs)
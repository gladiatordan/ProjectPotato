# Phase 1 UI Plan

## Locked Window Shell

The Phase 1 GUI is a Qt6 Widgets frameless shell with:

- a custom header banner for ProjectPotato
- integrated minimize, maximize/restore, and close buttons
- draggable header behavior
- native-resize hit testing on Windows
- a dark metallic / gothic launcher presentation

## Main Layout

`MainWindow`

- `PotatoHeader`
- body split
  - `PotatoSidebar`
    - `Launcher`
    - `Workers`
    - `Settings`
  - stacked content
    - `LauncherPage`
    - `WorkersPage`
    - `SettingsPage`

## Launcher Page

The launcher page is intentionally locked to this shape:

- Accounts panel
- Account table
- Context action row
- Log console

### Account Table Columns

1. Selected checkbox
2. Account
3. Character dropdown
4. Inject DLLs checkbox
5. Inject Mods checkbox
6. Launch action
7. Update action

Explicitly excluded from this Phase 1 table:

- settings column
- add-account button in the header
- extra utility/header button

### Context Action Row

- `Launch Selected`
- `Check for Updates`
- `Update All`

These actions route into stub services and produce logs through `LogService`.

## Workers Page

The workers page remains a placeholder surface. It shows that the internal service harness is alive without introducing the real Worker protocol or IPC design yet.

## Settings Page

Settings starts as a diagnostics/developer surface first:

- `Emit Test Log Burst`
- `Ping Services`
- `Clear GUI Log`
- `Open Logs Folder`
- simple service status display

Actual persistent application settings are intentionally deferred.

## Service/UI Relationship

- Widgets never own service threads directly.
- `MainController` routes actions into `ServiceManager`.
- `LogService` is the main bridge between runtime behavior and the launcher log console.
- GUI updates from background work are delivered through Qt-safe queued calls.

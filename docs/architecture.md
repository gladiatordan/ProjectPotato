# ProjectPotato Phase 1 Architecture

## Goals

Phase 1 establishes a debuggable Windows-focused Qt6 Widgets shell for ProjectPotato. The application is portable, creates its runtime folders relative to the executable directory, and starts a small internal service harness that can be exercised from the GUI.

## High-Level Structure

`src/app`

- Application bootstrap.
- Creates the runtime folder tree before services start.
- Loads the shared stylesheet and launches the main window/controller pair.

`src/core`

- `AppPaths`: resolves and creates runtime folders relative to the executable directory.
- `BuildInfo`: app identity/version constants.
- `ServiceCommand`: host-internal command routing types used only during Phase 1.

`src/services`

- `IService`: common start/stop/command interface.
- `ThreadSafeQueue`: low-overhead queue used by service threads.
- `LogService`: the first fully implemented service. It accepts thread-safe log submissions, timestamps them, rotates the file log, and forwards lines to the GUI via a safe callback bridge.
- `LauncherService`, `GameService`, `UpdateService`, `WorkerService`: stub services built on `std::jthread`, `std::stop_token`, and command queues. They emit heartbeats and log placeholder command handling.
- `ServiceManager`: owns services, starts/stops them in order, and exposes simple routing helpers to the controller.

`src/ui`

- `MainWindow`: frameless custom shell with a header banner, sidebar, and stacked pages.
- `MainController`: keeps UI handlers thin by routing actions into the service manager and publishing service/log updates back to the GUI.
- `pages`: launcher, workers, and settings surfaces.
- `models` and `delegates`: `QAbstractTableModel` plus delegates for the account table.
- `widgets`: reusable shell widgets such as the custom header, sidebar, window controls, and log console.

## Runtime Layout

The app creates these folders relative to the executable or working run directory:

- `assets/`
- `configs/`
- `configs/PotatoBox/`
- `crashes/`
- `crashes/gw/`
- `logs/`

`LogService` writes the primary log to `logs/ProjectPotato.log`.

## Logging Design

- Any thread can submit log messages through `LogService::submit`.
- Log lines include timestamp, level, source/service name, and message text.
- Rotation is simple and predictable: the active file is `ProjectPotato.log`, then archived files are `ProjectPotato_1.log` through `ProjectPotato_9.log` for a ten-file total cap including the active log.
- GUI forwarding is done indirectly through a Qt queued invocation set by `MainController`, so background service threads never touch widgets directly.

## Service Harness

Each non-UI service:

- owns its own `std::jthread`
- waits on a condition-variable-backed queue instead of busy looping
- supports `Ping`, `EmitTestLog`, and `Shutdown`
- supports placeholder service-specific commands:
  - `LaunchSelected` for `LauncherService`
  - `CheckUpdates` and `UpdateAll` for `UpdateService`
- emits start/stop/heartbeat logs

These commands are intentionally host-internal only. They are not the future Worker or PotatoService protocol.

## Explicit Phase 1 Exclusions

Phase 1 does **not** implement:

- real DLL injection
- Texmod/mod injection
- Guild Wars launching or process control
- real Worker protocol or IPC
- Discord integration
- OpenSSL credential encryption
- crash dump capture
- real updater networking or patch logic
- installer/registry requirements

## Legacy Repository Content

The repository already contained experimental code under `projects/` and `Dependencies/`. That content is preserved on disk. The default top-level build now focuses on the new Phase 1 app, while legacy experimental targets can still be opted into with the `PROJECTPOTATO_ENABLE_LEGACY_EXPERIMENTS` CMake option.

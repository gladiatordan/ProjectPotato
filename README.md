# ProjectPotato

ProjectPotato Phase 1 is a Windows-focused portable C++23 / Qt6 Widgets application built with CMake and vcpkg manifest mode. This phase delivers the app shell, GUI foundation, logging, and stub service harness only.

## Current Scope

- frameless Qt6 Widgets launcher shell
- launcher/workers/settings page foundation
- runtime folder creation relative to the executable directory
- rotating file logging to `logs/ProjectPotato.log`
- internal service manager with launcher/game/update/worker stub threads
- diagnostics controls for pings, test logs, GUI log clearing, and opening the log folder

Not included yet:

- real Guild Wars launching or process control
- real DLL or mod injection
- updater networking/patching
- worker IPC/protocol
- credential handling or encryption

## Requirements

- Windows
- MSVC toolchain
- CMake 3.25+
- vcpkg with manifest mode enabled

## Configure

Set `VCPKG_ROOT` to your vcpkg checkout, then configure the project:

```powershell
cmake -S . -B out/build `
  -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
```

## Build

```powershell
cmake --build out/build --config Debug
```

The executable is produced in `out/build/bin/`.

## Run

Launch `ProjectPotato.exe` from the build output directory. On first run the app creates:

- `assets/`
- `configs/PotatoBox/`
- `crashes/gw/`
- `logs/`

All of those folders live relative to the executable directory so the app stays portable.

## Regenerate Mockup Assets

The first-pass Qt art assets are extracted from the flattened mockup at `resources/source/projectpotato_mockup.png`.

Run the extractor with:

```powershell
& 'C:\Program Files\PostgreSQL\18\pgAdmin 4\python\python.exe' tools\extract_mockup_assets.py
```

The script recreates `resources/assets/`, generates hover variants, and prints every emitted asset path.

## Legacy Experimental Code

Older experiments under `projects/` and `Dependencies/` are preserved but are no longer part of the default build. If you explicitly want them too, configure with:

```powershell
cmake -S . -B out/build `
  -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" `
  -DPROJECTPOTATO_ENABLE_LEGACY_EXPERIMENTS=ON
```

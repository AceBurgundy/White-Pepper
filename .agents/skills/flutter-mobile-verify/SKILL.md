---
name: flutter-mobile-verify
description: Spawns a clean terminal, runs the backend and Flutter app in a mobile phone viewport/emulator, and checks Dart MCP and browser logs for RenderFlex overflows and runtime errors.
---

# Flutter Mobile UI Overflow & Full-Stack Verification (`flutter-mobile-verify`)

## Overview
This skill enforces automated full-stack and mobile viewport verification after every frontend (Flutter/Dart) or backend (Python CLI/server) code change.

## Mandatory Execution Steps

### Step 1: Clean New Terminal Window Every Time
1. Call `manage_task` with `Action: "list"` to inspect all active background tasks.
2. Call `manage_task` with `Action: "kill"` on any previous backend or `flutter run` tasks so stale processes never linger.
3. Spawn a brand-new terminal session via `run_command` (`IsDaemon: true` / persistent session, never reusing a previous terminal ID) to start the backend and the Flutter app.

### Step 2: Enforce Mobile Phone Screen Dimensions
1. Check `flutter devices` / `flutter emulators`.
2. If an Android Emulator or iOS Simulator is available, launch it and run `flutter run` on that mobile target, connecting the DTD / VM Service URI to the `dart` MCP server.
3. If no mobile emulator is available (or when running on Web/Desktop), run `flutter run -d web-server` (or resize the test surface/viewport) in the new terminal, and invoke the built-in browser subagent (`invoke_subagent` with `TypeName: "browser"`) or viewport harness to resize the window/viewport to small phone resolutions (`360x800` and `375x667`) before navigating through the app.

### Step 3: Detect Mobile UI Overflows & Runtime Errors
1. Navigate through all modified screens, tables, drawers, and interactive steps.
2. Call the `dart` MCP tools (`get_runtime_errors` and `get_widget_tree`) alongside checking the terminal stdout and Chrome DevTools console.
3. Specifically scan for:
   - `RenderFlex overflowed`
   - `unbounded height/width`
   - `ParentDataWidget` errors
   - Uncaught Dart assertions or runtime exceptions
   - Backend terminal errors

### Step 4: Fix & Re-Verify
1. If any layout overflow or runtime error is detected, apply the `flutter-fix-layout-issues`, `flutter-build-responsive-layout`, and `dart-fix-runtime-errors` skills (e.g., wrapping wide tables/rows in `SingleChildScrollView(scrollDirection: Axis.horizontal)`, using `Expanded`/`Flexible`, or responsive `LayoutBuilder` breakpoints).
2. Re-run verification in a clean terminal until zero errors remain.

# Release Guide — White Pepper Scanner Suite

This document outlines the build and release workflow for packaging the White Pepper Flutter Desktop Suite.

---

## 1. Automated GitHub Actions Release Workflow

The repository includes a GitHub Actions workflow at [`.github/workflows/release-desktop.yml`](./.github/workflows/release-desktop.yml) that triggers automatically when a version tag is pushed:

```bash
git tag -a v1.3.0 -m "Release v1.3.0 milestone"
git push origin v1.3.0
```

GitHub Actions will automatically:
1. Check out the repository and nested `scripts/` submodule.
2. Set up Flutter and run `flutter analyze` and `flutter test`.
3. Compile the production binary via `flutter build windows --release`.
4. Run Inno Setup Compiler (`ISCC.exe`) to generate `WhitePepper-Desktop-Setup-v1.3.0.exe`.
5. Compress a portable ZIP archive `WhitePepper-Desktop-Portable.zip`.
6. Publish both artifacts directly to the GitHub Release.

---

## 2. Local Installer Compilation (PowerShell)

To build and compile the Windows installer locally on your Windows development machine:

### Prerequisites:
- Flutter SDK (stable)
- Inno Setup 6 (`winget install JRSoftware.InnoSetup` or install from [jrsoftware.org](https://jrsoftware.org/isdl.php))

### Build Script:
Run the automated installer script:
```powershell
powershell -ExecutionPolicy Bypass -File installer\build_desktop_installer.ps1
```

If you already built the release executable and only want to re-compile the Inno Setup script:
```powershell
powershell -ExecutionPolicy Bypass -File installer\build_desktop_installer.ps1 -SkipFlutterBuild
```

The resulting installer is saved in:
```text
installer\output\WhitePepper-Desktop-Setup-v1.3.0.exe
```

# Installing White Pepper Scanner Suite

This guide explains how to install, configure, update, and uninstall the **White Pepper Scanner Suite** on Windows.

---

## 1. Standard Windows Installer (`WhitePepper-Desktop-Setup-v1.3.0.exe`)

The official Windows installer packages the complete Flutter desktop application, native graphics libraries, and the headless Python scanning engine in a single, self-contained setup wizard.

### Step-by-Step Installation:
1. Download **`WhitePepper-Desktop-Setup-v1.3.0.exe`** from the [GitHub Releases](https://github.com/AceBurgundy/white_pepper/releases) page.
2. Double-click the downloaded executable to open the Setup Wizard.
3. **Choose Installation Scope**:
   - *Install for me only* (Default, requires no Administrator privileges; installs to `%LOCALAPPDATA%\Programs\White Pepper`).
   - *Install for all users* (Installs to `C:\Program Files\White Pepper`).
4. **Choose Destination Folder**:
   - You can accept the default or browse to any custom folder or drive (e.g., `D:\Apps\White Pepper`).
5. **Select Additional Shortcuts**:
   - Check the **Create a desktop shortcut** checkbox if you want a White Pepper icon on your desktop.
6. Click **Install**.
7. Once finished, click **Finish** to immediately launch White Pepper Scanner.

---

## 2. Portable Mode (No Installation Required)

If you prefer not to install the application into Windows:
1. Download **`WhitePepper-Desktop-Portable.zip`** from [GitHub Releases](https://github.com/AceBurgundy/white_pepper/releases).
2. Extract the ZIP archive to any directory (e.g. `D:\Tools\White Pepper` or a USB drive).
3. Ensure Python 3.10+ is installed on your computer with the dependencies in `scripts/requirements.txt`:
   ```powershell
   pip install -r scripts\requirements.txt
   ```
4. Double-click `white_pepper.exe` to launch the application.

---

## 3. Uninstalling White Pepper

White Pepper registers an uninstaller with Windows:
1. Open Windows **Settings** (`Win + I`) → **Apps** → **Installed Apps** (or **Add/Remove Programs** in Control Panel).
2. Locate **White Pepper Scanner Suite**.
3. Click the three dots `...` and select **Uninstall**.
4. Alternatively, run `unins000.exe` directly from the White Pepper installation folder.
5. All application files, desktop shortcuts, and Start Menu entries are removed cleanly.

---

## 4. Hardware Connectivity Verification
Once installed and launched:
1. Connect your scanner (Wi-Fi eSCL at `http://192.168.1.150:8080/eSCL` or USB cable).
2. Click **Connect** in the sidebar (or the top-right bell icon) to test hardware status.
3. Select any workflow card (Flatbed, ID Card Duplex, Legal 2-Pass Stitch, etc.) and start scanning!

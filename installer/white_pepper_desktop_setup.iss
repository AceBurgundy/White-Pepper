; Inno Setup 6 Script for White Pepper Flutter Desktop Suite
; Author: AceBurgundy <Samadriansabalo99@gmail.com>

#define MyAppName "White Pepper Scanner Suite"
#define MyAppVersion "1.3.0"
#define MyAppPublisher "AceBurgundy"
#define MyAppURL "https://github.com/AceBurgundy/white_pepper"
#define MyAppExeName "white_pepper.exe"

[Setup]
AppId={{9B78A942-F203-4D90-8AE2-12C88915C421}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={autopf}\White Pepper
DefaultGroupName=White Pepper
AllowNoIcons=yes
OutputDir=output
OutputBaseFilename=WhitePepper-Desktop-Setup-v{#MyAppVersion}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
SetupIconFile=app_icon.ico
UninstallDisplayIcon={app}\app_icon.ico
UninstallDisplayName={#MyAppName}
CloseApplications=yes
RestartApplications=no
VersionInfoVersion=1.3.0.0
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=White Pepper Scanner Suite Setup
VersionInfoTextVersion={#MyAppVersion}
VersionInfoCopyright=Copyright (C) 2026 AceBurgundy
VersionInfoProductName=White Pepper Scanner Suite
VersionInfoProductVersion=1.3.0.0

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Custom Application Icon
Source: "app_icon.ico"; DestDir: "{app}"; Flags: ignoreversion
; Main Flutter Windows Release binaries and assets
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; Isolated Headless Python CLI Backend Engine
Source: "..\scripts\*"; DestDir: "{app}\scripts"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: ".git\*,.old.git*\,__pycache__\*,*.pyc,*.pyo,scratch\*,test_output\*"

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"
Name: "{group}\White Pepper Documentation"; Filename: "{app}\scripts\documentation\index.html"; IconFilename: "{app}\app_icon.ico"; Flags: createonlyiffileexists
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app_icon.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\scripts\__pycache__"
Type: filesandordirs; Name: "{app}\scripts\white_pepper\__pycache__"
Type: filesandordirs; Name: "{app}\scripts\white_pepper\*\__pycache__"

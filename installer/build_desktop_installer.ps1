<#
.SYNOPSIS
    Builds the White Pepper Windows Release executable and compiles the Inno Setup installer.
.DESCRIPTION
    1. Runs `flutter build windows --release`.
    2. Automatically locates `ISCC.exe` on the system.
    3. Compiles `white_pepper_desktop_setup.iss` to produce `WhitePepper-Desktop-Setup-v1.3.0.exe`.
#>

[CmdletBinding()]
param(
    [switch]$SkipFlutterBuild
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Resolve-Path "$PSScriptRoot\.."
Set-Location $ProjectRoot

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  White Pepper Scanner Suite — Desktop Installer Builder  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Flutter Release Build
if (-not $SkipFlutterBuild) {
    Write-Host "`n[1/3] Building Flutter Windows application in release mode..." -ForegroundColor Yellow
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Flutter build failed with exit code $LASTEXITCODE."
    }
} else {
    Write-Host "`n[1/3] Skipping Flutter release build as requested." -ForegroundColor DarkGray
}

$ReleaseExe = "$ProjectRoot\build\windows\x64\runner\Release\white_pepper.exe"
if (-not (Test-Path $ReleaseExe)) {
    Write-Error "Release executable not found at: $ReleaseExe"
}

# 2. Locate Inno Setup Compiler (ISCC.exe)
Write-Host "`n[2/3] Searching for Inno Setup 6 compiler (ISCC.exe)..." -ForegroundColor Yellow
$IsccCandidatePaths = @(
    (Get-Command ISCC.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles (x86)\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
)

$IsccPath = $null
foreach ($Path in $IsccCandidatePaths) {
    if ($Path -and (Test-Path $Path)) {
        $IsccPath = $Path
        break
    }
}

if (-not $IsccPath) {
    Write-Error "Could not find Inno Setup 6 compiler (ISCC.exe). Please install Inno Setup 6 via 'winget install JRSoftware.InnoSetup' or add it to PATH."
}
Write-Host "Found Inno Setup compiler: $IsccPath" -ForegroundColor Green

# 3. Compile Installer
Write-Host "`n[3/3] Compiling installer wizard via Inno Setup..." -ForegroundColor Yellow
$IssPath = "$ProjectRoot\installer\white_pepper_desktop_setup.iss"
$OutputDir = "$ProjectRoot\installer\output"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

& $IsccPath $IssPath
if ($LASTEXITCODE -ne 0) {
    Write-Error "Inno Setup compilation failed with exit code $LASTEXITCODE."
}

$InstallerFile = Get-ChildItem -Path $OutputDir -Filter "WhitePepper-Desktop-Setup-*.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($InstallerFile) {
    $SizeMb = [math]::Round($InstallerFile.Length / 1MB, 2)
    Write-Host "`n[SUCCESS] Installer successfully compiled!" -ForegroundColor Green
    Write-Host "  File   : $($InstallerFile.FullName)" -ForegroundColor Cyan
    Write-Host "  Size   : $SizeMb MB" -ForegroundColor Cyan
} else {
    Write-Error "Installer file was not generated in $OutputDir"
}

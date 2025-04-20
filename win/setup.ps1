# Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run as Administrator" -ForegroundColor Red
    exit 1
}

# Function to move files to their destination
function Move-ConfigFile {
    param(
        [string]$source,
        [string]$target,
        [switch]$CreateBackup = $true
    )

    if (Test-Path $target -and $CreateBackup) {
        Write-Host "Backing up existing $target to $target.backup"
        if (Test-Path "$target.backup") {
            Remove-Item "$target.backup" -Force -Recurse
        }
        Move-Item -Path $target -Destination "$target.backup" -Force
    }

    # Create parent directory if it doesn't exist
    $targetDir = Split-Path -Parent $target
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force
    }

    Write-Host "Moving configuration file from $source to $target"
    Copy-Item -Path $source -Destination $target -Force
}

# Check and install winget if needed
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $hasWinget) {
    Write-Host "Installing winget..."
    $progressPreference = 'silentlyContinue'
    $dlurl = 'https://aka.ms/getwinget'
    $outpath = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
    Invoke-WebRequest -Uri $dlurl -OutFile $outpath
    Add-AppxPackage -Path $outpath
    Remove-Item $outpath
}

# Function to ensure a package is installed
function Install-RequiredPackage {
    param (
        [string]$Name,
        [string]$Id
    )

    Write-Host "Checking for $Name..."
    $package = winget list --id $Id --exact
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Installing $Name..."
        winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements
    }
}

# Install essential packages
Install-RequiredPackage -Name "Windows Terminal" -Id "Microsoft.WindowsTerminal"
Install-RequiredPackage -Name "VS Code" -Id "Microsoft.VisualStudioCode"
Install-RequiredPackage -Name "Starship" -Id "Starship.Starship"

# Install packages from packages.json
Write-Host "Installing packages from winget..."
$packagesFile = "$PSScriptRoot\application\packages.json"
if (Test-Path $packagesFile) {
    winget import -i $packagesFile --accept-package-agreements --accept-source-agreements
} else {
    Write-Warning "packages.json not found at $packagesFile"
}

# Configure Windows Terminal
$terminalSettingsPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Move-ConfigFile -source "$PSScriptRoot\terminal\settings.json" -target $terminalSettingsPath

# Setup VS Code
Write-Host "Setting up VS Code configuration..."
$vscodePath = "$env:APPDATA\Code\User"
if (!(Test-Path $vscodePath)) {
    New-Item -ItemType Directory -Path $vscodePath -Force
}

# VS Code settings and tasks
Move-ConfigFile -source "$PSScriptRoot\..\vscode\settings.json" -target "$vscodePath\settings.json"
Move-ConfigFile -source "$PSScriptRoot\..\vscode\tasks.json" -target "$vscodePath\tasks.json"

# Install VS Code extensions
Write-Host "Installing VS Code extensions..."
$extensionsFile = "$PSScriptRoot\..\vscode\extensions.txt"
if (Test-Path $extensionsFile) {
    Get-Content $extensionsFile | ForEach-Object {
        if ($_.Trim()) {
            Write-Host "Installing VS Code extension: $_"
            code --install-extension $_ --force
        }
    }
} else {
    Write-Warning "extensions.txt not found at $extensionsFile"
}

# Setup Starship
Write-Host "Setting up Starship configuration..."
$starshipConfigDir = "$env:USERPROFILE\.config"
if (!(Test-Path $starshipConfigDir)) {
    New-Item -ItemType Directory -Path $starshipConfigDir -Force
}
Move-ConfigFile -source "$PSScriptRoot\..\starship.toml" -target "$starshipConfigDir\starship.toml"

# Setup PowerShell profile
$powerShellProfileDir = "$env:USERPROFILE\Documents\PowerShell"
if (!(Test-Path $powerShellProfileDir)) {
    New-Item -ItemType Directory -Path $powerShellProfileDir -Force
}

# Install PowerShell modules
Write-Host "Installing PowerShell modules..."
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force
Install-Module -Name PSReadLine -Scope CurrentUser -Force -AllowPrerelease

# Initialize PowerShell profile
$profileContent = @"
# Initialize Starship prompt
Invoke-Expression (&starship init powershell)

# Set useful aliases
Set-Alias -Name g -Value git
Set-Alias -Name ll -Value ls

# Import Terminal-Icons for better directory listing
Import-Module -Name Terminal-Icons

# Better history
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# Better tab completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Better command history
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
"@

Set-Content -Path "$powerShellProfileDir\Microsoft.PowerShell_profile.ps1" -Value $profileContent

Write-Host "`nSetup completed! Please restart your terminal for changes to take effect." -ForegroundColor Green
Write-Host "You may want to configure Git with your credentials:"
Write-Host "git config --global user.name 'Your Name'"
Write-Host "git config --global user.email 'your@email.com'"

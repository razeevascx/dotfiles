# Requires -RunAsAdministrator

# Check if winget is installed
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $hasWinget) {
    Write-Host "Winget is not installed. Installing Microsoft.DesktopAppInstaller..."
    $progressPreference = 'silentlyContinue'
    Write-Information "Downloading Microsoft.DesktopAppInstaller..."
    $dlurl = 'https://aka.ms/getwinget'
    $outpath = "$env:TEMP\Microsoft.DesktopAppInstaller.msixbundle"
    Invoke-WebRequest -Uri $dlurl -OutFile $outpath
    Add-AppxPackage -Path $outpath
    Remove-Item $outpath
}

# Function to create symbolic links
function New-SymbolicLink {
    param(
        [string]$source,
        [string]$target
    )

    if (Test-Path $target) {
        Write-Host "Backing up existing $target to $target.backup"
        Move-Item -Path $target -Destination "$target.backup" -Force
    }

    Write-Host "Creating symbolic link from $source to $target"
    New-Item -ItemType SymbolicLink -Path $target -Target $source -Force
}

# 1. Install winget packages first
Write-Host "Installing packages from winget..."
winget import -i "$PSScriptRoot\application\packages.json" --accept-package-agreements --accept-source-agreements

# Configure Windows Terminal settings
$terminalSettingsPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
New-SymbolicLink -source "$PSScriptRoot\terminal\settings.json" -target $terminalSettingsPath

# 2. Setup Visual Studio Code settings
Write-Host "Setting up VS Code configuration..."
$vscodePath = "$env:APPDATA\Code\User"
if (!(Test-Path $vscodePath)) {
    New-Item -ItemType Directory -Path $vscodePath -Force
}
New-SymbolicLink -source "$PSScriptRoot\..\vscode\settings.json" -target "$vscodePath\settings.json"
New-SymbolicLink -source "$PSScriptRoot\..\vscode\tasks.json" -target "$vscodePath\tasks.json"
New-SymbolicLink -source "$PSScriptRoot\..\prettierrc" -target "$env:USERPROFILE\.prettierrc"

# 3. Install VS Code extensions
Write-Host "Installing VS Code extensions..."
Get-Content "$PSScriptRoot\..\vscode\extensions.txt" | ForEach-Object {
    Write-Host "Installing VS Code extension: $_"
    code --install-extension $_ --force
}

# Create shortcut for Windows Terminal quick launch
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$wtScriptPath = "$PSScriptRoot\terminal\wt.ps1"
$shortcutPath = "$startupPath\Terminal.lnk"

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$wtScriptPath`""
$Shortcut.Save()

# 4. Setup Starship
Write-Host "Setting up Starship configuration..."
$starshipConfigDir = "$env:USERPROFILE\.config"
if (!(Test-Path $starshipConfigDir)) {
    New-Item -ItemType Directory -Path $starshipConfigDir -Force
}
New-SymbolicLink -source "$PSScriptRoot\..\starship.toml" -target "$starshipConfigDir\starship.toml"

# 5. Setup Git configuration
Write-Host "Setting up Git configuration..."
New-SymbolicLink -source "$PSScriptRoot\git\.gitconfig" -target "$env:USERPROFILE\.gitconfig"
New-SymbolicLink -source "$PSScriptRoot\git\.gitignore_global" -target "$env:USERPROFILE\.gitignore_global"

# Set up PowerShell profile
$powerShellProfileDir = "$env:USERPROFILE\Documents\PowerShell"
if (!(Test-Path $powerShellProfileDir)) {
    New-Item -ItemType Directory -Path $powerShellProfileDir -Force
}

# Initialize Starship prompt in PowerShell profile
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
"@

Set-Content -Path "$powerShellProfileDir\Microsoft.PowerShell_profile.ps1" -Value $profileContent

Write-Host "Setup completed! Please restart your terminal for changes to take effect."

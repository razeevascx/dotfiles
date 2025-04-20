[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'Continue'

$repoUrl = "https://github.com/razeevascx/dotfiles"
$branch = "main"

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script requires Administrator privileges. Please run PowerShell as Administrator and try again."
    exit 1
}

Write-Host "`n🚀 Starting dotfiles installation..." -ForegroundColor Cyan

function Get-Repository {
    param (
        [string]$url,
        [string]$branch,
        [string]$destination
    )

    try {
        Write-Host "📦 Downloading configuration files..."
        $tempZip = Join-Path $env:TEMP "dotfiles-$branch.zip"
        $downloadUrl = "$url/archive/refs/heads/$branch.zip"

        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

        if (Test-Path $destination) {
            Write-Host "🗑️ Removing existing dotfiles..."
            Remove-Item -Path $destination -Recurse -Force
        }

        Write-Host "📂 Extracting files..."
        Expand-Archive -Path $tempZip -DestinationPath $env:TEMP -Force
        $extractedFolder = Join-Path $env:TEMP "dotfiles-$branch"
        Move-Item -Path $extractedFolder -Destination $destination -Force
        Remove-Item -Path $tempZip -Force

        Write-Host "✅ Download completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to download and extract repository: $_"
        exit 1
    }
}

# Set up destination directory
$setupDir = "$env:USERPROFILE\dotfiles"

try {
    # Download and extract the repository
    Get-Repository -url $repoUrl -branch $branch -destination $setupDir

    # Set execution policy for this process
    Write-Host "`n🔒 Setting execution policy..."
    Set-ExecutionPolicy Bypass -Scope Process -Force

    # Run the main setup script
    Write-Host "`n🔧 Running setup script..."
    Set-Location $setupDir
    & "$setupDir\win\setup.ps1"

    if ($LASTEXITCODE -ne 0) {
        throw "Setup script failed with exit code $LASTEXITCODE"
    }

    Write-Host "`n✨ Installation completed successfully!" -ForegroundColor Green
    Write-Host "Please restart your terminal to apply all changes." -ForegroundColor Cyan
}
catch {
    Write-Error "Installation failed: $_"
    exit 1
}

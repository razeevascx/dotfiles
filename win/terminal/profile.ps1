# PowerShell Profile Configuration

# Environment Variables
$env:EDITOR = 'code --wait'
$env:PATH = "$env:PATH;$HOME\.local\bin"

# Initialize Starship prompt
Invoke-Expression (&starship init powershell)

# PSReadLine Configuration
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Import Modules
Import-Module -Name Terminal-Icons
Import-Module -Name posh-git -ErrorAction SilentlyContinue

# Useful aliases
Set-Alias -Name g -Value git
Set-Alias -Name ll -Value ls
Set-Alias -Name grep -Value findstr
Set-Alias -Name which -Value Get-Command
Set-Alias -Name touch -Value New-Item
Set-Alias -Name less -Value more

# Custom Functions
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

function Get-GitStatus { git status }
New-Alias -Name gs -Value Get-GitStatus

function Get-GitLog { git log --oneline --graph --decorate --all }
New-Alias -Name gl -Value Get-GitLog

# Development shortcuts
function Start-DevServer {
    if (Test-Path package.json) {
        npm run dev
    } elseif (Test-Path manage.py) {
        python manage.py runserver
    } else {
        Write-Host "No recognized development server configuration found."
    }
}
Set-Alias -Name dev -Value Start-DevServer

# Directory navigation
function proj { Set-Location $HOME\Projects }
function docs { Set-Location $HOME\Documents }
function dt { Set-Location $HOME\Desktop }

# Helper functions
function New-Directory-And-Enter($path) {
    New-Item -Path $path -ItemType Directory
    Set-Location -Path $path
}
Set-Alias -Name mkcd -Value New-Directory-And-Enter

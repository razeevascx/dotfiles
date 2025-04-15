# Windows Dotfiles

A collection of dotfiles and setup scripts for Windows development environment.

## Features

- PowerShell configuration with Starship prompt
- Windows Terminal settings with Catppuccin Mocha theme
- VS Code settings and extensions
- Automated software installation via winget
- Git configuration
- Development tools and fonts

## Installation

1. Clone this repository:

```powershell
git clone https://github.com/razeevascx/dotfiles.git
cd dotfiles
```

2. Run the setup script as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\win\setup.ps1
```

## What's Included

- 🔧 PowerShell profile with custom configuration
- 🎨 Windows Terminal with Catppuccin Mocha theme and JetBrains Mono Nerd Font
- 📝 VS Code with essential extensions and settings
- ⚡ Starship prompt customization
- 🚀 Development tools (Node.js, Python, Java, Git, etc.)
- 📦 Common applications via winget

## Post-Installation

After running the setup script:

1. Restart your terminal to apply the new settings
2. Open VS Code to let it install all extensions
3. Configure Git with your credentials:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

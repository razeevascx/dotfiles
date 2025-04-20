# Windows Dotfiles

A collection of dotfiles and setup scripts for Windows development environment.

## ⚠️ Important Note

The installation scripts require Administrator privileges. Make sure to run PowerShell as Administrator before proceeding with either the quick or manual installation methods.

## Quick Installation

Run this command in an administrator PowerShell window:

```powershell
irm "https://raw.githubusercontent.com/razeevascx/dotfiles/main/win/install.ps1" | iex
```

The script will:

1. Download the configuration files from the repository
2. Remove any existing dotfiles installation
3. Extract the files to `%USERPROFILE%\dotfiles`
4. Run the setup script automatically

## Manual Installation

### Installation

1. Clone this repository:

```powershell
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
```

2. Run the setup script as Administrator:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\win\setup.ps1
```

### What Gets Configured

- Windows Terminal with custom settings
- VS Code settings and extensions
- Starship prompt configuration
- PowerShell profile with useful aliases and better history
- Application installations via winget

### Included Applications

The `win/application/packages.json` contains a list of applications that will be installed via winget.

### Post-Installation

After running the setup script:

1. Restart your terminal to apply the new settings
2. Open VS Code to let it install all extensions
3. Configure Git with your credentials:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Troubleshooting

If you encounter any issues during installation:

1. Ensure you're running PowerShell as Administrator
2. Check your internet connection if the download fails
3. Look for error messages in the console output
4. Make sure no applications are locking any configuration files

If the installation fails, the script will display an error message explaining what went wrong.

### Customization

You can customize the configuration by modifying these files:

- `win/terminal/settings.json` - Windows Terminal settings
- `vscode/settings.json` - VS Code settings
- `vscode/tasks.json` - VS Code tasks
- `starship.toml` - Starship prompt configuration
- `win/application/packages.json` - Installed applications list

### Adding New VS Code Extensions

To add new VS Code extensions, add their identifiers to `vscode/extensions.txt`, one per line.

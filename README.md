# VlaDexa's NixOS Configuration

This repository contains my personal NixOS configuration using Flakes, Home Manager, and various modern NixOS tools.

## 🖥️ System Configurations

This flake defines two NixOS system configurations:

- **nixos** - Laptop configuration with KDE Plasma 6 desktop (AMD CPU/GPU with optimizations)
- **workstation** - Gaming/streaming desktop with Hyprland compositor (AMD CPU/GPU with optimizations)

Both systems share a common configuration base with user-specific customizations.

## ✨ Key Features

### Desktop Environment

#### Laptop (KDE Plasma 6)
- **KDE Plasma 6** with custom theming (Klassy theme)
- SDDM display manager
- KDE Connect for mobile device integration
- Custom keyboard layouts (US/RU) with Alt+Shift switching

#### Workstation (Hyprland)
- **Hyprland** tiling Wayland compositor
- Ly display manager with animations
- Waybar for status bar
- Wofi application launcher
- Dunst notification daemon
- Hyprlock screen locker
- Qt5ct theming with Adwaita Dark

### Both Systems
- Hardware acceleration for Chromium using Vulkan/ANGLE

### Development Tools
- **Neovim** (via nixvim) as the default editor
- **Fish shell** with Kitty terminal emulator
- Git with SSH signing enabled
- GitHub CLI (gh)
- Direnv with nix-direnv integration
- Developer environments via devenv

### Applications
- **Browsers**: Firefox and Chromium (with extensions)
- **Communication**: Telegram, Teams for Linux, Vesktop (Discord)
- **Email**: Thunderbird with multiple account support
- **Media**: MPV with yt-dlp integration for streaming
- **Password Manager**: Bitwarden (self-hosted)
- **Music**: Spotify

#### Workstation-Specific
- **Gaming**: Steam with Proton-GE, HDR support, remote play
- **Streaming**: OBS Studio with pipewire, vkcapture, and wlrobs plugins
- **Office**: LibreOffice Fresh
- **File Sharing**: qBittorrent
- **Containers**: Distrobox with Arch Linux container
- **VPN**: Mullvad VPN and WireGuard

### Security & Secrets
- **SOPS** (Secrets OPerationS) for managing encrypted secrets
- **Lanzaboote** for Secure Boot support
- GPG and SSH key management

### System Features
- **Disko** for declarative disk partitioning
- **Cachix** for binary cache
- **NUR** (Nix User Repository) integration
- **Nix-index** for command-not-found functionality
- Hardware-specific optimizations via nixos-hardware modules
- Pre-commit hooks for code quality

#### Workstation-Specific
- **AMD GPU Control**: LACT for overclocking and fan management
- **Audio**: EasyEffects for audio processing
- **ADB**: Android Debug Bridge support
- **Zram**: On laptop for swap optimization
- **Network**: systemd-networkd (workstation), NetworkManager (laptop)

## 📁 Repository Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Flake inputs lock file
├── cachix.nix             # Cachix binary cache configuration
├── secure-boot.nix        # Secure boot configuration
├── secrets.yaml           # Encrypted secrets (SOPS)
├── .sops.yaml             # SOPS configuration
├── modules/               # Reusable NixOS modules
│   ├── programs/          # Program-specific configurations
│   ├── services/          # Service configurations
│   ├── containers/        # Container definitions
│   └── plymouth.nix       # Boot splash screen
├── nixosConfigs/          # System-specific configurations
│   ├── laptop/            # Laptop-specific config
│   ├── workstation/       # Workstation-specific config
│   └── shared/            # Shared configurations
│       ├── configuration.nix
│       └── home/          # Home Manager configurations
│           └── vladexa.nix
└── cachix/                # Cachix-related files
```

## 🚀 Usage

### Building a Configuration

To build a specific system configuration:

```bash
# Build laptop configuration
nix build .#nixosConfigurations.nixos.config.system.build.toplevel

# Build workstation configuration
nix build .#nixosConfigurations.workstation.config.system.build.toplevel
```

### Applying Configuration

On the target system:

```bash
# Switch to new configuration
sudo nixos-rebuild switch --flake .#nixos

# Or for workstation
sudo nixos-rebuild switch --flake .#workstation
```

Using the `nh` helper (configured in the system):

```bash
nh os switch
```

### Development Shell

Enter a development shell with all required tools:

```bash
nix develop
```

This provides:
- `nil` (Nix LSP)
- Pre-commit hooks (nixfmt-rfc-style)
- All tools needed for development

### Formatting Code

Format all Nix files:

```bash
nix fmt
```

### Running Checks

Run pre-commit checks:

```bash
nix flake check
```

## 🔧 Customization

### Adding a New System

1. Create a new directory under `nixosConfigs/`
2. Add the system configuration to `flake.nix` in the `nixosConfigurations` section
3. Reference shared modules and customize as needed

### Adding Programs

1. Create a new module in `modules/programs/`
2. Import it in `modules/programs/default.nix` or directly in your configuration
3. Configure the program in your home configuration

### Managing Secrets

Secrets are managed using SOPS:

1. Ensure you have the age key in `/var/lib/sops-nix/key.txt`
2. Edit secrets: `sops secrets.yaml`
3. Reference secrets in your configuration using `config.sops.secrets.<name>.path`

## 📋 Requirements

- NixOS with Flakes enabled
- For Secure Boot: TPM 2.0 and UEFI firmware
- For secrets: SOPS age key configured

## 🔗 Related Projects

- [nixvim-config](https://github.com/VlaDexa/nixvim-config) - My Neovim configuration
- [Hyprland](https://github.com/VlaDexa/Hyprland) - Custom Hyprland fork

## 📝 License

This is personal configuration. Feel free to use it as inspiration for your own setup.

## 🙏 Acknowledgments

This configuration uses many excellent projects from the Nix community:
- [NixOS](https://nixos.org/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [SOPS-nix](https://github.com/Mic92/sops-nix)
- [Lanzaboote](https://github.com/nix-community/lanzaboote)
- [nixos-hardware](https://github.com/NixOS/nixos-hardware)
- And many more!

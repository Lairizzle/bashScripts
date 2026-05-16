#!/bin/bash

set -e  # Exit immediately on error

# List of packages to install via pacman
packages=(
  ark
  btop
  discord
  dotnet-sdk
  eza
  filezilla
  fzf
  gimp
  github-cli
  godot-mono
  gnome-keyring
  gvfs
  hugo
  kdenlive
  kitty
  lutris
  man
  neovim
  nextcloud-client
  noto-fonts
  noto-fonts-emoji
  noto-fonts-extra
  npm
  obs-studio
  pavucontrol
  rofi
  rustup
  spotify-launcher
  starship
  steam
  swaync
  tailscale
  tealdeer
  thunar
  thunar-archive-plugin
  ttf-jetbrains-mono-nerd
  unzip
  vlc
  vlc-plugins-all
  waybar
  wiremix
  zoxide
)

# Function to install yay
install_yay() {
  if ! command -v yay &>/dev/null; then
    echo "Installing yay AUR helper..."
    sudo pacman -S --noconfirm --needed base-devel git
    temp_dir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    cd "$temp_dir/yay"
    makepkg -si --noconfirm
    cd -
    rm -rf "$temp_dir"
  else
    echo "yay is already installed."
  fi
}

# Install yay if not available
install_yay

# Update system and install packages
echo "Installing packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm --needed "${packages[@]}"

yay -Syu brave-bin --noconfirm
yay -Syu protonup-qt --noconfirm
yay -Syu wlogout --noconfirm

# Clone Niri-Dots and copy to ~/.config
temp_dir=$(mktemp -d)

echo "Cloning Niri-Dots..."
git clone https://github.com/Lairizzle/niri-dots "$temp_dir"

echo "Creating ~/.config if needed..."
mkdir -p "$HOME/.config"

echo "Copying config files to ~/.config..."
cp -r "$temp_dir"/* "$HOME/.config/"

rm -rf "$temp_dir"

# Prompt for reboot
echo "Setup complete!"
read -rp "Would you like to reboot now to apply all changes? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Rebooting..."
  sudo shutdown -r now
else
  echo "Reboot skipped. Please reboot manually for changes to take effect."
f

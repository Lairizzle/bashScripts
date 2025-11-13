#!/bin/bash

set -e  # Exit immediately on error

# List of packages to install via pacman
packages=(
  btop
  kitty
  neovim
  firefox
  thunderbird
  ttf-jetbrains-mono-nerd
  noto-fonts
  noto-fonts-emoji
  noto-fonts-extra
  discord
  tealdeer
  unzip
  npm
  starship
  zoxide
  fzf
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

# Clone TokyoDots and copy to ~/.config
temp_dir=$(mktemp -d)

echo "Cloning TokyoDots..."
git clone https://github.com/Lairizzle/tokyoDots "$temp_dir"

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
fi

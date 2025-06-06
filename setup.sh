#!/bin/bash

set -e  # Exit immediately on error

# List of packages to install via pacman
packages=(
  btop
  dunst
  kitty
  neovim
  rofi
  waybar
  hypridle
  hyprlock
  hyprpaper
  mc
  firefox
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

# Clone GruvDots and copy to ~/.config
temp_dir=$(mktemp -d)

echo "Cloning GruvDots..."
git clone https://github.com/Lairizzle/GruvDots "$temp_dir"

echo "Creating ~/.config if needed..."
mkdir -p "$HOME/.config"

echo "Copying config files to ~/.config..."
cp -r "$temp_dir"/* "$HOME/.config/"

rm -rf "$temp_dir"

echo "✅ Setup complete! All packages installed and configs copied to ~/.config."

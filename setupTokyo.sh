#!/bin/bash

set -e  # Exit immediately on error

# List of packages to install via pacman
packages=(
  ark
  btop
  dunst
  kitty
  hugo
  vlc
  vlc-plugins-all
  neovim
  rofi
  waybar
  hypridle
  hyprlock
  hyprpaper
  mc
  gnome-keyring
  ttf-jetbrains-mono-nerd
  noto-fonts
  noto-fonts-emoji
  noto-fonts-extra
  discord
  man
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

yay -Syu brave-bin --noconfirm
yay -Syu hyprshot --noconfirm
yay -Syu protonup-qt --noconfirm

# Install Tokyo Night skin for Midnight Commander
echo "Installing tokyonight skin for Midnight Commander..."
skin_temp=$(mktemp -d)
git clone https://github.com/Lairizzle/mc-tokyonight-skin "$skin_temp"
mkdir -p "$HOME/.local/share/mc/skins"
cp "$skin_temp/tokyonight.ini" "$HOME/.local/share/mc/skins/"
rm -rf "$skin_temp"

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
echo "Setup complete! greetd is configured for user '$username', Midnight Commander skin installed, and sddm is disabled."
read -rp "Would you like to reboot now to apply all changes? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Rebooting..."
  sudo shutdown -r now
else
  echo "Reboot skipped. Please reboot manually for changes to take effect."
fi

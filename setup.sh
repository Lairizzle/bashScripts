#!/bin/bash

set -e  # Exit immediately on error

# Ask for the username to be used in /etc/greetd/config.toml
read -rp "Enter your username (used in greetd config): " username

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
	hyprshot
  mc
  firefox
  greetd-tuigreet
	ttf-jetbrains-mono-nerd
	discord
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

# Install Gruvbox skin for Midnight Commander
echo "Installing gruvbox skin for Midnight Commander..."
skin_temp=$(mktemp -d)
git clone https://github.com/DmitriyMaksimovich/MidnightCommander-grovbox-port "$skin_temp"
mkdir -p "$HOME/.local/share/mc/skins"
cp "$skin_temp/gruvbox256.ini" "$HOME/.local/share/mc/skins/"
rm -rf "$skin_temp"

# Clone GruvDots and copy to ~/.config
temp_dir=$(mktemp -d)

echo "Cloning GruvDots..."
git clone https://github.com/Lairizzle/GruvDots "$temp_dir"

echo "Creating ~/.config if needed..."
mkdir -p "$HOME/.config"

echo "Copying config files to ~/.config..."
cp -r "$temp_dir"/* "$HOME/.config/"

rm -rf "$temp_dir"

# Create /etc/greetd/config.toml with the user's username
echo "Creating /etc/greetd/config.toml..."
sudo mkdir -p /etc/greetd

sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd hyprland --theme 'title=yellow;border=gray;prompt=yellow;time=yellow;button=gray'"
user = "$username"
EOF

# Disable sddm and enable greetd
echo "Disabling sddm.service and enabling greetd.service..."
sudo systemctl disable sddm.service
sudo systemctl enable greetd.service

# Prompt for reboot
echo "✅ Setup complete! greetd is configured for user '$username', Midnight Commander skin installed, and sddm is disabled."
read -rp "Would you like to reboot now to apply all changes? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Rebooting..."
  sudo shutdown -r now
else
  echo "Reboot skipped. Please reboot manually for changes to take effect."
fi

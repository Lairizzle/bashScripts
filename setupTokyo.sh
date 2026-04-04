#!/bin/bash

set -e  # Exit immediately on error

# List of packages to install via pacman
packages=(
  ark
  btop
  discord
  dotnet-sdk
  filezilla
  fzf
  gimp
  github-cli
  godot-mono
  gnome-keyring
  gvfs
  hugo
  hypridle
  hyprlock
  hyprpaper
  hyprshot
  kdenlive
  kitty
  lutris
  man
  mc
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
  sddm
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

# ==============================
# Configure Hyprland monitors (PRIMARY-BASED)
# ==============================

echo "Configuring Hyprland monitors..."

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

if [[ -f "$HYPR_CONF" ]]; then
  echo "Detected hyprland.conf at $HYPR_CONF"

  # Detect monitors
  mapfile -t MONITOR_INFO < <(hyprctl monitors)

  PRIMARY_MONITOR=$(hyprctl monitors | awk '/Monitor/ {name=$2} /focused: yes/ {print name}')

  if [[ -z "$PRIMARY_MONITOR" ]]; then
    echo "Could not detect primary monitor, falling back to first monitor..."
    PRIMARY_MONITOR=$(hyprctl monitors | awk '/Monitor/ {print $2; exit}')
  fi

  echo "Primary monitor detected: $PRIMARY_MONITOR"

  # ------------------------------
  # Rewrite monitor= lines
  # ------------------------------
  monitor_lines=""

  while read -r name res refresh pos scale; do
    monitor_lines+="monitor=$name, ${res}@${refresh}, ${pos}, ${scale}\n"
  done < <(
    hyprctl monitors | awk '
      /Monitor/ { name=$2 }
      /resolution:/ { res=$2 }
      /@/ { split($1,r,"@"); refresh=r[2] }
      /position:/ { pos=$2 }
      /scale:/ { scale=$2 }
      /active workspace:/ {
        print name, res, refresh, pos, scale
      }
    '
  )

  # Remove old monitor lines
  sed -i '/^monitor=/d' "$HYPR_CONF"

  # Insert new ones
  sed -i "/### MONITORS ###/a $monitor_lines" "$HYPR_CONF"

  # ------------------------------
  # Force everything to primary
  # ------------------------------

  echo "Rewriting all monitor references to $PRIMARY_MONITOR"

  # workspace monitor bindings
  sed -i -E "s/(workspace *= *[0-9]+, *monitor:)[A-Za-z0-9\\-]+/\\1$PRIMARY_MONITOR/g" "$HYPR_CONF"

  # focusmonitor binds
  sed -i -E "s/(focusmonitor )[A-Za-z0-9\\-]+/\\1$PRIMARY_MONITOR/g" "$HYPR_CONF"

  # window rules
  sed -i -E "s/(windowrule *= *monitor )[A-Za-z0-9\\-]+/\\1$PRIMARY_MONITOR/g" "$HYPR_CONF"

  echo "Hyprland monitor configuration updated (primary-based)."

else
  echo "hyprland.conf not found, skipping monitor configuration."
fi

# Install SDDM Midnight Crystal theme
echo "Installing SDDM theme: midnight-crystal..."

sddm_temp=$(mktemp -d)
git clone https://github.com/Lairizzle/sddm "$sddm_temp"

# Copy theme to system themes directory
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r "$sddm_temp/midnight-crystal" /usr/share/sddm/themes/

rm -rf "$sddm_temp"

# Configure SDDM theme (clean override method)
echo "Configuring SDDM to use midnight-crystal theme..."

sudo mkdir -p /etc/sddm.conf.d
sudo bash -c 'cat > /etc/sddm.conf.d/theme.conf <<EOF
[Theme]
Current=midnight-crystal
EOF'

# Prompt for reboot
echo "Setup complete!"
read -rp "Would you like to reboot now to apply all changes? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo "Rebooting..."
  sudo shutdown -r now
else
  echo "Reboot skipped. Please reboot manually for changes to take effect."
fi

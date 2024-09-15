#!/bin/bash

# Update the system and install Hyprland, Wayland utilities, and required packages
sudo pacman -Syu --noconfirm

# Install core packages
sudo pacman -S --noconfirm \
    hyprland \
    hyprctl \ 
    waybar \ 
    wofi \ 
    alacritty \
    fish \
    mako 
    pipewire \
    pipewire-pulse \
    pipewire-media-session \
    wireplumber \
    xorg-xwayland \
    polkit-gnome \
    bluez \
    bluez-utils \
    blueberry \
    networkmanager \
    swaylock \
    gnome-keyring\
    gvfs \
    gvfs-mtp \
    gvfs-smb \
    gtk3 \
    gtk4 \
    ttf-jetbrains-mono-nerd \
    noto-fonts-emoji \
    pavucontrol \
    sddm \
    sddm-kcm \
    xdg-desktop-portal-hyprland \
    xorg-xhost

# Install NVIDIA drivers and Wayland compatibility packages
sudo pacman -S --noconfirm \
    nvidia-dkms nvidia-utils nvidia-settings egl-wayland libglvnd mesa mesa-utils \
    vulkan-icd-loader libva-mesa-driver mesa-vdpau libva-nvidia-driver-git

# Configure NVIDIA kernel mode settings
sudo tee -a /etc/mkinitcpio.conf <<EOF
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
EOF
sudo mkinitcpio -P

# Set nvidia-drm.modeset=1 in GRUB for Wayland support
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 /' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Enable and start essential services
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now sddm

# Set Fish as the default shell
chsh -s /usr/bin/fish

# Install and configure Oh My Fish (OMF)
curl -L https://get.oh-my.fish | fish
fish -c "omf install agnoster"

# Configure Pipewire and XDG services for user session
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user start pipewire pipewire-pulse wireplumber
systemctl --user enable xdg-desktop-portal-hyprland
systemctl --user start xdg-desktop-portal-hyprland

# Create config directories
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/alacritty ~/.config/wofi ~/.config/fastfetch ~/.config/fish

# Move configuration files into place
mv ./config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
mv ./config/waybar/config ~/.config/waybar/config
mv ./config/waybar/style.css ~/.config/waybar/style.css
mv ./config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
mv ./config/wofi/config ~/.config/wofi/config
mv ./config/fastfetch/config.json ~/.config/fastfetch/config.json
mv ./config/fish/config.fish ~/.config/fish/config.fish

echo "Installation complete! Configuration files have been placed."

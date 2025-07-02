#!/bin/bash

echo "🔧 Installing system packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm git curl wget base-devel neofetch zsh htop

echo "🌐 Installing AUR helper (yay)..."
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ~

echo "🌍 Installing browsers and dev tools..."
yay -S --noconfirm google-chrome visual-studio-code-bin postman

echo "🛢️ Installing PostgreSQL..."
sudo pacman -S --noconfirm postgresql
sudo systemctl enable postgresql
sudo -iu postgres initdb --locale $LANG -D /var/lib/postgres/data
sudo systemctl start postgresql

echo "✅ Setup complete!"

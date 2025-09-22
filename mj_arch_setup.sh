#!/bin/bash

# 📦 System update & essentials
echo "🔧 Updating system and installing core packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm git curl wget base-devel neofetch zsh htop lsd bat unzip zip jq fzf ripgrep python python-pip nodejs npm zoxide starship alacritty vlc pavucontrol xfce4-taskmanager thunar-archive-plugin

# 🌐 AUR Helper (yay)
echo "🌐 Installing AUR helper (yay)..."
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay || exit 1
makepkg -si --noconfirm || exit 1
cd ~

# 🌍 Browsers & Developer Tools
echo "🌍 Installing browsers and dev tools..."
yay -S --noconfirm \
  firefox-developer-edition \
  visual-studio-code-bin

# 🛢️ Databases & Servers
echo "🛢️ Installing databases..."
sudo pacman -S --noconfirm postgresql sqlite redis

# PostgreSQL setup
echo "🛠️ Configuring PostgreSQL..."
sudo systemctl enable postgresql
sudo -iu postgres initdb --locale $LANG -D /var/lib/postgres/data
sudo systemctl start postgresql

# 🧠 Developer Essentials
echo "🧠 Installing development languages and tools..."
sudo pacman -S --noconfirm \
  docker docker-compose \
  go rustup \
  openssh \
  libvirt qemu virt-manager dnsmasq vde2 bridge-utils openbsd-netcat
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
sudo usermod -aG libvirt $(whoami)

# Rust setup
rustup install stable

# 🧪 Python AI/ML packages
echo "🤖 Installing AI/ML Python packages..."
pip install --upgrade pip
pip install numpy pandas matplotlib jupyter scikit-learn notebook

# 📥 Installing Gamani CLI & Offline Chatbot
echo "📦 Installing Gamani CLI..."
mkdir -p ~/tools/gamani
cd ~/tools/gamani || exit 1
git clone https://github.com/mj-offline/gamani-cli.git . || exit 1
chmod +x gamani

# ⌨️ Aliases for MJ CLI
echo "alias mj='~/tools/gamani/gamani'" >> ~/.zshrc
echo "alias MJ='~/tools/gamani/gamani'" >> ~/.zshrc

# 📦 Installing Offline Chatbot (GPT4All or similar)
echo "📦 Installing Offline Chatbot..."
mkdir -p ~/tools/gpt4all-chat/models
cd ~/tools/gpt4all-chat || exit 1
wget https://gpt4all.io/gpt4all-lora-quantized.bin -O models/gpt4all-lora-quantized.bin

# 🌈 Terminal customization
echo "🎨 Setting up hacker terminal..."
chsh -s $(which zsh)
mkdir -p ~/.config

yay -S --noconfirm starship zsh-autosuggestions zsh-syntax-highlighting

# 💡 Safe sourcing with checks
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

echo '[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc

echo '[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc

# 🧵 Final Touches
echo "🎉 Finalizing setup..."
echo "alias ll='lsd -lah'" >> ~/.zshrc
echo "alias cat='bat'" >> ~/.zshrc
echo "alias gs='git status'" >> ~/.zshrc
echo "alias python=python3" >> ~/.zshrc
echo "alias pip=pip3" >> ~/.zshrc
echo "export EDITOR=code" >> ~/.zshrc
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

neofetch

echo "✅ Super Optimized setup complete! Lightweight + full developer stack ready for AI, Cybersecurity & Fullstack learning."

#!/bin/bash
set -euo pipefail

SUCCESS_LIST=()
FAIL_LIST=()

install_pkg() {
local cmd="$1"
local name="$2"
echo "📦 Installing: $name ..."
if eval "$cmd"; then
SUCCESS_LIST+=("$name")
else
echo "❌ Failed: $name"
FAIL_LIST+=("$name")
fi
}

echo "🔧 Updating system..."
sudo pacman -Syu || true

# Core packages (light but essential)

install_pkg "sudo pacman -S --needed --noconfirm git curl wget base-devel neofetch zsh htop lsd bat unzip zip jq fzf ripgrep python python-pip nodejs npm zoxide starship alacritty vlc pavucontrol thunar-archive-plugin" "Core Packages"

# yay (AUR helper)

cd /tmp && rm -rf yay
install_pkg "git clone [https://aur.archlinux.org/yay.git](https://aur.archlinux.org/yay.git) && cd yay && makepkg -si --noconfirm" "yay (AUR Helper)"
cd ~

# Browser + Dev Editor (Only needed)

install_pkg "yay -S --needed --noconfirm firefox-developer-edition visual-studio-code-bin" "Firefox Dev + VSCode"

# Databases (important)

install_pkg "sudo pacman -S --needed --noconfirm postgresql sqlite redis" "Databases"
if [ ! -d /var/lib/postgres/data ]; then
sudo -iu postgres initdb --locale "$LANG" -D /var/lib/postgres/data || true
fi
sudo systemctl enable --now postgresql || true

# Developer essentials

install_pkg "sudo pacman -S --needed --noconfirm docker docker-compose go openssh libvirt qemu virt-manager dnsmasq bridge-utils" "Dev Essentials"
sudo systemctl enable --now libvirtd || true
sudo systemctl enable --now docker || true
sudo usermod -aG libvirt,docker "$(whoami)" || true

# Rust

install_pkg "curl --proto '=https' --tlsv1.2 -sSf [https://sh.rustup.rs](https://sh.rustup.rs) | sh -s -- -y && source ~/.cargo/env && rustup default stable" "Rust (rustup)"

# Python (AI safe version via pyenv)

install_pkg "sudo pacman -S --noconfirm pyenv" "pyenv"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

install_pkg "pyenv install 3.10.14 -s && pyenv global 3.10.14" "Python 3.10 (AI Safe)"
python -m pip install --upgrade pip || true
python -m pip install numpy pandas matplotlib jupyter scikit-learn notebook torch torchvision torchaudio tensorflow --index-url [https://download.pytorch.org/whl/cpu](https://download.pytorch.org/whl/cpu) || true

# Gamani CLI

mkdir -p ~/tools/gamani
if [ ! -d ~/tools/gamani/.git ]; then
install_pkg "git clone [https://github.com/mj-offline/gamani-cli.git](https://github.com/mj-offline/gamani-cli.git) ~/tools/gamani" "Gamani CLI"
fi
[ -f ~/tools/gamani/gamani ] && chmod +x ~/tools/gamani/gamani

# Aliases

grep -qxF "alias mj='~/tools/gamani/gamani'" ~/.zshrc || echo "alias mj='~/tools/gamani/gamani'" >> ~/.zshrc
grep -qxF "alias MJ='~/tools/gamani/gamani'" ~/.zshrc || echo "alias MJ='~/tools/gamani/gamani'" >> ~/.zshrc

# GPT4All (optional download placeholder)

mkdir -p ~/tools/gpt4all-chat/models

# Zsh setup

chsh -s "$(which zsh)" || true
install_pkg "yay -S --needed --noconfirm starship zsh-autosuggestions zsh-syntax-highlighting" "Zsh Plugins"

# Zsh config

grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc || echo 'eval "$(starship init zsh)"' >> ~/.zshrc
grep -qxF 'eval "$(zoxide init zsh)"' ~/.zshrc || echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

cat >> ~/.zshrc <<'EOF'
alias ll='lsd -lah'
alias cat='bat'
alias gs='git status'
alias python=python3
alias pip='python -m pip'
export EDITOR=code
EOF

neofetch || true

# Final summary

echo -e "\n🎉 INSTALLATION SUMMARY"
echo "✅ Successful Installs:"
for item in "${SUCCESS_LIST[@]}"; do
echo "   - $item"
done
if [ "${#FAIL_LIST[@]}" -gt 0 ]; then
echo -e "\n❌ Failed Installs:"
for item in "${FAIL_LIST[@]}"; do
echo "   - $item"
done
fi
echo -e "\n⚡ Done! Please reboot or re-login for changes to apply."

#!/bin/bash
set -euo pipefail

SUCCESS_LIST=()
FAIL_LIST=()

# Detect package manager
if command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --needed --noconfirm"
    UPDATE_CMD="sudo pacman -Syu"
    AUR_HELPER="yay"
elif command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update"
    AUR_HELPER=""
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD="sudo dnf update -y"
    AUR_HELPER=""
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    INSTALL_CMD="sudo yum install -y"
    UPDATE_CMD="sudo yum update -y"
    AUR_HELPER=""
elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
    INSTALL_CMD="sudo zypper install -y"
    UPDATE_CMD="sudo zypper update"
    AUR_HELPER=""
else
    echo "❌ Unsupported package manager. Exiting."
    exit 1
fi

# Map package names across distros
get_pkg_name() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)
            case "$pkg" in
                base-devel) echo "build-essential" ;;
                python) echo "python3" ;;
                python-pip) echo "python3-pip" ;;
                nodejs) echo "nodejs" ;;
                npm) echo "npm" ;;
                lsd) echo "lsd" ;; # might need snap
                zoxide) echo "zoxide" ;;
                starship) echo "starship" ;;
                alacritty) echo "alacritty" ;;
                thunar-archive-plugin) echo "thunar-archive-plugin" ;;
                postgresql) echo "postgresql" ;;
                sqlite) echo "sqlite3" ;;
                redis) echo "redis-server" ;;
                docker docker-compose) echo "docker.io docker-compose" ;;
                go) echo "golang" ;;
                openssh) echo "openssh-client" ;;
                libvirt) echo "libvirt-daemon-system" ;;
                qemu) echo "qemu-system" ;;
                virt-manager) echo "virt-manager" ;;
                dnsmasq) echo "dnsmasq" ;;
                bridge-utils) echo "bridge-utils" ;;
                pyenv) echo "pyenv" ;; # usually git clone
                *) echo "$pkg" ;;
            esac
            ;;
        dnf|yum)
            case "$pkg" in
                base-devel) echo "gcc gcc-c++ make" ;;
                python) echo "python3" ;;
                python-pip) echo "python3-pip" ;;
                lsd) echo "lsd" ;;
                *) echo "$pkg" ;;
            esac
            ;;
        *) echo "$pkg" ;;
    esac
}

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

echo "🔧 Updating system... ($PKG_MANAGER)"
eval "$UPDATE_CMD" || true

# Core packages (distro-agnostic)
CORE_PKGS="git curl wget neofetch zsh htop unzip zip jq fzf ripgrep nodejs npm zoxide alacritty vlc pavucontrol"
if [ "$PKG_MANAGER" = "pacman" ]; then
    CORE_PKGS="$CORE_PKGS lsd bat base-devel python python-pip starship thunar-archive-plugin"
elif [ "$PKG_MANAGER" = "apt" ]; then
    CORE_PKGS="$CORE_PKGS lsd bat build-essential python3 python3-pip starship thunar-archive-plugin"
else
    CORE_PKGS="$CORE_PKGS lsd bat gcc gcc-c++ make python3 python3-pip starship"
fi
install_pkg "$INSTALL_CMD $CORE_PKGS" "Core Packages"

# AUR helper (only Arch)
if [ "$PKG_MANAGER" = "pacman" ]; then
    cd /tmp && rm -rf yay
    install_pkg "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm" "yay (AUR Helper)"
    cd ~
    install_pkg "yay -S --needed --noconfirm firefox-developer-edition visual-studio-code-bin" "Firefox Dev + VSCode"
else
    # Non-Arch: install regular Firefox and VSCode from repos
    if [ "$PKG_MANAGER" = "apt" ]; then
        install_pkg "sudo apt install -y firefox code" "Firefox + VSCode"
    elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
        install_pkg "sudo dnf install -y firefox code" "Firefox + VSCode"
    else
        install_pkg "sudo zypper install -y MozillaFirefox code" "Firefox + VSCode"
    fi
fi

# Databases
install_pkg "$INSTALL_CMD postgresql sqlite redis" "Databases"
if [ "$PKG_MANAGER" = "pacman" ]; then
    if [ ! -d /var/lib/postgres/data ]; then
        sudo -iu postgres initdb --locale "$LANG" -D /var/lib/postgres/data || true
    fi
    sudo systemctl enable --now postgresql || true
elif [ "$PKG_MANAGER" = "apt" ]; then
    sudo systemctl enable --now postgresql || true
else
    sudo systemctl enable --now postgresql || true
fi

# Dev essentials
DEV_PKGS="docker docker-compose go openssh libvirt qemu virt-manager dnsmasq bridge-utils"
if [ "$PKG_MANAGER" = "apt" ]; then
    DEV_PKGS="docker.io docker-compose golang openssh-client libvirt-daemon-system qemu-system virt-manager dnsmasq bridge-utils"
fi
install_pkg "$INSTALL_CMD $DEV_PKGS" "Dev Essentials"
sudo systemctl enable --now libvirtd || true
sudo systemctl enable --now docker || true
sudo usermod -aG libvirt,docker "$(whoami)" || true

# Rust
install_pkg "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source ~/.cargo/env && rustup default stable" "Rust (rustup)"

# Python via pyenv
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
fi
install_pkg "git clone https://github.com/pyenv/pyenv.git ~/.pyenv || true" "pyenv"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
install_pkg "pyenv install 3.10.14 -s && pyenv global 3.10.14" "Python 3.10 (AI Safe)"
python -m pip install --upgrade pip || true
python -m pip install numpy pandas matplotlib jupyter scikit-learn notebook torch torchvision torchaudio tensorflow --index-url https://download.pytorch.org/whl/cpu || true

# Gamani CLI
mkdir -p ~/tools/gamani
if [ ! -d ~/tools/gamani/.git ]; then
    install_pkg "git clone https://github.com/mj-offline/gamani-cli.git ~/tools/gamani" "Gamani CLI"
fi
[ -f ~/tools/gamani/gamani ] && chmod +x ~/tools/gamani/gamani

# Aliases
grep -qxF "alias mj='~/tools/gamani/gamani'" ~/.zshrc || echo "alias mj='~/tools/gamani/gamani'" >> ~/.zshrc
grep -qxF "alias MJ='~/tools/gamani/gamani'" ~/.zshrc || echo "alias MJ='~/tools/gamani/gamani'" >> ~/.zshrc

# Zsh setup
chsh -s "$(which zsh)" || true
if [ "$PKG_MANAGER" = "pacman" ]; then
    install_pkg "yay -S --needed --noconfirm starship zsh-autosuggestions zsh-syntax-highlighting" "Zsh Plugins"
else
    if [ "$PKG_MANAGER" = "apt" ]; then
        install_pkg "sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting" "Zsh Plugins"
    elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
        install_pkg "sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting" "Zsh Plugins"
    fi
fi

# Zsh config
grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc || echo 'eval "$(starship init zsh)"' >> ~/.zshrc
grep -qxF 'eval "$(zoxide init zsh)"' ~/.zshrc || echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc

cat >> ~/.zshrc <<'EOF'
alias ll='ls -lah'
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

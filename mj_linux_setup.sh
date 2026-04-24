#!/bin/bash


SUCCESS_LIST=()
FAIL_LIST=()

# ── Colors for pretty output ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error()   { echo -e "${RED}❌ $1${NC}"; }

# ── Safety check: do NOT run as root ─────────────────────────────────────────
if [ "$EUID" -eq 0 ]; then
    log_error "Do NOT run this script as root or with sudo."
    log_error "Run it as a normal user: bash setup.sh"
    exit 1
fi

# ── Detect package manager ────────────────────────────────────────────────────
if command -v pacman &>/dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --needed --noconfirm"
    UPDATE_CMD="sudo pacman -Syu --noconfirm"
elif command -v apt &>/dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt install -y"
    UPDATE_CMD="sudo apt update && sudo apt upgrade -y"
elif command -v dnf &>/dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    UPDATE_CMD="sudo dnf update -y"
elif command -v yum &>/dev/null; then
    PKG_MANAGER="yum"
    INSTALL_CMD="sudo yum install -y"
    UPDATE_CMD="sudo yum update -y"
elif command -v zypper &>/dev/null; then
    PKG_MANAGER="zypper"
    INSTALL_CMD="sudo zypper install -y"
    UPDATE_CMD="sudo zypper update -y"
else
    log_error "Unsupported package manager. Exiting."
    exit 1
fi

log_info "Detected package manager: $PKG_MANAGER"

# =============================================================================
# FIX #2: install_pkg now installs ONE package at a time for accurate tracking
# =============================================================================
install_pkg() {
    local pkg_cmd="$1"
    local display_name="$2"
    echo ""
    log_info "Installing: $display_name ..."
    if eval "$pkg_cmd" &>/dev/null; then
        log_success "Installed: $display_name"
        SUCCESS_LIST+=("$display_name")
    else
        log_error "Failed: $display_name"
        FAIL_LIST+=("$display_name")
    fi
}

# Install a list of packages individually for accurate success/fail tracking
install_pkg_list() {
    local pkg_list=("$@")
    for pkg in "${pkg_list[@]}"; do
        local mapped
        mapped=$(get_pkg_name "$pkg")
        install_pkg "$INSTALL_CMD $mapped" "$pkg"
    done
}

# ── Map package names across distros ─────────────────────────────────────────
get_pkg_name() {
    local pkg="$1"
    case "$PKG_MANAGER" in
        apt)
            case "$pkg" in
                base-devel)              echo "build-essential" ;;
                python)                  echo "python3" ;;
                python-pip)              echo "python3-pip" ;;
                lsd)                     echo "lsd" ;;
                zoxide)                  echo "zoxide" ;;
                starship)                echo "starship" ;;
                alacritty)               echo "alacritty" ;;
                thunar-archive-plugin)   echo "thunar-archive-plugin" ;;
                postgresql)              echo "postgresql" ;;
                sqlite)                  echo "sqlite3" ;;
                redis)                   echo "redis-server" ;;
                docker)                  echo "docker.io" ;;
                docker-compose)          echo "docker-compose" ;;
                go)                      echo "golang" ;;
                openssh)                 echo "openssh-client" ;;
                libvirt)                 echo "libvirt-daemon-system" ;;
                qemu)                    echo "qemu-system" ;;
                *)                       echo "$pkg" ;;
            esac
            ;;
        dnf|yum)
            case "$pkg" in
                base-devel)              echo "gcc gcc-c++ make" ;;
                python)                  echo "python3" ;;
                python-pip)              echo "python3-pip" ;;
                sqlite)                  echo "sqlite" ;;
                redis)                   echo "redis" ;;
                docker)                  echo "docker" ;;
                go)                      echo "golang" ;;
                *)                       echo "$pkg" ;;
            esac
            ;;
        *) echo "$pkg" ;;
    esac
}

# =============================================================================
# STEP 1 — System Update
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 1: Updating system ($PKG_MANAGER)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if eval "$UPDATE_CMD"; then
    log_success "System updated."
else
    log_warn "System update had issues. Continuing anyway..."
fi

# =============================================================================
# STEP 2 — Core Packages (installed one by one for accurate tracking)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 2: Installing Core Packages..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

COMMON_PKGS=(git curl wget neofetch zsh htop unzip zip jq fzf ripgrep nodejs npm zoxide alacritty vlc pavucontrol bat lsd)

if [ "$PKG_MANAGER" = "pacman" ]; then
    DISTRO_PKGS=(base-devel python python-pip starship thunar-archive-plugin)
elif [ "$PKG_MANAGER" = "apt" ]; then
    DISTRO_PKGS=(base-devel python python-pip starship thunar-archive-plugin)
else
    DISTRO_PKGS=(base-devel python python-pip starship)
fi

install_pkg_list "${COMMON_PKGS[@]}" "${DISTRO_PKGS[@]}"

# =============================================================================
# STEP 3 — AUR Helper (Arch only) + Browser + VSCode
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 3: Installing Browser & Editor..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$PKG_MANAGER" = "pacman" ]; then
    # FIX #3: yay build — proper directory handling with subshell
    log_info "Installing yay (AUR Helper)..."
    if (cd /tmp && rm -rf yay && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm); then
        log_success "Installed: yay (AUR Helper)"
        SUCCESS_LIST+=("yay (AUR Helper)")
    else
        log_error "Failed: yay (AUR Helper)"
        FAIL_LIST+=("yay (AUR Helper)")
    fi
    install_pkg "yay -S --needed --noconfirm firefox-developer-edition" "Firefox Developer Edition"
    install_pkg "yay -S --needed --noconfirm visual-studio-code-bin" "VS Code"

elif [ "$PKG_MANAGER" = "apt" ]; then
    install_pkg "sudo apt install -y firefox" "Firefox"
    install_pkg "sudo apt install -y code" "VS Code"

elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
    install_pkg "sudo dnf install -y firefox" "Firefox"
    install_pkg "sudo dnf install -y code" "VS Code"

else
    install_pkg "sudo zypper install -y MozillaFirefox" "Firefox"
    install_pkg "sudo zypper install -y code" "VS Code"
fi

# =============================================================================
# STEP 4 — Databases
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 4: Installing Databases..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

install_pkg_list postgresql sqlite redis

# PostgreSQL init (Arch only needs manual initdb)
if [ "$PKG_MANAGER" = "pacman" ]; then
    if [ ! -d /var/lib/postgres/data ]; then
        log_info "Initializing PostgreSQL database..."
        sudo -iu postgres initdb --locale "$LANG" -D /var/lib/postgres/data || log_warn "PostgreSQL init failed."
    fi
fi

sudo systemctl enable --now postgresql 2>/dev/null || log_warn "Could not start PostgreSQL service."
sudo systemctl enable --now redis 2>/dev/null || \
sudo systemctl enable --now redis-server 2>/dev/null || log_warn "Could not start Redis service."

# =============================================================================
# STEP 5 — DevOps & Virtualization Tools
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 5: Installing DevOps & Virtualization Tools..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

install_pkg_list docker docker-compose go openssh libvirt qemu virt-manager dnsmasq bridge-utils

sudo systemctl enable --now libvirtd 2>/dev/null || log_warn "Could not start libvirtd."
sudo systemctl enable --now docker 2>/dev/null || log_warn "Could not start Docker."
sudo usermod -aG libvirt,docker "$(whoami)" 2>/dev/null || log_warn "Could not add user to libvirt/docker groups."

# =============================================================================
# STEP 6 — Rust (via rustup)
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 6: Installing Rust..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v rustc &>/dev/null; then
    log_warn "Rust already installed. Skipping."
    SUCCESS_LIST+=("Rust (already installed)")
else
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        source "$HOME/.cargo/env"
        rustup default stable
        log_success "Installed: Rust"
        SUCCESS_LIST+=("Rust (rustup)")
    else
        log_error "Failed: Rust"
        FAIL_LIST+=("Rust (rustup)")
    fi
fi

# =============================================================================
# STEP 7 — Python via pyenv
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 7: Installing Python 3.10 via pyenv..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Install pyenv build dependencies
if [ "$PKG_MANAGER" = "apt" ]; then
    log_info "Installing pyenv build dependencies..."
    sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev curl git libncursesw5-dev xz-utils \
        tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev 2>/dev/null || true
fi

# Install pyenv
if [ ! -d "$HOME/.pyenv" ]; then
    install_pkg "git clone https://github.com/pyenv/pyenv.git ~/.pyenv" "pyenv"
else
    log_warn "pyenv already installed. Skipping clone."
    SUCCESS_LIST+=("pyenv (already installed)")
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null || true

# Install Python 3.10.14
if pyenv versions 2>/dev/null | grep -q "3.10.14"; then
    log_warn "Python 3.10.14 already installed via pyenv."
    SUCCESS_LIST+=("Python 3.10.14 (already installed)")
else
    install_pkg "pyenv install 3.10.14" "Python 3.10.14"
fi

pyenv global 3.10.14 2>/dev/null || log_warn "Could not set Python 3.10.14 as global."

# Upgrade pip
python -m pip install --upgrade pip 2>/dev/null || true

# FIX #4: Install PyTorch and TensorFlow SEPARATELY (they conflict with same --index-url)
log_info "Installing PyTorch (CPU)..."
if python -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu; then
    log_success "Installed: PyTorch (CPU)"
    SUCCESS_LIST+=("PyTorch (CPU)")
else
    log_error "Failed: PyTorch"
    FAIL_LIST+=("PyTorch")
fi

log_info "Installing TensorFlow..."
if python -m pip install tensorflow; then
    log_success "Installed: TensorFlow"
    SUCCESS_LIST+=("TensorFlow")
else
    log_error "Failed: TensorFlow"
    FAIL_LIST+=("TensorFlow")
fi

log_info "Installing other ML/Data libraries..."
if python -m pip install numpy pandas matplotlib jupyter scikit-learn notebook; then
    log_success "Installed: ML Libraries (numpy, pandas, matplotlib, jupyter, scikit-learn)"
    SUCCESS_LIST+=("ML Libraries")
else
    log_error "Failed: ML Libraries"
    FAIL_LIST+=("ML Libraries")
fi

# =============================================================================
# STEP 8 — Gamani CLI
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 8: Installing Gamani CLI..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

mkdir -p ~/tools/gamani

if [ ! -d ~/tools/gamani/.git ]; then
    # FIX #5: Warn user if repo is private/unavailable
    if git clone https://github.com/mj-offline/gamani-cli.git ~/tools/gamani 2>/dev/null; then
        log_success "Installed: Gamani CLI"
        SUCCESS_LIST+=("Gamani CLI")
    else
        log_warn "Could not clone Gamani CLI — repo may be private or unavailable."
        log_warn "Skipping Gamani CLI. Add it manually later."
        FAIL_LIST+=("Gamani CLI (repo unavailable)")
    fi
else
    log_warn "Gamani CLI already cloned. Pulling latest..."
    git -C ~/tools/gamani pull 2>/dev/null || true
    SUCCESS_LIST+=("Gamani CLI (already installed)")
fi

[ -f ~/tools/gamani/gamani ] && chmod +x ~/tools/gamani/gamani

# =============================================================================
# STEP 9 — Zsh Setup & Shell Configuration
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log_info "STEP 9: Setting up Zsh & Shell Config..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

chsh -s "$(which zsh)" 2>/dev/null || log_warn "Could not change default shell to zsh."

if [ "$PKG_MANAGER" = "pacman" ]; then
    install_pkg "yay -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting" "Zsh Plugins"
elif [ "$PKG_MANAGER" = "apt" ]; then
    install_pkg "sudo apt install -y zsh-autosuggestions zsh-syntax-highlighting" "Zsh Plugins"
elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
    install_pkg "sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting" "Zsh Plugins"
else
    log_warn "Zsh plugins not available for your distro. Install manually."
fi

# ── Write ~/.zshrc additions ──────────────────────────────────────────────────
ZSHRC="$HOME/.zshrc"

add_to_zshrc() {
    local line="$1"
    grep -qxF "$line" "$ZSHRC" 2>/dev/null || echo "$line" >> "$ZSHRC"
}

# pyenv
add_to_zshrc 'export PYENV_ROOT="$HOME/.pyenv"'
add_to_zshrc 'export PATH="$PYENV_ROOT/bin:$PATH"'
add_to_zshrc 'eval "$(pyenv init -)"'

# Rust
add_to_zshrc 'source "$HOME/.cargo/env" 2>/dev/null || true'

# Starship & zoxide
add_to_zshrc 'eval "$(starship init zsh)"'
add_to_zshrc 'eval "$(zoxide init zsh)"'

# Gamani CLI aliases
add_to_zshrc "alias mj='~/tools/gamani/gamani'"
add_to_zshrc "alias MJ='~/tools/gamani/gamani'"

# Common aliases
add_to_zshrc "alias ll='ls -lah'"
add_to_zshrc "alias gs='git status'"
add_to_zshrc "alias python=python3"
add_to_zshrc "alias pip='python -m pip'"
add_to_zshrc "export EDITOR=code"

log_success "Zsh configuration written to ~/.zshrc"

# =============================================================================
# STEP 10 — Neofetch (show system info)
# =============================================================================
echo ""
neofetch 2>/dev/null || true

# =============================================================================
# FINAL SUMMARY
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 INSTALLATION COMPLETE — SUMMARY${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo -e "${GREEN}✅ Successful Installs (${#SUCCESS_LIST[@]}):${NC}"
for item in "${SUCCESS_LIST[@]}"; do
    echo "   ✔ $item"
done

if [ "${#FAIL_LIST[@]}" -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Failed Installs (${#FAIL_LIST[@]}):${NC}"
    for item in "${FAIL_LIST[@]}"; do
        echo "   ✘ $item"
    done
    echo ""
    log_warn "Some packages failed. Check errors above and install manually."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}⚡ Please REBOOT or RE-LOGIN for all changes to take effect!${NC}"
echo -e "${BLUE}   Run: sudo reboot${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 🚀 Arch Linux Auto Setup Script

Ye script tumhare Arch Linux system ko ek complete **development environment** bana deta hai. Sab kuch ek hi command se install ho jata hai: backend tools, databases, AI/ML setup, aur lightweight dev utilities.

---

## 📦 Install Hone Wali Cheezen

### 🔧 Core Packages

* git, curl, wget, base-devel
* neofetch, zsh, htop
* lsd (better ls), bat (better cat)
* unzip, zip, jq, fzf, ripgrep
* python, python-pip
* nodejs, npm
* zoxide, starship (prompt)
* alacritty (terminal)
* vlc, pavucontrol (sound)
* thunar-archive-plugin

### 📦 AUR Helper

* yay

### 🌐 Browser / Editor

* Firefox Developer Edition
* Visual Studio Code (bin)

### 🗄 Databases

* PostgreSQL (auto initdb setup)
* SQLite
* Redis

### 🛠 Developer Essentials

* docker, docker-compose
* go
* openssh
* libvirt, qemu, virt-manager
* dnsmasq, bridge-utils

### ⚙️ Languages & AI Tools

* Rust (rustup se)
* Python 3.10.14 (pyenv ke zariye)

  * pip upgrade
  * AI/ML libraries:

    * numpy, pandas, matplotlib
    * jupyter, scikit-learn, notebook
    * torch, torchvision, torchaudio
    * tensorflow (CPU build)

### 🧰 Custom Tools

* Gamani CLI (aliases: `mj` aur `MJ`)

### 🎨 Shell / Config

* Zsh (default shell)
* starship
* zsh-autosuggestions
* zsh-syntax-highlighting
* Aliases (`ll`, `cat`, `gs`, `python3`, `pip`)

### 🧪 Optional

* GPT4All models ke liye folder (empty placeholder)

---

## ⚡ Usage

1. Script download karo:

   ```bash
   curl -O https://raw.githubusercontent.com/JawadAbbasi14/mj-arch-setup/main/setup.sh
   ```

2. Executable banao:

   ```bash
   chmod +x setup.sh
   ```

3. Run karo:

   ```bash
   ./setup.sh
   ```

---

## ✅ Post Setup

* PostgreSQL aur Docker services enable ho jayengi
* Zsh default shell ho jayega (starship + plugins ke sath)
* Gamani CLI shortcut `mj` ready ho jayega
* AI libraries Python 3.10 par stable chalengi

---

## 🎯 Target Users

* Arch Linux Developers
* Backend (Node.js, Go, Rust, Python)
* AI/ML Developers
* Fullstack Engineers
* Terminal Power Users

---

⚡ Smooth aur clean environment — extra browsers (Chrome, Brave, etc.) hata diye gaye hain. Sirf **essential dev t

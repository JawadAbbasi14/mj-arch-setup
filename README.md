# 🚀 MJ Dev Environment Setup Script

A powerful **one-shot setup script** that automatically installs and configures a complete developer environment on any Linux distro — Arch, Ubuntu/Debian, Fedora, RHEL, or openSUSE.

---

## 📋 Table of Contents

- [What Does This Script Do?](#-what-does-this-script-do)
- [Supported Linux Distros](#-supported-linux-distros)
- [Prerequisites](#-prerequisites)
- [How to Use](#-how-to-use)
- [What Gets Installed](#-what-gets-installed)
- [After Installation](#-after-installation)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)

---

## 🤔 What Does This Script Do?

This script sets up a **full developer workstation** from scratch — automatically. No need to install things one by one. Just run it once and it handles everything:

- Detects your Linux distro and uses the right package manager
- Installs developer tools, databases, languages, and apps
- Sets up Zsh with a beautiful prompt (Starship)
- Configures Python (via pyenv), Rust, Node.js, and Go
- Sets up Docker, VMs (libvirt/QEMU), and databases
- Adds helpful aliases and shell configurations

---

## 🐧 Supported Linux Distros

| Distro | Package Manager | Status |
|--------|----------------|--------|
| Arch Linux / Manjaro | `pacman` + `yay` | ✅ Full Support |
| Ubuntu / Debian / Mint | `apt` | ✅ Full Support |
| Fedora | `dnf` | ✅ Full Support |
| RHEL / CentOS | `yum` | ✅ Full Support |
| openSUSE | `zypper` | ✅ Full Support |

---

## ✅ Prerequisites

Before running the script, make sure you have:

- [ ] A working internet connection
- [ ] `sudo` (admin) access on your system
- [ ] `git` installed — if not, install it first:
  ```bash
  # Ubuntu/Debian
  sudo apt install git -y

  # Arch
  sudo pacman -S git

  # Fedora
  sudo dnf install git -y
  ```
- [ ] `bash` shell (already available on all Linux systems)

---

## 🛠️ How to Use

### Step 1 — Download the Script

```bash
git clone https://github.com/mj-offline/gamani-cli.git
cd gamani-cli
```

> Or if you already have the script file, just navigate to its folder.

### Step 2 — Make It Executable

```bash
chmod +x setup.sh
```

### Step 3 — Run the Script

```bash
bash setup.sh
```

> ⚠️ **Do NOT run as root (`sudo bash setup.sh`).** The script will ask for sudo when needed internally.

### Step 4 — Wait for It to Finish

The script will show live progress like this:

```
🔧 Updating system... (pacman)
📦 Installing: Core Packages ...
📦 Installing: yay (AUR Helper) ...
📦 Installing: Rust (rustup) ...
...
🎉 INSTALLATION SUMMARY
✅ Successful Installs:
   - Core Packages
   - Databases
   - Dev Essentials
   ...
⚡ Done! Please reboot or re-login for changes to apply.
```

### Step 5 — Reboot

```bash
reboot
```

After reboot, open your terminal — it should look amazing with Starship prompt! ✨

---

## 📦 What Gets Installed

### 🧰 Core Tools
| Tool | Purpose |
|------|---------|
| `git` | Version control |
| `curl` / `wget` | Download files from terminal |
| `zsh` | Modern shell (replaces bash) |
| `fzf` | Fuzzy file finder |
| `ripgrep` | Super fast search |
| `htop` | System monitor |
| `jq` | JSON processor |
| `bat` | Better `cat` with syntax highlighting |
| `lsd` | Better `ls` with icons |
| `zoxide` | Smarter `cd` command |
| `neofetch` | Show system info |

### 🌐 Apps
| App | Purpose |
|-----|---------|
| Firefox / Firefox Dev Edition | Web browser |
| VS Code | Code editor |
| Alacritty | Fast terminal emulator |
| VLC | Media player |
| Thunar + Archive Plugin | File manager |

### 💾 Databases
| Database | Purpose |
|----------|---------|
| PostgreSQL | Relational database |
| SQLite | Lightweight database |
| Redis | In-memory cache/DB |

### 👨‍💻 Programming Languages
| Language | How Installed |
|----------|--------------|
| Python 3.10 | via `pyenv` (with AI/ML libraries) |
| Node.js + npm | via package manager |
| Go (Golang) | via package manager |
| Rust | via `rustup` |

### 🤖 Python AI/ML Libraries (auto-installed)
- `numpy`, `pandas`, `matplotlib`
- `scikit-learn`, `jupyter`, `notebook`
- `torch`, `torchvision`, `torchaudio` (CPU)
- `tensorflow`

### 🐳 DevOps & Virtualization
| Tool | Purpose |
|------|---------|
| Docker + docker-compose | Containers |
| libvirt + QEMU | Virtual machines |
| virt-manager | VM GUI |
| dnsmasq + bridge-utils | Networking for VMs |

### 🐚 Zsh Setup
- **Starship** — beautiful, fast prompt
- **zsh-autosuggestions** — suggests commands as you type
- **zsh-syntax-highlighting** — colors valid/invalid commands

### ⚡ Shell Aliases Added
```bash
alias ll='ls -lah'         # Detailed file list
alias gs='git status'      # Quick git status
alias python=python3        # Always use python3
alias pip='python -m pip'  # Correct pip usage
alias mj='~/tools/gamani/gamani'   # Gamani CLI
alias MJ='~/tools/gamani/gamani'   # Gamani CLI (caps)
```

---

## 🔁 After Installation

Once rebooted, verify everything is working:

```bash
# Check Python version
python --version

# Check Node.js
node --version

# Check Rust
rustc --version

# Check Docker
docker --version

# Check Go
go version

# Check databases
psql --version
redis-cli --version

# Launch Jupyter Notebook
jupyter notebook

# Use Gamani CLI
mj
```

---

## 🔧 Troubleshooting

### ❌ "Unsupported package manager"
Your distro is not supported. Check the [Supported Distros](#-supported-linux-distros) list.

### ❌ A package failed to install
At the end of the script, failed packages are listed under `❌ Failed Installs`. You can install them manually:
```bash
# Example: manually install a failed package
sudo apt install <package-name> -y   # Ubuntu
sudo pacman -S <package-name>        # Arch
sudo dnf install <package-name> -y  # Fedora
```

### ❌ Docker/libvirt not working after reboot
Your user needs to be in the right groups. Run:
```bash
sudo usermod -aG docker,libvirt $USER
# Then log out and log back in
```

### ❌ `mj` command not found
Run this to reload your shell config:
```bash
source ~/.zshrc
```

### ❌ Python version still shows old version
```bash
pyenv global 3.10.14
source ~/.zshrc
python --version
```

---

## ❓ FAQ

**Q: Can I run this on a fresh install?**
Yes! That's exactly what it's designed for.

**Q: Will it break my existing setup?**
It uses `--needed` / `-y` flags and skips already-installed packages. It's generally safe, but a backup is always a good idea.

**Q: How long does it take?**
Depending on your internet speed: **15–45 minutes**.

**Q: Can I re-run it?**
Yes. The script is idempotent — it skips things already installed.

**Q: What is Gamani CLI (`mj`)?**
A custom CLI tool by the author, cloned from `github.com/mj-offline/gamani-cli`.

---

## 👤 Author

Made with ❤️ by **MJ**
GitHub: [mj-offline](https://github.com/mj-offline)

---

## 📄 License

This project is open source. Use it, modify it, share it freely.

---

> 💡 **Tip:** After setup, open a new terminal window to see your new Zsh + Starship prompt in action!

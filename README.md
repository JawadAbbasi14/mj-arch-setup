# Arch Linux Auto Setup Script (mj-arch)

This script automates the installation of a complete development environment on **Arch Linux**.

---

## 🚀 Quick Start (One Command Install)

Next time you want to set up, you only need to run **one command**:

```bash
curl -L https://raw.githubusercontent.com/JawadAbbasi14/mj-arch-setup/main/mj_arch_setup.sh -o mj_arch_setup.sh && chmod +x mj_arch_setup.sh && ./mj_arch_setup.sh
```

That’s it ✅

---

## 📦 What this script installs

* **Core Packages**: git, curl, wget, base-devel, zsh, neofetch, htop, etc.
* **AUR Helper**: yay
* **Browser & Editor**: Firefox Developer Edition, Visual Studio Code
* **Databases**: PostgreSQL, SQLite, Redis
* **Developer Essentials**: Docker, libvirt, QEMU, Go, OpenSSH, etc.
* **Languages/Tools**: Rust (via rustup), Python (via pyenv with AI/ML libraries)
* **AI/ML Libraries**: numpy, pandas, matplotlib, jupyter, scikit-learn, PyTorch, TensorFlow
* **Custom Tools**: Gamani CLI
* **Shell Setup**: zsh with starship prompt, plugins, aliases
* **Optional**: GPT4All folder for offline models

---

## 🔧 Post-Setup

After the script finishes:

1. PostgreSQL, Docker, and libvirt services will be enabled.
2. Zsh will be configured with plugins and starship prompt.
3. AI/ML Python environment (3.10 via pyenv) will be ready.
4. Firefox Developer Edition and VSCode available in the menu.

---

## 👤 Target Users

* Arch developers
* Backend engineers
* AI/ML coders
* Fullstack learners
* Terminal power users

---

### ⚡ Notes

* Script may take time depending on your internet speed.
* If any package fails, re-run the script; it will skip already installed ones.
* Repo: [mj-arch-setup](https://github.com/JawadAbbasi14/mj-arch-setup)

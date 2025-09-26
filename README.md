# 🚀 MJ Arch Auto Setup Script

Ye script ek **full Arch Linux auto-setup** hai jo tumhare liye sab essential tools, dev languages, databases, aur AI/ML libraries install aur configure kar dega. Sirf ek command run karo aur tumhara Arch environment hacker-style ready ho jayega 🔥

---

## 🛠️ What It Installs

### 🖥️ System Utilities

* `git`, `curl`, `wget`, `base-devel`, `htop`, `zsh`, `neofetch`, `lsd`, `bat`, `jq`, `fzf`, `ripgrep`, `unzip`, `zip`, `zoxide`, `starship`

### 🌐 AUR Helper

* `yay` (Arch User Repository ke liye, auto install hota hai)

### 🌍 Browsers & Dev Tools

* `Google Chrome`
* `Brave Browser`
* `Firefox Developer Edition`
* `Visual Studio Code (bin)`
* `Postman`
* `Insomnia`

### 🛢️ Databases

* `PostgreSQL` (auto init + service enabled)
* `MariaDB`
* `SQLite`
* `Redis`

### 💻 Development Languages & Tools

* **Python 3.10 + pip** (AI/ML models ke liye best LTS version, TensorFlow & PyTorch supported)
* `Node.js` + `npm`
* `Rust` (via rustup, latest stable)
* `Go`
* `Docker` + `Docker Compose` (enabled & added to user group)
* `libvirt`, `qemu`, `virt-manager` (VMs ke liye)

### 🤖 AI / ML Python Packages (User-level, not system-wide)

* `numpy`
* `pandas`
* `matplotlib`
* `scikit-learn`
* `notebook`
* `jupyter`

### 🛠️ Offline Dev Tools

* **Gamani CLI** (custom tool, alias `mj` / `MJ`)
* **GPT4All (offline chatbot)** with local model folder ready

### 💻 Terminal Customization

* ZSH default shell
* `starship` hacker prompt
* `zsh-autosuggestions`, `zsh-syntax-highlighting`
* Custom aliases (`ll`, `cat`, `gs`, `python`, `pip`)

---

## ⚙️ How to Use (Only 3 Steps!)

### 1️⃣ Download the script

```bash
curl -O https://raw.githubusercontent.com/JawadAbbasi14/mj-arch-setup/main/mj_arch_setup.sh
```

### 2️⃣ Make the script executable

```bash
chmod +x mj_arch_setup.sh
```

### 3️⃣ Run the script

```bash
./mj_arch_setup.sh
```

---

## ✅ After Setup

* Run `mj` or `MJ` in terminal to launch **Gamani CLI** 🟢
* PostgreSQL aur MariaDB auto-enabled services ke sath ready honge 🔄
* Python 3.10 ke sath **AI/ML ready environment** milega (PyTorch / TensorFlow supported) 🧠
* Hacker terminal enabled with:

  * `starship` hacker prompt
  * `neofetch`
  * `autosuggestions`
  * `syntax highlighting`
* Offline chatbot model path: `~/tools/gpt4all-chat/models/`

---

### 🧠 Perfect For:

* Arch Linux developers
* AI/ML coders (TensorFlow, PyTorch, Jupyter)
* Full-stack devs (Databases + Docker + Node + Go + Rust)
* Terminal hackers who love customization

> Made with 💥 by MJ (for a blazing-fast Arch Dev Experience)

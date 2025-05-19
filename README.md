<h1 align="center" > 🚀 MintDev Setup Script</h1>

<p align="center">
 <img src="assets/logo.png" alt="MintDev Setup Logo" width="200" />
</p>

<h3 align="center">
 Your Development Environment Ready in Linux Mint Cinnamon
</h3>

<h5 align="center">
 An automated tool to quickly set up a professional development environment.
</h5>

---

## ✨ What is MintDev Setup?

MintDev Setup is a script that automates the installation and configuration of the most common and useful tools for developers in Linux Mint Cinnamon. Forget about installing and configuring everything manually; with just one command, you'll have your environment ready to start coding.

This project is inspired by the popular setup [Omakub](https://github.com/basecamp/omakub), specifically adapted for Linux Mint.

## 📝 Requirements

* **Operating System:** Linux Mint 22.1 Cinnamon (other versions may work, but 22.1 is tested).
* **Architecture:** 64-bit (x86_64).
* **Internet Connection:** Required to download packages and files.
* **Disk Space:** Minimum 5GB free.
* **RAM:** Minimum 4GB.
* **Privileges:** A user with `sudo` permissions.

The script will automatically install basic dependencies like `git`, `curl`, `wget`, `unzip`, `jq`, etc.

## 🚀 Quick Installation

The easiest way to install MintDev Setup is using the bootstrap script with `wget` and `sudo bash`.

**Important!** This command will download the startup script and run it with admin privileges to install software on your system. Review the code if you have doubts.

1.  Open a terminal in your Linux Mint.
2.  Copy and paste the following command and press Enter:

   ```bash
   wget -O - https://raw.githubusercontent.com/kalashbg-dev/mintdev/main/bootstrap.sh | bash
   ```

3.  The script will start the process. You'll be asked for your `sudo` password and then you can select which specific components you want to install through an interactive menu.

## 🛠️ Included Components

MintDev Setup offers a wide selection of tools for a complete development environment, which you can choose to install:

* **Terminal Tools:** Zsh (with Oh My Zsh), Alacritty, Tmux, Starship (prompt), Micro (editor), Bat, Ranger (file explorer), Neofetch.
* **General Development:** Python, Node.js (with NVM), Docker, GitHub CLI, Rust, Zellij (terminal multiplexer).
* **Databases:** PostgreSQL, MongoDB.
* **Desktop Applications:** VS Code (Code Editor), Spotify, LibreOffice.
* **Communication:** Slack, Telegram, Discord, WhatsApp.
* **API Tools:** Postman, Insomnia.
* **Monitoring and Customization:** Conky (system monitor), Plank (dock), Ulauncher (launcher), Variety (wallpapers).
* **Basic Security:** UFW (Firewall), ClamAV (Antivirus), Fail2ban.
* **Virtualization:** VirtualBox, QEMU/KVM.

*(The exact selection may depend on the specific scripts in the `install/` folder of this repository.)*

## 🎨 Theme Management

The setup includes a theme management system that allows applying a consistent visual style to several compatible applications (Alacritty, VS Code, Starship, Tmux, Conky).

During installation, you can choose your preferred theme among options like:

* Tokyo Night
* Catppuccin
* Nord
* Gruvbox
* Dracula
* Everforest
* Kanagawa
* Rosé Pine

You can see the available themes in the `themes/index.json` file of the repository.

## 🔄 Idempotency and Logging

The script is designed to be *idempotent*. This means you can run it multiple times without fear of reinstalling things you already have. The system will detect already installed components and skip them.

All operations are logged in log files located in `$HOME/.mintdev/logs/` so you can review the process in detail if needed.

## 💡 Advanced Customization

If you want to customize further, the modified configuration files are in your standard directories (`~/.config/`, `~/.zshrc`, `~/.tmux.conf`, etc.). You're free to adjust them to your liking.

## 🗑️ Uninstallation

(If you provide an `uninstall.sh` script)

You can uninstall specific components by running the uninstall script in the cloned repository:

```bash
~/.local/share/mint-dev-setup/uninstall.sh
```

This script will present you with a menu to select which components you want to remove.

## 👋 Contributing

Contributions are welcome! If you find a bug, have a suggestion, or want to add support for another application/functionality:

Fork the repository.
Clone your fork.
Create a new branch for your changes.
Implement your improvements (check the file structure in the Developer Guide section - if you have that file).
Commit, push to your fork, and open a Pull Request to the original repository.

## 📄 License

This project is under the [MIT License](LICENSE). Check it for more details.

We hope you enjoy using MintDev Setup. Happy coding!

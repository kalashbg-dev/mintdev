# MintDev Audit & Modernization Plan (Inspired by Omakub)

This document outlines the analysis performed on the upstream [Omakub](https://github.com/basecamp/omakub) project and the subsequent modernization plan for `mintdev` to adapt these improvements for Linux Mint Cinnamon.

## 1. Migrations System (Updating Existing Users)
**Analysis:** Omakub introduced a robust migration system (`migrations/` directory and `migrate.sh`). This allows applying fixes (like updating expired GPG keys) to users who have already installed the setup, simply by running the CLI update command.
**MintDev Plan:**
*   Implement a similar `migrations/` directory.
*   Create a `mintdev update` command that fetches the latest code and runs `.sh` scripts in `migrations/` based on timestamps.
*   Port the Spotify GPG key fix as the first migration test case.

## 2. Lightweight and Modern Terminal Ecosystem
**Analysis:** Omakub has shifted towards more modern, lightweight terminal utilities written in Rust/Go.
*   **Neofetch -> Fastfetch:** Neofetch is abandoned. Fastfetch is significantly faster and actively maintained.
*   **Language Management (Mise):** Instead of using NVM for Node, Pyenv for Python, and rbenv for Ruby, Omakub now uses `mise` (formerly `rtx`), which manages all dev tools in a single, fast rust binary.
*   **TUI Tools:** Omakub includes tools like `btop` (instead of htop), `lazygit`, and `lazydocker`.
**MintDev Plan:**
*   Replace `neofetch.sh` with `fastfetch.sh`.
*   Replace `nodejs.sh` and `python.sh` with a unified `mise.sh` installer.
*   Add installation scripts for `btop`, `lazygit`, and `lazydocker`.

## 3. Global CLI (`mintdev`) and TUI Menus
**Analysis:** Omakub uses a global executable `omakub` that leverages `gum` (from Charmbracelet) to render beautiful terminal UIs for changing themes, running updates, and managing optional apps.
**MintDev Plan:**
*   Ensure `gum` is installed globally.
*   Create a `bin/mintdev` executable script added to the user's PATH (e.g., in `~/.local/bin/`).
*   Implement `bin/mintdev-sub/` scripts (menu, theme picker, update mechanism) using `gum` for a polished Mint-native experience.

## 4. Theme Management & Cinnamon Integration
**Analysis:** Omakub frequently adds new themes (e.g., `osaka-jade`, `matte-black`, `ristretto`) and updates their configs across Alacritty, Neovim, Zellij, and GNOME.
**MintDev Plan:**
*   Sync `themes/index.json` with the latest themes from Omakub.
*   **Cinnamon Native Integration:** Modify `lib/theme-manager.sh` to not only update Alacritty/VS Code but also dynamically update the Cinnamon Desktop Accent colors (e.g., `Mint-Y-Dark-Teal` for green themes, `Mint-Y-Dark-Pink` for Dracula). This ensures the desktop feels cohesive with the terminal theme.
*   Ensure all new theme configurations are available in the `themes/` directory structure.

## 5. Optional Apps
**Analysis:** Omakub supports optional apps like Discord, Brave, Cursor/Windsurf, and Ollama.
**MintDev Plan:**
*   Add installers for these tools inside an `install/optional/` directory.
*   Make them installable via the `mintdev` interactive menu.

---

**Approval:** This audit and plan were discussed and approved by the user. The primary focus remains on maintaining high compatibility with Linux Mint Cinnamon while adopting the "lightweight" and modern philosophy of recent Omakub releases.

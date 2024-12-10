## ⚡️ Requirements
- [Neovim](https://neovim.io/)
  ```sh
  brew install neovivm
  ```
- [GIT](https://git-scm.com/)
  ```sh
  brew install git
  ```
- [Nerd Font](https://www.nerdfonts.com)
- a **C** compiler for `nvim-treesitter`. See [here](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
    ```sh
    brew install make
    ```
## ⚡️ Optional

## 🚀 Getting Started
- Backup or delete your current configuration
  *Delete Current Configuration*
  ```sh
    rm -rf ~/.config/nvim ~/.cache/nvim ~/.local/share/nvim ~/.local/state/nvim
  ```
  *Backup Current Configuration*
    ```sh
    mv ~/.config/nvim{,.bak}
    mv ~/.local/share/nvim{,.bak}
    mv ~/.local/state/nvim{,.bak}
    mv ~/.cache/nvim{,.bak}
    ```
- Clone the code

  ```sh
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  ```
- Start Neovim!

  ```sh
  nvim
  ```

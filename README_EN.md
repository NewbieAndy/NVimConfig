# NVimConfig | Neovim Configuration (Linux Server Edition)

A lightweight Neovim configuration optimized for low-spec Linux servers. LSP, AI assistants, debugger, and macOS-specific features have been removed. What remains: syntax highlighting, file management, Git integration, fuzzy search, and formatting — everything you need for productive server-side editing.

- Audience: developers editing code on Linux servers (2 cores / 2 GB RAM and above)
- Requirements: Neovim >= 0.9, Git, a C compiler (for treesitter)

## ✨ Features
- Performance & UI: lazy-loaded plugins, tokyonight theme, lualine, bufferline
- Syntax Highlighting: nvim-treesitter with server-essential parsers only (bash, python, lua, yaml, json, dockerfile, sql, etc.)
- Formatting: conform.nvim (manual trigger, no background scanning)
- Files & Search: neo-tree file explorer, grug-far search & replace, Snacks.picker fuzzy finder
- Git: gitsigns inline diff markers
- Sessions & Utils: persistence, which-key, todo-comments
- Terminal: Snacks.terminal floating terminal

> **Removed from this config:** LSP / auto-completion / AI Copilot / DAP debugger / neotest / noice UI / macOS-specific features

## 📦 Installing Dependencies on a Linux Server

### 1. Install Neovim (>= 0.9)

**Option A: Pre-built binary (recommended)**
```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
# Add to PATH in ~/.bashrc or ~/.zshrc
echo 'export PATH="/opt/nvim-linux-x86_64/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Option B: Package manager (may be older)**
```sh
# Ubuntu/Debian — add PPA for a recent version
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update && sudo apt install -y neovim

# CentOS/RHEL
sudo yum install -y neovim
```

### 2. Required tools
```sh
# Ubuntu/Debian
sudo apt install -y git gcc make ripgrep

# CentOS/RHEL
sudo yum install -y git gcc make ripgrep
```

### 3. Optional tools
```sh
# fd — faster file finder used by the picker
sudo apt install -y fd-find && ln -sf $(which fdfind) ~/.local/bin/fd
```

## 🚀 Getting Started

### 1. Back up / remove old config
```sh
mv ~/.config/nvim{,.bak} 2>/dev/null
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

### 2. Clone
```sh
git clone -b linux_server https://github.com/NewbieAndy/NVimConfig.git ~/.config/nvim
```

### 3. First launch — plugins install automatically
```sh
nvim
```
On the first start, lazy.nvim downloads and installs all plugins (needs network, ~1–3 min). Restart nvim once the install completes.

> **Tip:** Make sure your terminal connection supports 256-color or TrueColor. Using tmux with a TrueColor-capable terminal is recommended.

### 4. Verify TreeSitter parsers
```
:TSInstall bash python lua yaml json
```
Or just `:Lazy sync` to trigger auto-install.

### 5. (Optional) Install formatters
conform.nvim calls system-installed formatters — install only what you need:
```sh
pip install black isort      # Python
npm install -g prettier      # JS/JSON/YAML/Markdown
cargo install stylua         # Lua
sudo apt install -y shfmt    # Shell
```

## ⌨️ Keymaps (Leader = `<Space>`)

| Action | Key |
|--------|-----|
| Toggle file tree | `<leader>e` / `<C-e>` |
| Find file | `<leader><space>` |
| Global search | `<leader>/` |
| Search & replace | `<leader>fr` |
| Floating terminal | `<C-/>` |
| Format file | `<leader>cf` |
| Git blame | `<leader>gb` |
| Next / prev buffer | `<S-l>` / `<S-h>` |
| Close buffer | `<leader>bd` |
| Split horizontal / vertical | `<leader>-` / `<leader>\|` |
| Move between windows | `<leader>h/j/k/l` |
| Open Lazy | `<leader>L` |
| Which-key hints | `<leader>` (wait briefly) |

## 🧱 Layout
```
~/.config/nvim/
├── init.lua              # Entry point (lazy.nvim bootstrap)
├── lazy-lock.json        # Plugin version lock
└── lua/
    ├── config/           # Core settings (options/keymaps/autocmds)
    ├── plugins/          # Plugin specs (one file per plugin/group)
    ├── utils/            # Shared utilities (root detection, UI helpers, etc.)
    └── types.lua         # Type definitions
```

## 🛠 Customizing
- Theme: edit `lua/plugins/colorscheme.lua` (default: tokyonight)
- Options: edit `lua/config/options.lua`
- Keymaps: edit `lua/config/keymaps.lua`
- Add a plugin: create a new file under `lua/plugins/` returning a lazy.nvim plugin spec

## 🐞 Troubleshooting
- **Plugins not installing**: `:Lazy sync` — check server network / proxy settings
- **Treesitter errors**: make sure `gcc` and `make` are installed, then run `:TSUpdate`
- **Performance profiling**: `:Lazy profile`
- **View startup messages**: `:messages`

## 📄 License
MIT

## 🙏 Acknowledgments
Neovim community; inspired by LazyVim, NvChad, and AstroNvim.

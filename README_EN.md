# NVimConfig | Neovim configuration

A modern, batteries-included Neovim setup featuring LSP, DAP, testing, formatting, Git, AI assistants, and VSCode integration. Built on lazy.nvim with great performance and modularity.

- Audience: multi-language developers and users migrating from VSCode
- Requirements: Neovim >= 0.9, a Nerd Font, and a basic C toolchain

## ✨ Features
- Performance & UI: lazy-loaded plugins, tokyonight theme, lualine, bufferline, noice UI, Snacks statuscolumn/terminal/tools
- Language & Completion: mason(+lspconfig), nvim-lspconfig, blink.cmp, friendly-snippets
- Syntax & Editing: nvim-treesitter, ts-autotag, ts-comments, todo-comments
- Code Quality: conform.nvim (formatting), nvim-lint (linting)
- Debug & Test: nvim-dap + ui + virtual-text, dap-python, neotest (python/vitest)
- Files & Search: neo-tree file explorer, grug-far search & replace
- Git: gitsigns, integrated Snacks.lazygit
- AI: GitHub Copilot and CopilotChat
- Sessions & Utils: persistence, which-key, venv-selector
- VSCode: seamless use with VSCode Neovim extension (auto-selects vscode-config)
- macOS utility: optional auto IME switching via Hammerspoon

## 📦 Requirements
- Neovim >= 0.9.0, Git, a Nerd Font, C toolchain
- Optional: Node.js, Python, Lazygit, ripgrep, fd, Hammerspoon (macOS)

macOS example:
```sh
brew install neovim git make ripgrep fd lazygit node python
brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font
```

## 🚀 Getting Started
1) Backup or remove your old config
```sh
mv ~/.config/nvim{,.bak}; mv ~/.local/share/nvim{,.bak}; mv ~/.local/state/nvim{,.bak}; mv ~/.cache/nvim{,.bak}
# or
rm -rf ~/.config/nvim ~/.cache/nvim ~/.local/share/nvim ~/.local/state/nvim
```
2) Clone
```sh
git clone https://github.com/NewbieAndy/NVimConfig.git ~/.config/nvim
```
3) Start Neovim and wait for auto-install
```sh
nvim
```
4) (Optional) Install tools via Mason
```
:Mason
```
Suggested LSP: lua-language-server, typescript-language-server, pyright, rust-analyzer, gopls, clangd
Suggested formatters: stylua, prettier, shfmt, black

5) (Optional) Copilot login
```
:Copilot auth
```

## ⌨️ Keymaps (Leader = Space)
- Files: <leader>e or <C-e> → toggle neo-tree
- Windows: <leader>h/j/k/l move; <C-arrows> resize; <leader>- / <leader>| split; <leader>wd close
- Buffers: <S-h>/<S-l> prev/next; <leader>bd delete; <leader>bo delete others
- Search & Replace: <leader>fr grug-far
- Terminal: <C-/> floating terminal (Snacks.terminal); in terminal, <C-/> closes
- Diagnostics: <leader>cd line diag; ]d/[d next/prev; ]e/[e error; ]w/[w warn
- Git (lazygit): <leader>gg root; <leader>gG cwd; <leader>gb blame; <leader>gB browse; <leader>gh file history; <leader>gl/gL log
- Misc: <leader>L Lazy; <leader>fn new file; <leader>ft change filetype; <leader>cf format
- Common LSP: gd/gr/gi, K, <leader>ca, <leader>rn

## 🧱 Layout
```
~/.config/nvim/
├── init.lua
├── lazy-lock.json
└── lua/{config,plugins,utils,vscode-config,types.lua}
```

## 🛠 Customize
- Theme: edit lua/plugins/colorscheme.lua (default: tokyonight)
- Options: edit lua/config/options.lua
- Keymaps: edit lua/config/keymaps.lua
- Plugins: add a file under lua/plugins/ that returns your plugin spec

## 🐞 Troubleshooting
- Plugins not installing: :Lazy sync (check network/proxy)
- LSP issues: :Mason to install, :LspInfo to check, :LspRestart to restart
- Performance: :Lazy profile

## 📄 License
MIT

## 🙏 Acknowledgments
Neovim community; inspirations from LazyVim, NvChad, AstroNvim.

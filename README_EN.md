# Neovim Configuration

A modern, feature-rich Neovim configuration optimized for software development across multiple languages with LSP, debugging, testing, and AI-assisted coding capabilities.

## ✨ Features

- 🚀 **Fast Startup**: Lazy-loading plugins with optimized performance
- 🔧 **Language Support**: Full LSP integration for Python, TypeScript, JavaScript, Lua, Go, and more
- 🤖 **AI Integration**: GitHub Copilot and CopilotChat for AI-assisted coding
- 🐛 **Debugging**: Complete DAP (Debug Adapter Protocol) setup with UI
- 🧪 **Testing**: Integrated test runner with Neotest for Python and Vitest
- 🎨 **Modern UI**: Beautiful interface with Tokyo Night theme, statusline, and bufferline
- 📁 **File Management**: Neo-tree file explorer with git integration
- 🔍 **Search & Replace**: Powerful fuzzy finding with Telescope and grug-far
- 📝 **Code Formatting**: Auto-formatting with conform.nvim and linting with nvim-lint
- 🔄 **Git Integration**: Gitsigns and Lazygit for seamless version control
- 💻 **VSCode Compatible**: Optional VSCode Neovim integration

## 📦 Requirements

- [Neovim](https://neovim.io/) >= 0.9.0
  ```sh
  brew install neovim
  ```
- [Git](https://git-scm.com/)
  ```sh
  brew install git
  ```
- [Nerd Font](https://www.nerdfonts.com) - Required for icons
- **C compiler** for `nvim-treesitter`. See [requirements](https://github.com/nvim-treesitter/nvim-treesitter#requirements)
  ```sh
  brew install make
  ```

## 🌟 Optional Dependencies

- [Lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for git
  ```sh
  brew install lazygit
  ```
- [Ripgrep](https://github.com/BurntSushi/ripgrep) - Fast search tool
  ```sh
  brew install ripgrep
  ```
- [fd](https://github.com/sharkdp/fd) - Fast file finder
  ```sh
  brew install fd
  ```

## 🚀 Getting Started

### Installation

1. **Backup or delete your current configuration**

   *Delete current configuration:*
   ```sh
   rm -rf ~/.config/nvim ~/.cache/nvim ~/.local/share/nvim ~/.local/state/nvim
   ```

   *Or backup current configuration:*
   ```sh
   mv ~/.config/nvim{,.bak}
   mv ~/.local/share/nvim{,.bak}
   mv ~/.local/state/nvim{,.bak}
   mv ~/.cache/nvim{,.bak}
   ```

2. **Clone this repository**
   ```sh
   git clone https://github.com/NewbieAndy/NVimConfig.git ~/.config/nvim
   ```

3. **Start Neovim**
   ```sh
   nvim
   ```

   The plugin manager will automatically install all plugins on first launch.

## ⌨️ Key Mappings

Leader key: `<Space>`

### General

| Key | Mode | Description |
|-----|------|-------------|
| `<Space>e` | Normal | Toggle file explorer |
| `<C-e>` | Normal/Insert | Toggle file explorer |
| `<Space>ff` | Normal | Find files |
| `<Space>fg` | Normal | Live grep |
| `<Space>fb` | Normal | Find buffers |
| `<Space>fr` | Normal/Visual | Search and replace |
| `<C-/>` | Normal | Toggle terminal |

### Window Management

| Key | Mode | Description |
|-----|------|-------------|
| `<Space>h/j/k/l` | Normal | Navigate windows |
| `<Space>-` | Normal | Split window horizontally |
| `<Space>|` | Normal | Split window vertically |
| `<Space>wd` | Normal | Close window |

### Buffer Management

| Key | Mode | Description |
|-----|------|-------------|
| `<S-h>` | Normal | Previous buffer |
| `<S-l>` | Normal | Next buffer |
| `<Space>bd` | Normal | Delete buffer |
| `<Space>bo` | Normal | Delete other buffers |

### LSP & Code

| Key | Mode | Description |
|-----|------|-------------|
| `gd` | Normal | Go to definition |
| `gr` | Normal | Go to references |
| `K` | Normal | Hover documentation |
| `<Space>ca` | Normal | Code actions |
| `<Space>cr` | Normal | Rename symbol |
| `<Space>cf` | Normal/Visual | Format code |
| `]d` / `[d` | Normal | Next/Previous diagnostic |
| `]e` / `[e` | Normal | Next/Previous error |

### Git

| Key | Mode | Description |
|-----|------|-------------|
| `<Space>gg` | Normal | Open Lazygit |
| `<Space>gb` | Normal | Git blame line |
| `<Space>gh` | Normal | File history |
| `<Space>gB` | Normal | Browse on GitHub |

### AI & Copilot

| Key | Mode | Description |
|-----|------|-------------|
| `<Space>aa` | Normal/Visual | Toggle CopilotChat |
| `<Space>ae` | Visual | Explain code |
| `<Space>ar` | Visual | Review code |
| `<Space>af` | Visual | Fix code |

## 🔧 Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/
│   ├── config/             # Core configuration
│   │   ├── init.lua        # Plugin manager setup
│   │   ├── options.lua     # Vim options
│   │   ├── keymaps.lua     # Key mappings
│   │   └── autocmds.lua    # Auto commands
│   ├── plugins/            # Plugin configurations
│   │   ├── lsp.lua         # LSP setup
│   │   ├── nvim-cmp.lua    # Completion
│   │   ├── dap.lua         # Debugging
│   │   ├── neotest.lua     # Testing
│   │   └── ...
│   ├── utils/              # Utility functions
│   │   ├── init.lua        # Utility loader
│   │   ├── lsp.lua         # LSP utilities
│   │   ├── format.lua      # Formatting utilities
│   │   └── ...
│   └── vscode-config/      # VSCode integration
└── lazy-lock.json          # Plugin version lock
```

## 🎨 Customization

### Changing Theme

Edit `lua/plugins/colorscheme.lua` to switch themes. Current theme: Tokyo Night.

### Adding Plugins

Create a new file in `lua/plugins/` with your plugin configuration:

```lua
return {
  "author/plugin-name",
  opts = {
    -- plugin options
  },
}
```

### Modifying Keymaps

Edit `lua/config/keymaps.lua` to add or modify keybindings.

## 📝 Supported Languages

Out of the box LSP and tooling support for:

- Python
- TypeScript/JavaScript
- Lua
- Go
- Rust
- C/C++
- JSON/YAML
- Markdown
- And many more...

Language servers are automatically installed via Mason on first use.

## 🛠️ Troubleshooting

### Plugins not installing

Run `:Lazy sync` to manually sync plugins.

### LSP not working

1. Check if language server is installed: `:Mason`
2. Check LSP status: `:LspInfo`
3. Restart LSP: `:LspRestart`

### Performance issues

Run `:Lazy profile` to identify slow plugins.

## 📄 License

This configuration is available under the MIT License. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

This configuration is built upon the excellent work of the Neovim community and inspired by various configurations including LazyVim and other popular setups.

---

**Note**: This is a personal configuration. Feel free to fork and customize it to your needs!

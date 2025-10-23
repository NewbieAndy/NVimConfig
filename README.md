# 🚀 NVimConfig

一个现代化、功能完整的 Neovim 配置，开箱即用，支持多种编程语言的开发。

## ✨ 项目介绍

这是一个基于 [lazy.nvim](https://github.com/folke/lazy.nvim) 构建的 Neovim 配置，旨在提供一个高效、美观、功能强大的现代化编辑器体验。

### 🎯 项目优势

- **🎨 美观易用** - 使用 Tokyo Night 主题，配置 lualine、bufferline 等现代化 UI 组件
- **⚡ 高性能** - 基于 lazy.nvim 的延迟加载机制，启动速度快
- **🔧 开箱即用** - 预配置了主流编程语言的 LSP、格式化、语法高亮等功能
- **🤖 AI 辅助** - 集成 GitHub Copilot，提供智能代码补全和 AI 对话
- **🔍 强大搜索** - 集成 Snacks Picker 提供快速文件和代码搜索
- **🐛 调试支持** - 内置 DAP (Debug Adapter Protocol) 调试功能
- **📦 插件丰富** - 包含 50+ 精选插件，覆盖开发的各个方面
- **🎯 VSCode 兼容** - 支持在 VSCode Neovim 扩展中使用
- **📝 完整文档** - 详细的配置说明和键位映射

### 🎁 主要特性

- **LSP 支持** - 自动补全、代码诊断、跳转定义、重命名等
- **代码格式化** - 使用 conform.nvim 支持多种格式化工具（Prettier、Stylua 等）
- **代码检查** - 使用 nvim-lint 进行代码质量检查
- **语法高亮** - 基于 Treesitter 的准确语法高亮和代码折叠
- **Git 集成** - Gitsigns 提供 Git 状态显示和操作
- **文件浏览** - Neo-tree 文件管理器
- **智能搜索** - 快速查找文件、符号、文本
- **会话管理** - 自动保存和恢复工作会话
- **测试集成** - Neotest 支持运行和查看测试结果
- **重构工具** - 支持代码重构操作

## 📋 必须依赖

在使用本配置之前，请确保安装以下必需的软件：

### 1. Neovim (>= 0.9.0)

```sh
# macOS (Homebrew)
brew install neovim

# Ubuntu/Debian
sudo apt install neovim

# Arch Linux
sudo pacman -S neovim

# Windows (Scoop)
scoop install neovim
```

### 2. Git

```sh
# macOS (Homebrew)
brew install git

# Ubuntu/Debian
sudo apt install git

# Arch Linux
sudo pacman -S git

# Windows (Scoop)
scoop install git
```

### 3. C 编译器和构建工具

Treesitter 需要 C 编译器来编译语法解析器。

```sh
# macOS (Homebrew)
brew install make gcc

# Ubuntu/Debian
sudo apt install build-essential

# Arch Linux
sudo pacman -S base-devel

# Windows
# 安装 Visual Studio Build Tools 或 MinGW
```

### 4. Nerd Font 字体

为了正确显示图标，需要安装一个 [Nerd Font](https://www.nerdfonts.com) 字体。

推荐字体：
- **JetBrains Mono Nerd Font**
- **FiraCode Nerd Font**
- **Hack Nerd Font**

```sh
# macOS (Homebrew)
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# 其他系统请访问 https://www.nerdfonts.com/font-downloads 下载
```

### 5. Node.js (推荐)

许多 LSP 服务器和工具需要 Node.js。

```sh
# macOS (Homebrew)
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Arch Linux
sudo pacman -S nodejs npm

# Windows (Scoop)
scoop install nodejs
```

### 6. Python (推荐)

Python LSP 和一些工具需要 Python。

```sh
# macOS (Homebrew)
brew install python3

# Ubuntu/Debian
sudo apt install python3 python3-pip

# Arch Linux
sudo pacman -S python python-pip

# Windows (Scoop)
scoop install python
```

### 7. Ripgrep (搜索工具)

用于快速文本搜索。

```sh
# macOS (Homebrew)
brew install ripgrep

# Ubuntu/Debian
sudo apt install ripgrep

# Arch Linux
sudo pacman -S ripgrep

# Windows (Scoop)
scoop install ripgrep
```

### 8. fd (文件查找工具)

用于快速文件查找。

```sh
# macOS (Homebrew)
brew install fd

# Ubuntu/Debian
sudo apt install fd-find

# Arch Linux
sudo pacan -S fd

# Windows (Scoop)
scoop install fd
```

## 🚀 快速开始

### 1. 备份现有配置（如果有）

如果你已经有 Neovim 配置，建议先备份：

```sh
# 备份配置文件
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

或者完全删除（谨慎操作）：

```sh
# 删除现有配置
rm -rf ~/.config/nvim ~/.cache/nvim ~/.local/share/nvim ~/.local/state/nvim
```

### 2. 克隆配置

```sh
git clone https://github.com/NewbieAndy/NVimConfig.git ~/.config/nvim
```

### 3. 启动 Neovim

```sh
nvim
```

首次启动时，lazy.nvim 会自动安装所有插件，这可能需要几分钟时间。请耐心等待所有插件安装完成。

### 4. 安装 LSP 服务器（可选）

启动 Neovim 后，可以使用 Mason 安装需要的 LSP 服务器、格式化工具和调试器：

```
:Mason
```

推荐安装的 LSP 服务器：
- **lua-language-server** - Lua
- **typescript-language-server** - JavaScript/TypeScript
- **pyright** - Python
- **rust-analyzer** - Rust
- **gopls** - Go
- **clangd** - C/C++

推荐安装的格式化工具：
- **prettier** - JavaScript/TypeScript/JSON/Markdown 等
- **stylua** - Lua
- **shfmt** - Shell 脚本
- **black** - Python

### 5. 配置 Copilot（可选）

如果你想使用 GitHub Copilot，需要进行认证：

```
:Copilot auth
```

## 📂 项目结构

```
.
├── init.lua                 # 入口文件，判断是否在 VSCode 环境
├── lazy-lock.json           # 插件版本锁定文件
├── lua/
│   ├── config/              # 核心配置
│   │   ├── init.lua         # 初始化配置，设置 lazy.nvim
│   │   ├── options.lua      # Vim 选项设置
│   │   ├── keymaps.lua      # 键位映射
│   │   └── autocmds.lua     # 自动命令
│   ├── plugins/             # 插件配置（每个文件对应一个或一组插件）
│   │   ├── colorscheme.lua  # 主题配置
│   │   ├── lsp.lua          # LSP 配置
│   │   ├── nvim-cmp.lua     # 自动补全
│   │   ├── treesitter.lua   # 语法高亮
│   │   ├── neo-tree.lua     # 文件浏览器
│   │   ├── lualine.lua      # 状态栏
│   │   ├── bufferline.lua   # 标签栏
│   │   ├── gitsigns.lua     # Git 集成
│   │   ├── conform.lua      # 代码格式化
│   │   ├── nvim-lint.lua    # 代码检查
│   │   ├── dap.lua          # 调试器
│   │   ├── copilot-chat.lua # Copilot AI 助手
│   │   ├── flash.nvim       # 快速跳转
│   │   ├── which-key.lua    # 键位提示
│   │   └── ...              # 其他插件
│   ├── utils/               # 工具函数
│   │   ├── init.lua         # 通用工具函数
│   │   ├── lsp.lua          # LSP 相关工具
│   │   ├── format.lua       # 格式化工具
│   │   └── ...              # 其他工具
│   ├── vscode-config/       # VSCode Neovim 扩展配置
│   │   ├── init.lua         # VSCode 环境初始化
│   │   ├── options.lua      # VSCode 环境选项
│   │   ├── keymaps.lua      # VSCode 环境键位
│   │   └── plugins/         # VSCode 环境插件
│   └── types.lua            # 类型定义
└── README.md                # 项目说明文档
```

### 配置说明

- **init.lua**: 根据运行环境自动选择加载普通配置或 VSCode 配置
- **lua/config/**: 包含 Neovim 的基础配置，如选项设置、键位映射、自动命令等
- **lua/plugins/**: 每个文件配置一个或一组相关的插件，使用 lazy.nvim 的懒加载机制
- **lua/utils/**: 提供各种工具函数，供配置文件和插件使用
- **lua/vscode-config/**: 专门为 VSCode Neovim 扩展优化的配置

## ⌨️ 常用快捷键

Leader 键设置为 `空格键`

### 通用操作
- `<leader>e` - 打开/关闭文件浏览器
- `<C-e>` - 打开/关闭文件浏览器
- `<leader>ff` - 查找文件
- `<leader>fg` - 全局搜索文本
- `<leader>fb` - 查找 Buffer

### 窗口管理
- `<leader>h/j/k/l` - 切换到左/下/上/右窗口
- `<C-Up/Down/Left/Right>` - 调整窗口大小

### Buffer 操作
- `<S-h>` - 上一个 Buffer
- `<S-l>` - 下一个 Buffer
- `<leader>bd` - 删除 Buffer
- `<leader>bo` - 删除其他 Buffer

### LSP 功能
- `gd` - 跳转到定义
- `gr` - 查找引用
- `gi` - 跳转到实现
- `K` - 显示悬浮文档
- `<leader>ca` - 代码操作
- `<leader>rn` - 重命名符号

### Git 操作
- `<leader>gg` - 打开 Lazygit
- `<leader>gb` - Git blame

更多快捷键请在 Neovim 中按 `<leader>` 查看 which-key 提示。

## 🔧 自定义配置

如果你想自定义配置，可以：

1. 修改 `lua/config/options.lua` 来调整 Vim 选项
2. 修改 `lua/config/keymaps.lua` 来自定义快捷键
3. 在 `lua/plugins/` 目录下添加新的插件配置文件
4. 修改现有插件配置文件来调整插件行为

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🙏 致谢

本配置参考了以下优秀项目：
- [LazyVim](https://github.com/LazyVim/LazyVim)
- [NvChad](https://github.com/NvChad/NvChad)
- [AstroNvim](https://github.com/AstroNvim/AstroNvim)

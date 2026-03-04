# 🚀 NVimConfig | Neovim 配置（Linux 服务器版）

专为低配 Linux 服务器优化的 Neovim 配置。去掉了 LSP、AI、调试等重量级功能，保留语法高亮、文件管理、Git、搜索、格式化等日常开发必备工具。基于 lazy.nvim，资源占用低、启动快。

- 适合：需要在 2 核 2G 及以上 Linux 服务器上流畅使用 Neovim 的开发者
- 要求：Neovim >= 0.9，Git，C 编译器（treesitter 需要）

## ✨ 功能特性
- 性能与体验：lazy.nvim 按需加载、tokyonight 主题、lualine 状态栏、bufferline 标签栏
- 语法高亮：nvim-treesitter（仅安装服务器常用语言解析器：bash/python/lua/yaml/json 等）
- 代码格式化：conform.nvim（按需手动触发，不自动扫描）
- 文件/搜索：neo-tree 文件管理、grug-far 全局搜索替换、Snacks.picker 模糊查找
- Git：gitsigns 行内 diff 标记
- 会话与实用：persistence 会话恢复、which-key 键位提示、todo-comments
- 终端：Snacks.terminal 浮动终端

> 本配置已移除：LSP / 自动补全 / AI Copilot / 调试(DAP) / 测试(neotest) / noice UI / macOS 相关功能

## 📦 服务器依赖安装

### 1. 安装 Neovim（>= 0.9）

**方式 A：使用预编译包（推荐，最快）**
```sh
# 下载最新稳定版
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
tar -C /opt -xzf nvim-linux-x86_64.tar.gz
# 添加到 PATH（写入 ~/.bashrc 或 ~/.zshrc）
echo 'export PATH="/opt/nvim-linux-x86_64/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**方式 B：包管理器（版本可能较旧）**
```sh
# Ubuntu/Debian（推荐加 PPA 获取新版）
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update && sudo apt install -y neovim

# CentOS/RHEL
sudo yum install -y neovim
```

### 2. 安装必备工具
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

## 🚀 快速开始

### 1. 备份或清理旧配置
```sh
mv ~/.config/nvim{,.bak} 2>/dev/null
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

### 2. 克隆配置
```sh
git clone -b linux_server https://github.com/NewbieAndy/NVimConfig.git ~/.config/nvim
```

### 3. 首次启动（自动安装插件）
```sh
nvim
```
首次启动会自动下载并安装所有插件（需要网络，约 1~3 分钟）。安装完成后重启 nvim 即可正常使用。

> **提示**：在没有图形界面的纯终端服务器上，确保终端支持 256 色或 TrueColor（推荐使用 tmux + 支持 TrueColor 的终端连接）。

### 4. 确认 TreeSitter 解析器安装
```
:TSInstall bash python lua yaml json dockerfile
```
或直接 `:Lazy sync` 触发自动安装。

### 5. （可选）安装代码格式化工具
conform.nvim 会调用系统已安装的格式化程序，按需安装：
```sh
pip install black isort          # Python
npm install -g prettier          # JS/TS/JSON/YAML/Markdown
cargo install stylua             # Lua
sudo apt install -y shfmt        # Shell
```

## ⌨️ 常用按键
Leader 键：`<Space>`

| 功能 | 按键 |
|------|------|
| 文件树 | `<leader>e` / `<C-e>` |
| 查找文件 | `<leader><space>` |
| 全局搜索 | `<leader>/` |
| 搜索替换 | `<leader>fr` |
| 浮动终端 | `<C-/>` |
| 格式化 | `<leader>cf` |
| Git blame | `<leader>gb` |
| Buffer 切换 | `<S-h>` / `<S-l>` |
| 关闭 Buffer | `<leader>bd` |
| 分屏 | `<leader>-` (水平) / `<leader>\|` (垂直) |
| 窗口移动 | `<leader>h/j/k/l` |
| Lazy 管理 | `<leader>L` |
| 键位提示 | `<leader>` （稍等弹出 which-key）|

## 🧱 目录结构
```
~/.config/nvim/
├── init.lua                 # 入口（lazy.nvim 初始化）
├── lazy-lock.json           # 插件版本锁定
└── lua/
    ├── config/              # 核心配置（options/keymaps/autocmds）
    ├── plugins/             # 插件配置（按功能拆分）
    ├── utils/               # 通用工具（root/ui/format 等）
    └── types.lua            # 类型定义
```

## 🛠 自定义
- 主题：编辑 `lua/plugins/colorscheme.lua`（默认 tokyonight）
- 选项：编辑 `lua/config/options.lua`
- 键位：编辑 `lua/config/keymaps.lua`
- 添加插件：在 `lua/plugins/` 新增文件并返回插件 spec 即可

## 🐞 故障排查
- **插件未安装**：`:Lazy sync` / 检查服务器网络（是否需要代理）
- **treesitter 报错**：确认 gcc/make 已安装，运行 `:TSUpdate`
- **性能分析**：`:Lazy profile`
- **查看启动日志**：`:messages`

## 📄 许可
MIT License

## 🙏 鸣谢
- Neovim 社区与优秀配置：LazyVim、NvChad、AstroNvim 等

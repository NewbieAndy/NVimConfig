# 🚀 NVimConfig | Neovim 配置

一个现代、开箱即用的 Neovim 配置，涵盖 LSP、调试、测试、格式化、Git、AI 助手与 VSCode 集成等。基于 lazy.nvim，启动快、可维护、可扩展。

- 适合：多语言开发者、希望从 VSCode 平滑过渡到 Neovim 的用户
- 要求：Neovim >= 0.9，Nerd Font，基础构建工具

## ✨ 功能特性
- 性能与体验：lazy.nvim 按需加载、tokyonight 主题、lualine 状态栏、bufferline 标签栏、noice 增强 UI、Snacks 状态列/终端/工具集
- 语言与补全：mason/mason-lspconfig + nvim-lspconfig，blink.cmp 补全，friendly-snippets 片段
- 语法与文本：nvim-treesitter、ts-autotag、ts-comments、todo-comments
- 代码质量：conform.nvim（格式化）、nvim-lint（诊断）
- 调试与测试：nvim-dap + ui + virtual-text、dap-python、neotest（含 python 与 vitest）
- 文件/搜索：neo-tree 文件管理，grug-far 全局搜索替换
- Git：gitsigns，内置 Snacks.lazygit 集成
- AI：GitHub Copilot 与 CopilotChat（对话/解释/评审/修复）
- 会话与实用：persistence 会话恢复，which-key 键位提示，venv-selector 虚拟环境
- VSCode：支持在 VSCode Neovim 扩展中使用（自动选择 vscode-config）
- macOS 小工具：自动切换中英输入法（需 Hammerspoon，可选）

## 📦 必备依赖
- Neovim >= 0.9.0
- Git
- Nerd Font（推荐 JetBrains Mono Nerd Font）
- C 编译工具链（treesitter 需要）

可选：Node.js、Python、Lazygit、ripgrep、fd、Hammerspoon(macOS)

示例（macOS/Homebrew）：
```sh
brew install neovim git make ripgrep fd lazygit node python
brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font
```

## 🚀 快速开始
1) 备份/清理旧配置（二选一）
```sh
# 备份
mv ~/.config/nvim{,.bak}; mv ~/.local/share/nvim{,.bak}; mv ~/.local/state/nvim{,.bak}; mv ~/.cache/nvim{,.bak}
# 或删除
rm -rf ~/.config/nvim ~/.cache/nvim ~/.local/share/nvim ~/.local/state/nvim
```
2) 克隆到配置目录
```sh
git clone https://github.com/NewbieAndy/NVimConfig.git ~/.config/nvim
```
3) 启动 Neovim 并等待插件自动安装
```sh
nvim
```
4) 可选：安装所需 LSP/格式化/调试工具
```
:Mason
```
推荐 LSP：lua-language-server, typescript-language-server, pyright, rust-analyzer, gopls, clangd
推荐格式化：stylua, prettier, shfmt, black

5) 可选：登录 Copilot
```
:Copilot auth
```

## ⌨️ 常用按键
Leader 键：<Space>

- 文件：<leader>e 或 <C-e> 打开/关闭侧边文件树（neo-tree）
- 窗口：<leader>h/j/k/l 在分屏间移动；<C-箭头> 调整大小；<leader>- / <leader>| 分屏；<leader>wd 关窗
- Buffer：<S-h>/<S-l> 上/下一个；<leader>bd 关当前；<leader>bo 关其他
- 搜索替换：<leader>fr 打开 grug-far
- 终端：<C-/> 浮动终端（Snacks.terminal），终端中 <C-/> 关闭
- 诊断：<leader>cd 当前行诊断；]d/[d 下/上一条；]e/[e 错误；]w/[w 警告
- Git（需已安装 lazygit）：<leader>gg 根目录 Lazygit；<leader>gG 当前 cwd；<leader>gb 逐行 blame；<leader>gB 浏览；<leader>gh 文件历史；<leader>gl/gL 日志
- 其他：<leader>L 打开 Lazy；<leader>fn 新文件；<leader>ft 更改文件类型；<leader>cf 格式化
- 常见 LSP：gd 定义，gr 引用，gi 实现，K 悬浮文档，<leader>ca Code Action，<leader>rn 重命名

更多按键在 which-key 中查看（按 <leader> 弹出）。

## 🧱 目录结构
```
~/.config/nvim/
├── init.lua                 # VSCode/Neovim 自动分流入口
├── lazy-lock.json           # 插件版本锁定
└── lua/
    ├── config/              # 核心配置（options/keymaps/autocmds）
    ├── plugins/             # 插件配置（按功能拆分）
    ├── utils/               # 通用工具（root/ui/format 等）
    ├── vscode-config/       # VSCode Neovim 环境专用配置
    └── types.lua            # 类型定义
```

## 🛠 自定义
- 主题：编辑 lua/plugins/colorscheme.lua（默认 tokyonight）
- 选项：编辑 lua/config/options.lua
- 键位：编辑 lua/config/keymaps.lua
- 插件：在 lua/plugins/ 新增文件并返回插件表即可

## 🐞 故障排查
- 插件未安装：:Lazy sync / 检查网络代理
- LSP 异常：:Mason 查看安装，:LspInfo 查看状态，:LspRestart 重启
- 性能分析：:Lazy profile

## 📄 许可
MIT License

## 🙏 鸣谢
- Neovim 社区与优秀配置：LazyVim、NvChad、AstroNvim 等

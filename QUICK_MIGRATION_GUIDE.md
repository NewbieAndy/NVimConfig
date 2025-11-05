# 🚀 快速迁移指南 - nvim-cmp → blink.cmp

## 📝 迁移前检查
- [ ] 已阅读完整任务文档 `MIGRATION_TASK_nvim-cmp_to_blink-cmp.md`
- [ ] 已查看配置示例 `EXAMPLE_blink-cmp-config.lua`
- [ ] 当前配置已提交到 git 或已备份

## ⚡ 快速执行步骤

### 1️⃣ 删除旧配置 (2分钟)
```bash
# 在 ~/.config/nvim 目录下执行

# 方案A: 直接删除
rm lua/plugins/nvim-cmp.lua
rm lua/utils/cmp.lua

# 方案B: 重命名备份（推荐）
mv lua/plugins/nvim-cmp.lua lua/plugins/nvim-cmp.lua.bak
mv lua/utils/cmp.lua lua/utils/cmp.lua.bak
```

### 2️⃣ 创建新配置 (5分钟)
```bash
# 复制示例配置
cp EXAMPLE_blink-cmp-config.lua lua/plugins/blink-cmp.lua

# 或手动创建
nvim lua/plugins/blink-cmp.lua
```

### 3️⃣ 更新 LSP 配置 (2分钟)
编辑 `lua/plugins/lsp.lua`，查找并替换：

**查找:**
```lua
local capabilities = require('cmp_nvim_lsp').default_capabilities()
```

**替换为:**
```lua
local capabilities = require('blink.cmp').get_lsp_capabilities()
```

### 4️⃣ 更新 Copilot 配置 (3分钟)
编辑 `lua/plugins/copilot-chat.lua`：

**移除依赖:**
```lua
-- 删除这个依赖
-- "zbirenbaum/copilot-cmp",
```

**保留:**
```lua
-- 保留 copilot.lua（CopilotChat 需要）
{
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  enabled = true,
  build = ":Copilot auth",
  event = "BufReadPost",
  opts = {
    suggestion = {
      enabled = false, -- 使用 blink.cmp 的补全
      -- ... 其他配置保持不变
    },
  },
}
```

### 5️⃣ 启动并测试 (5分钟)
```bash
# 启动 Neovim
nvim

# Lazy 会自动安装 blink.cmp
# 等待安装完成后测试
```

## ✅ 测试清单

### 基础测试
- [ ] 打开 Lua 文件，输入 `vim.` 看到 LSP 补全
- [ ] 输入路径 `~/` 看到路径补全
- [ ] 输入代码片段触发词，看到 snippet 补全
- [ ] 按 Tab 能够接受补全和跳转 snippet
- [ ] 按 Ctrl+B/F 能够滚动文档

### Copilot 测试
- [ ] 输入代码看到 Copilot 建议（灰色行内提示）
- [ ] 补全菜单中看到 Copilot 补全项（有 Copilot 图标）
- [ ] `:CopilotChat` 仍然可用

### 命令行测试
- [ ] 按 `:` 输入命令看到命令补全
- [ ] 按 `/` 搜索时看到 buffer 补全

## 🔧 常见问题快速修复

### 问题1: blink.cmp 未启动
**症状**: 没有任何补全
**解决**:
```vim
:Lazy sync
:Lazy build blink.cmp
```

### 问题2: Copilot 补全不显示
**症状**: 只有 LSP 补全，没有 Copilot
**解决**:
1. 检查 `blink-cmp-copilot` 是否安装
2. 检查 `copilot.lua` 是否正常运行 `:Copilot status`
3. 查看配置中 sources.providers.copilot 是否正确

### 问题3: 键盘映射不工作
**症状**: Tab/Enter 行为不正确
**解决**:
检查 `keymap` 配置，确保函数返回值正确：
- 返回 `true` 表示已处理
- 返回 `false` 或不返回表示 fallback

### 问题4: LSP 补全缺失
**症状**: 之前有的 LSP 补全现在没了
**解决**:
确认 `lsp.lua` 中使用了正确的 capabilities:
```lua
local capabilities = require('blink.cmp').get_lsp_capabilities()
```

### 问题5: 代码片段不工作
**症状**: snippet 补全项无法展开
**解决**:
1. 确认 `friendly-snippets` 已安装
2. 检查 `snippets.preset` 配置
3. 测试 `:lua vim.snippet.expand("test ${1:placeholder}")`

## 📊 性能对比

理论上你应该感受到：
- ✅ 补全响应更快（特别是在大文件中）
- ✅ 启动速度略微提升（减少了插件数量）
- ✅ 模糊匹配更智能（容错性更好）

## 🔄 回滚方案

如果遇到无法解决的问题，快速回滚：

```bash
# 恢复备份
mv lua/plugins/nvim-cmp.lua.bak lua/plugins/nvim-cmp.lua
mv lua/utils/cmp.lua.bak lua/utils/cmp.lua

# 删除 blink.cmp 配置
rm lua/plugins/blink-cmp.lua

# 恢复 LSP 配置（手动修改）
# 将 blink.cmp 改回 cmp_nvim_lsp

# 重启 Neovim
nvim
:Lazy sync
```

## 📚 参考文档

- [详细任务文档](./MIGRATION_TASK_nvim-cmp_to_blink-cmp.md)
- [配置示例](./EXAMPLE_blink-cmp-config.lua)
- [blink.cmp 官方文档](https://cmp.saghen.dev)
- [当前 nvim-cmp 配置](./lua/plugins/nvim-cmp.lua.bak)

## ✨ 完成后

迁移成功后，可以删除以下文件：
- `lua/plugins/nvim-cmp.lua.bak`
- `lua/utils/cmp.lua.bak`
- `MIGRATION_TASK_nvim-cmp_to_blink-cmp.md`
- `EXAMPLE_blink-cmp-config.lua`
- `QUICK_MIGRATION_GUIDE.md`

---

**预计总耗时**: 15-20 分钟  
**难度**: 🟢 简单（按步骤操作）  
**建议**: 在非工作时间进行迁移，以便有时间测试和调整

---

祝迁移顺利！ 🎉

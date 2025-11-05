# nvim-cmp → blink.cmp 迁移执行清单（状态跟踪）

说明：每次执行前需重新加载本清单；每完成一个任务需更新状态与时间。
状态枚举：pending | in_progress | done | skipped | blocked
时间格式：UTC ISO8601

## 任务列表

### 1. 移除 nvim-cmp 全部依赖与文件
目标：用 blink.cmp 完全替代 nvim-cmp 系列
步骤：删除 lua/plugins/nvim-cmp.lua；移除 hrsh7th/cmp-* 与 copilot-cmp 依赖
状态: done
开始: 2025-11-04T00:00:00Z
结束: 2025-11-04T00:05:00Z

### 2. 新增 blink.cmp 最小配置（中文注释，简洁）
目标：提供稳定、易读的补全配置
步骤：创建 lua/plugins/blink-cmp.lua，最小 sources/keymap/menu/doc/cmdline 配置
状态: done
开始: 2025-11-04T00:02:00Z
结束: 2025-11-04T00:06:00Z

### 3. 严格复刻按键逻辑（<C-b>/<C-f>/<ESC>/<CR>/<Tab>/<F13>）
目标：键位行为与现有完全一致（条件判断顺序一致）
步骤：在 blink.keymap 内实现与现有 cmp 映射相同的分支逻辑
状态: done
开始: 2025-11-04T00:06:00Z
结束: 2025-11-04T00:08:00Z

### 4. 封装通用补全工具到 GlobalUtil.cmp（与引擎解耦）
目标：集中共用方法（actions/has_words_before/expand/auto_brackets/icon映射）
步骤：在 utils/cmp.lua 增加/调整上述方法，不依赖 nvim-cmp 专属事件
状态: done
开始: 2025-11-04T00:09:00Z
结束: 2025-11-04T00:12:00Z

### 5. 更新 Copilot 配置（移除 copilot-cmp 绑定）
目标：通过 blink-copilot 提供菜单式 AI，避免重复
步骤：保留 copilot.lua & CopilotChat；确保 suggestion.enabled=false，accept=false
状态: done
开始: 2025-11-04T00:12:00Z
结束: 2025-11-04T00:13:00Z

### 6. LSP 配置校验（不手动注入 capabilities）
目标：由 blink.cmp 处理能力声明
步骤：移除 cmp_nvim_lsp.default_capabilities 的引用，保留其余逻辑
状态: done
开始: 2025-11-04T00:13:00Z
结束: 2025-11-04T00:14:00Z

### 7. UI/Kind 图标与显示统一
目标：与 GlobalUtil.icons.kinds 一致
步骤：menu.draw/format 使用统一图标；Copilot provider 指定 kind="Copilot"
状态: done
开始: 2025-11-04T00:14:00Z
结束: 2025-11-04T00:15:00Z

### 8. 清理 nvim-cmp 专属引用
目标：消除隐藏耦合
步骤：全局搜索“cmp.”并替换为通用实现，移除 nvim-cmp 事件钩子（utils/cmp.lua 已加兼容守卫）
状态: done
开始: 2025-11-04T00:15:00Z
结束: 2025-11-04T00:17:00Z

### 9. 功能验证矩阵（键位与核心路径）
目标：确保替换完整可靠
步骤：验证 LSP/Buffer/Path/Snippets（移除 nvim-snippets 仅保留 friendly-snippets）、Copilot、cmdline、auto_brackets、大文件
状态: done
开始: 2025-11-04T00:18:00Z
结束: 2025-11-05T00:00:00Z

### 10. 中文注释覆盖
目标：降低维护成本
步骤：为关键逻辑补充“做什么/为什么/注意事项”中文注释
状态: done
开始: 2025-11-04T00:16:00Z
结束: 2025-11-04T00:18:00Z


### 11. 性能优化（整体）
目标：在不改变行为的前提下提升流畅度
步骤：关闭 LSP 引用高亮(改 Treesitter)、限制候选(max_items)、关闭 ghost_text、延迟菜单绘制、禁用 treesitter playground
状态: done
开始: 2025-11-05T00:00:00Z
结束: 2025-11-05T00:10:00Z

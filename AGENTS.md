AGENTS
======

目的
----
- 这个文档供自动化/代理式编码代理（agentic coding agents）在本仓库工作时参考：如何构建、格式化、运行单测，以及代码风格/约定。
- 文件位置：`AGENTS.md`（仓库根目录）。

快速命令（在仓库根目录执行）
--------------------------------
- 运行所有格式化器（如果你使用系统工具）：
  - `stylua .` （格式化 Lua 文件，需安装 `stylua`）
  - `prettier --write "**/*.{js,ts,json,md,css,scss,html,mdx,json5}"` （格式化 JS/TS/JSON/Markdown 等）
  - 或使用 `conform`：在 Neovim 环境中，通过插件自动运行（仓库中使用 `conform.nvim` 注册）。
- 运行 linters/诊断（工具依赖本机安装或 mason 管理）：
  - `luacheck .`（如果项目使用 luacheck）
  - `markdownlint-cli2 README.md`（markdown lint）

测试（本仓库为 Neovim 配置，测试支持推荐）
------------------------------------------------
- Neovim 内运行（neotest）：
  - 运行文件：在 Neovim 中 `:lua require('neotest').run.run(vim.fn.expand('%'))` 或 快捷键 `<leader>tf`（已在 keymaps 注册）
  - 运行最近：`require('neotest').run.run_last()`（若配置启用）
  - 运行最近失败：`require('neotest').run.run_last({strategy = 'dap'})`（示例）
- 在外部终端运行单个 Python 测试（pytest）：
  - 按测试函数名过滤：`pytest -q -k "TestNameOrExpression"`  
  - 按文件和测试名定位：`pytest path/to/test_file.py::test_function_name -q`  
- 在外部终端运行单个 Vitest（Node/TS）：
  - 使用 npx/npm/pnpm：`npx vitest -t "test name or regexp"` 或 `pnpm vitest -t "pattern"`
- Lua 单测（如果使用 plenary/busted）：
  - plenary（Neovim 插件测试）：在 Neovim 中运行 `:lua require('plenary.test_harness').test_directory('path/to/tests')` 或使用 neotest 集成
  - busted（如果项目使用）：`busted path/to/test.lua:LINE` 或 `busted -g "pattern"`

如何运行单个测试（常用示例）
--------------------------------
- pytest 单测定位（最确定）：
  - `pytest path/to/test_file.py::TestClass::test_method -q`
- pytest 按关键字：
  - `pytest -k "something" -q` （匹配测试名或父类名）
- vitest：
  - `npx vitest -t "should compute X"`（测试名匹配）
- neotest（在 Neovim 内运行某一行/最近）：
  - `:lua require('neotest').run.run()`（运行光标所在的最近测试）

仓库特殊说明
----------------
- 这是个人 Neovim 配置（Lua），入口 `init.lua`，插件配置放在 `lua/plugins/`，工具模块在 `lua/utils/`。
- 格式化器在 `lua/plugins/conform.lua` 中注册，推荐使用 `stylua`（Lua）与 `prettier`（前端、json、markdown 等）。
- 全局工具对象：`_G.GlobalUtil`（定义于 `lua/utils/init.lua`），agents 在修改或调用全局工具时请保持谨慎并优先使用 `GlobalUtil` 提供的 API。
- 测试/调试：仓库集成 `neotest`、`nvim-dap` 等，Neovim 内快捷键映射已在 `lua/config/keymaps.lua` 注册（例如 `<leader>tt`, `<leader>tf` 等）。

代码风格与约定（Lua 重点）
---------------------------------
- 文件与模块：
  - 模块统一返回一个 table（例如 `local M = {}` / `return M`）。
  - 模块名对应路径（`lua/foo/bar.lua` -> `require('foo.bar')`）。
  - 在模块顶部使用 `local` 引入依赖：`local util = require('utils.something')`。
- 命名约定：
  - 模块表命名为 `M`。模块内部函数和字段使用 `snake_case` 或 `camel_case_with_underscores`（仓库示例多用 `get_pkg_path`, `safe_keymap_set`），保持一致性即可，优先遵循现有代码风格（使用下划线分隔单词）。
  - 常量或全局常量使用大写或 Pascal（`CREATE_UNDO` 在仓库已使用）。
  - 局部变量使用 `local`，避免污染全局作用域。
- 函数与注释：
  - 使用 EmmyLua 注释（`---@param`, `---@return`, `---@class`, `---@generic` 等）为 LSP 提供类型提示，参见 `lua/types.lua` 和库内注释样式。
  - 复杂函数在顶部添加简短中文注释，说明职责与边界条件。
- 错误处理：
  - 优先使用 `pcall(require, ...)` 或 `pcall(fn)` 捕获可预期的模块加载或运行错误，并在失败时优雅退回（不要让整个 Neovim 崩溃）。
  - 使用 `assert` 仅用于致命错误或开发断言，生产路径请返回 `nil` + 错误信息或调用 `GlobalUtil.warn/error(...)`。
  - 不要静默吞掉异常；记录/通知（`GlobalUtil.warn/error` 或 `vim.notify`）有助于排查。
- 导入/require 的使用：
  - 在文件顶部进行 `local mod = require('...')`，避免在循环或热路径里重复 require。
  - 对于可选依赖使用 `local ok, mod = pcall(require, 'mod')` 并在 `ok` 为 false 时 fallback。
  - utils 模式：`lua/utils/init.lua` 使用元表延迟加载（懒加载），agent 在新增工具模块时应遵循该模式以保持一致。
- 格式化与风格工具：
  - Lua：`stylua` 作为首选格式化工具；在需要特殊对齐或忽略时使用 `-- stylua: ignore` 或 `-- stylua: ignore start/stop`。
  - JS/TS/JSON/Markdown：`prettier`（`--write`）。
  - conform.nvim：仓库中通过 `conform` 集成多种格式化器，prefer 用项目配置而不是手动格式化所有文件。
- 代码组织与粒度：
  - 小模块、专一原则：每个 `lua/plugins/*.lua` 文件返回一个 lazy.nvim 插件 spec；每个 `lua/utils/*.lua` 提供一组相关工具。
  - 避免过大的文件；将不相关的功能拆分成独立模块。
- 日志与提示：
  - 使用 `GlobalUtil.info/warn/error` 包裹通知（这些封装了标题与一致的行为），不要直接大量使用 `print`。

Pull Request / Commit 建议
---------------------------
- 小而频繁的提交；每次提交只做一件事（修复、功能、样式）。
- 提交信息使用中文简短前缀，例如 `feat(...)`, `fix(...)`, `chore(...)` 并在正文简述为什么要改动。

Copilot / Cursor 规则
---------------------
- Copilot 指令文件：仓库包含 `.github/copilot-instructions.md`，主要内容摘要：
  - 该配置的注释以中文为主；入口 `init.lua`；插件文件必须返回 lazy.nvim 插件 spec；工具模块使用元表懒加载；使用 EmmyLua 注解；格式化通过 `GlobalUtil.format.register(...)` 注册。
  - 位置：`.github/copilot-instructions.md`（请遵循其中的关键约定）。
- Cursor 规则：在仓库中未发现 `.cursor/rules/` 或 `.cursorrules`，因此没有额外的 Cursor-specific 指令需要包含。

行为准则（agent 专用）
----------------------
- 不要在未询问的情况下修改大量文件或重写风格工具配置；先运行并报告现状。
- 若要新增依赖或更改工具（例如把 `stylua` 换为其他格式器），先在 PR 中说明理由与回退方案。
- 修改 `lua/plugins/` 或 `lua/config/` 时保持 lazy.nvim 的约定（文件返回 plugin spec）；不要把副作用放在 module 顶部（除非必要）。
- 测试策略：对功能性修改，优先在本地用 `neotest`/`pytest`/`vitest` 验证；对格式化/样式改动，运行格式化工具并确保 no changes in unrelated files。

后续建议（可选）
-------------------
1. 添加 `Makefile` 或 `./scripts` 目录，集中封装常用命令：`make fmt`, `make lint`, `make test TEST=path::name`。
2. 在仓库根放 `stylua.toml` 与 `.prettierrc` 明确团队格式规则。
3. 若希望 agents 自动运行测试并提交结果，添加 CI（GitHub Actions）步骤：`fmt/lint/test`。

附：关键参考文件
-----------------
- `init.lua`（仓库入口）
- `lua/config/*`（启动配置）
- `lua/plugins/*`（插件配置，必须返回 lazy spec）
- `lua/utils/init.lua`（全局工具与懒加载实现）
- `.github/copilot-instructions.md`（Copilot 规则）

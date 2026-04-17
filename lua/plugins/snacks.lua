return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			indent = { enabled = true },
			bigfile = { enabled = true },
			lazygit = { enabled = true },
			image = {
				-- 文档内内联渲染（markdown/html/tsx 等）
				doc = {
					enabled = true,
					inline = true,
					float = true,
					max_width = 80,
					max_height = 40,
				},
				-- ![[image.png]] Obsidian wikilink 格式路径解析
				-- 仅处理无路径分隔符的裸文件名，在整个 vault 内递归查找
				-- 有路径的 src（如 ./img/foo.png）返回 nil，交给 snacks 默认逻辑处理
				resolve = function(_, src)
					if src:find("/") or src:find("\\") then
						return nil
					end
					local vault_path = require("miniobsidian").config.vault_path
					if not vault_path or vault_path == "" then
						return nil
					end
					local found = vim.fs.find(src, { path = vault_path, type = "file", limit = 1 })
					return found[1]
				end,
			},
			styles = {
				snacks_image = {
					relative = "cursor",
					focusable = false,
				},
			},
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			explorer = {
				enabled = true,
				replace_netrw = true, -- 禁用自动打开（手动用 <C-e> / <leader>e 打开）
        trash = true, -- Use the system trash when deleting files
			},
			picker = {
				prompt = GlobalUtil.icons.kinds.Apple,
				enabled = true,
				ui_select = true,
				actions = {
					sidekick_send = function(...)
						return require("sidekick.cli.snacks").send(...)
					end,
					-- 复制文件完整路径到系统剪贴板
					custom_copy_path = function(picker)
						local selected = picker:selected({ fallback = true })
						local target = selected and selected[1]
						if not target or not target.file then
							return
						end
						vim.fn.setreg("+", target.file, "c")
						vim.notify("已复制路径: " .. target.file, vim.log.levels.INFO, { title = "explorer" })
					end,
					-- 删除文件/文件夹，但禁止删除当前项目根目录
					custom_explorer_del = function(picker, item)
						local selected = picker:selected({ fallback = true })
						if not selected or #selected == 0 then
							return
						end
						local root = GlobalUtil.root.root()
						for _, target in ipairs(selected) do
							local target_path = target.file
							if target_path then
								target_path = GlobalUtil.root.realpath(target_path) or target_path
								if root and target_path == root then
									vim.notify(
										"不能删除当前项目根目录: " .. vim.fn.fnamemodify(root, ":~"),
										vim.log.levels.WARN,
										{ title = "explorer" }
									)
									return
								end
							end
						end
						picker:action("explorer_del")
					end,
					-- 导航上级目录并同步项目根目录
					-- 注意\uff1a必须用 picker:action() 调用内置动作，不能直接 require snacks 内部模块
					custom_explorer_up = function(picker, item)
						picker:action("explorer_up")
						vim.schedule(function()
							local cwd = vim.uv.cwd()
							if cwd then
								GlobalUtil.root.reload_root_path(cwd)
							end
						end)
					end,
				},
				win = {
					input = {
						keys = {
							["<a-a>"] = { "sidekick_send", mode = { "n", "i" } },
							["<c-b>"] = { "preview_scroll_up", mode = { "i", "n" } },
							["<c-f>"] = { "preview_scroll_down", mode = { "i", "n" } },
						},
					},
				},
				sources = {
					ui_select = {
						win = {
							list = { number = false, relativenumber = false },
						},
					},
					files = {
						ignored = true, -- 默认显示 gitignore 文件
						hidden = true, -- 默认显示 gitignore 文件
					},
					explorer = {
						ignored = true, -- 默认显示 gitignore 文件
						win = {
							list = {
								keys = {
									-- ESC 在 list 窗口中禁用（防止关闭 explorer）
									["<Esc>"] = false,
									-- ── 导航 ──────────────────────────────────────────
									["<BS>"] = "custom_explorer_up",      -- 退回上级目录（同步根目录）
									["<CR>"] = "explorer_focus",          -- 进入目录并设为 cwd（方案 B）
									["<2-LeftMouse>"] = "confirm",        -- 双击打开文件
									["o"] = "confirm",                    -- 打开文件
									["l"] = "confirm",                    -- 打开文件（同 o）
									["h"] = "explorer_close",             -- 折叠目录
									["s"] = "edit_split",                 -- 水平分割打开
									["v"] = "edit_vsplit",                -- 垂直分割打开
									["O"] = "explorer_open",              -- 用系统应用打开
									-- ── 搜索 / 过滤 ───────────────────────────────────
									["/"] = "focus_input",                -- 聚焦顶部搜索框进行实时过滤（同 vim / 搜索习惯）
									-- ── 文件操作 ──────────────────────────────────────
									-- 新建：输入名称后按 <CR>；以 / 结尾自动创建目录
									["a"] = "explorer_add",               -- 新建文件（名称末尾加 / 则建目录）
									["A"] = "explorer_add",               -- 同上（保留 neo-tree 肌肉记忆）
									["d"] = "custom_explorer_del",        -- 移入回收站（禁止删除项目根目录）
									["r"] = "explorer_rename",            -- 重命名
									["y"] = { "explorer_yank", mode = { "n", "x" } }, -- 复制到剪贴板
									["Y"] = "custom_copy_path",           -- 复制完整路径到系统剪贴板
									["x"] = { "explorer_yank", mode = { "n", "x" } }, -- 剪切（配合 p 粘贴）
									["p"] = "explorer_paste",             -- 粘贴
									["c"] = "explorer_copy",              -- 复制文件
									["m"] = "explorer_move",              -- 移动文件
									-- ── 视图 ──────────────────────────────────────────
									["z"] = "explorer_close_all",         -- 折叠所有目录
									["Z"] = "explorer_close_all",
									["R"] = "explorer_update",            -- 刷新
									["u"] = "explorer_update",
									["<tab>"] = "toggle_preview",         -- 切换预览
									["P"] = "toggle_preview",
									["<C-f>"] = { "preview_scroll_down", mode = { "n", "x" } },
									["<C-b>"] = { "preview_scroll_up", mode = { "n", "x" } },
									["I"] = "toggle_ignored",             -- 切换显示 gitignore 文件
									["."] = "toggle_hidden",              -- 切换显示隐藏文件
									-- ── 其他 ──────────────────────────────────────────
									["<c-o>"] = "explorer_open",          -- 系统应用打开（备用）
									["<c-c>"] = "tcd",                    -- 设置 tab 工作目录
									["<leader>/"] = "picker_grep",        -- 在当前目录 grep
									["<c-t>"] = "terminal",               -- 在当前目录打开终端
									-- ── Git / 诊断跳转 ────────────────────────────────
									["]g"] = "explorer_git_next",
									["[g"] = "explorer_git_prev",
									["]d"] = "explorer_diagnostic_next",
									["[d"] = "explorer_diagnostic_prev",
									["]w"] = "explorer_warn_next",
									["[w"] = "explorer_warn_prev",
									["]e"] = "explorer_error_next",
									["[e"] = "explorer_error_prev",
									["?"] = "toggle_help_list",           -- 显示快捷键帮助
								},
							},
						},
					},
				},
				-- filter = {
				-- 	cwd = true, -- Filter pickers by current working directory
				-- },
			},
			quickfile = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			terminal = {
				win = { position = "float", border = "rounded" },
			},
			-- styles = {
			-- 	notification = {
			-- 		wo = { wrap = true }, -- Wrap notifications
			--        -- relative = true, -- Relative time
			-- 	},
			-- },
			dashboard = {
				preset = {
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "e", desc = "Open", action = function() vim.api.nvim_feedkeys(":edit ", "n", false) end },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            -- { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "f", desc = "Find File", action = function() Snacks.picker.smart() end },
            { icon = " ", key = "g", desc = "Find Text", action = function() Snacks.picker.grep() end },
            { icon = " ", key = "o", desc = "Recent Files", action = function() Snacks.picker.recent() end },
            { icon = " ", key = "p", desc = "Recent Project", action = function() Snacks.picker.projects() end },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
					header = [[
███╗   ██╗███████╗ ██████╗  █████╗ ██╗██████╗  █████╗ 
████╗  ██║██╔════╝██╔═══██╗██╔══██╗██║██╔══██╗██╔══██╗
██╔██╗ ██║█████╗  ██║   ██║███████║██║██████╔╝███████║
██║╚██╗██║██╔══╝  ██║   ██║██╔══██║██║██╔══██╗██╔══██║
██║ ╚████║███████╗╚██████╔╝██║  ██║██║██║  ██║██║  ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝]],
				},
			},
		},
		config = function(_, opts)
			require("snacks").setup(opts)

			-- 修复 snacks 图片 buffer：切走再切回时 hidden 状态没有恢复，导致图片不重绘。
			local placement = require("snacks.image.placement")
			if placement._patched_reenter_fix then
				return
			end
			placement._patched_reenter_fix = true

			local update = placement.update
			function placement:update()
				if not self.opts.inline and self.hidden and #self:wins() > 0 then
					self.hidden = false
				end
				return update(self)
			end
		end,
		keys = {
			-- Top Pickers & Explorer
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "文件浏览器",
			},
			{
				"<C-e>",
				function()
					Snacks.explorer()
					vim.cmd("stopinsert")
				end,
				desc = "文件浏览器",
				mode = { "n", "i" },
			},
			{
				"<leader><space>",
				function()
					Snacks.picker.smart({ filter = { cwd = true } })
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>ff",
				function()
					Snacks.picker.files({ filter = { cwd = true } })
				end,
				desc = "Find Files",
			},
			{
				"<leader>/",
				function()
					Snacks.picker.lines()
				end,
				desc = "Grep",
			},
			{
				"<leader>sg",
				function()
					Snacks.picker.grep({ filter = { cwd = true } })
				end,
				desc = "Grep",
			},
			{
				"<leader>,",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			-- {
			-- 	"<leader>n",
			-- 	function()
			-- 		Snacks.picker.notifications()
			-- 	end,
			-- 	desc = "Notification History",
			-- },
			-- find
			{
				"<leader>fb",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fp",
				function()
					Snacks.picker.projects()
				end,
				desc = "Projects",
			},
			{
				"<leader>fo",
				function()
					Snacks.picker.recent({ filter = { cwd = true } })
				end,
				desc = "Recent",
			},
			{
				"<leader>fO",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent",
			},
			-- git
			{
				"<leader>gb",
				function()
					Snacks.picker.git_branches()
				end,
				desc = "Git Branches",
			},
			{
				"<leader>gl",
				function()
					Snacks.picker.git_log()
				end,
				desc = "Git Log",
			},
			{
				"<leader>gL",
				function()
					Snacks.picker.git_log_line()
				end,
				desc = "Git Log Line",
			},
			{
				"<leader>gs",
				function()
					Snacks.picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					Snacks.picker.git_stash()
				end,
				desc = "Git Stash",
			},
			{
				"<leader>gd",
				function()
					Snacks.picker.git_diff()
				end,
				desc = "Git Diff (Hunks)",
			},
			{
				"<leader>gf",
				function()
					Snacks.picker.git_log_file()
				end,
				desc = "Git Log File",
			},
			-- search
			{
				'<leader>"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>s/",
				function()
					Snacks.picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				function()
					Snacks.picker.loclist()
				end,
				desc = "Location List",
			},
			{
				"<leader>m",
				function()
					Snacks.picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sR",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>uC",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			-- image（备用快捷键，K 在图片文件中会自动触发）
			{
				"<leader>ip",
				function()
					Snacks.image.hover()
				end,
				desc = "预览光标处图片",
			},
		},

		init = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					-- Setup some globals for debugging (lazy-loaded)
					_G.dd = function(...)
						Snacks.debug.inspect(...)
					end
					_G.bt = function()
						Snacks.debug.backtrace()
					end
					vim.print = _G.dd -- Override print to use snacks for `:=` command
				end,
			})
		end,
	},
}

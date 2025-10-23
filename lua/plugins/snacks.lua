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
			notifier = {
				enabled = true,
				timeout = 3000,
			},
			explorer = {
				enabled = false,
				replace_netrw = true, -- Replace netrw with Snacks Explorer
			},
			picker = {
				prompt = GlobalUtil.icons.kinds.Apple,
				enabled = true,
				cwd = GlobalUtil.root.root(),
				ui_select = true,
				sources = {
					explorer = {
						enabled = false,
						win = {
							list = {
								keys = {
									["<BS>"] = "explorer_up",
									["<CR>"] = "explorer_focus",
									["o"] = "confirm",
									["l"] = "confirm",
									["h"] = "explorer_close", -- close directory
									["a"] = "explorer_add",
									["d"] = "explorer_del",
									["r"] = "explorer_rename",
									["c"] = "explorer_copy",
									["m"] = "explorer_move",
									["<c-o>"] = "explorer_open", -- open with system application
									["P"] = "toggle_preview",
									["y"] = { "explorer_yank", mode = { "n", "x" } },
									["p"] = "explorer_paste",
									["u"] = "explorer_update",
									["<c-c>"] = "tcd",
									["<leader>/"] = "picker_grep",
									["<c-t>"] = "terminal",
									["I"] = "toggle_ignored",
									["."] = "toggle_hidden",
									["Z"] = "explorer_close_all",
									["]g"] = "explorer_git_next",
									["[g"] = "explorer_git_prev",
									["]d"] = "explorer_diagnostic_next",
									["[d"] = "explorer_diagnostic_prev",
									["]w"] = "explorer_warn_next",
									["[w"] = "explorer_warn_prev",
									["]e"] = "explorer_error_next",
									["[e"] = "explorer_error_prev",
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
				win = { position = "float" },
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
		keys = {
			-- Top Pickers & Explorer
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
			{
				"<leader>n",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},
			-- {
			-- 	"<leader>e",
			-- 	function()
			-- 		Snacks.explorer()
			-- 	end,
			-- 	desc = "File Explorer",
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
			-- Grep
			-- search
			{
				'<leader>s"',
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

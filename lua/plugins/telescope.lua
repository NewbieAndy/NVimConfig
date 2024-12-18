return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		enabled = true,
		version = false, -- telescope did only one release, so use HEAD for now
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				enabled = true,
				config = function(plugin)
					GlobalUtil.on_load("telescope.nvim", function()
						local ok, err = pcall(require("telescope").load_extension, "fzf")
						if not ok then
							local lib = plugin.dir .. "/build/libfzf." .. (GlobalUtil.is_win() and "dll" or "so")
							if not vim.uv.fs_stat(lib) then
								GlobalUtil.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
								require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
									GlobalUtil.info(
										"Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim."
									)
								end)
							else
								GlobalUtil.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
							end
						end
					end)
				end,
			},
		},
		keys = function()
			local builtin = require("telescope.builtin")
			return {
				-- { "<leader><space>", builtin.find_files, desc = "搜索文件" },
				{
					"<leader><space>",
					function()
						builtin.find_files({ cwd = GlobalUtil.root.root() })
					end,
					desc = "搜索文件",
				},
				{ "<leader>/", builtin.current_buffer_fuzzy_find, desc = "Buffer" },
				{ "<leader>:", builtin.command_history, desc = "History Commands" },
				{ "<leader>m", builtin.marks, desc = "跳转书签" },
				{
					"<leader>ff",
					function()
						builtin.find_files({ cwd = GlobalUtil.root.root() })
					end,
					desc = "搜索文件",
				},
				{
					"<leader>fo",
					function()
						builtin.oldfiles({ cwd = GlobalUtil.root.root() })
					end,
					desc = "Recent",
				},
				{
					"<leader>sg",
					function()
						builtin.live_grep({ cwd = GlobalUtil.root.root() })
					end,
					desc = "Grep (Root Dir)",
				},
				{ "<leader>sb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "切换 Buffer" },
				{ "<leader>sj", builtin.jumplist, desc = "Jumplist" },
				{ "<leader>sk", builtin.keymaps, desc = "keymaps" },
				{ "<leader>sl", builtin.loclist, desc = "Location List" },
				{ "<leader>so", builtin.vim_options, desc = "Options" },
				{ "<leader>sq", builtin.quickfix, desc = "Quickfix List" },
				{ "<leader>sr", builtin.registers, desc = "Registers" },
				{
					"<leader>gf",
					function()
						builtin.git_files({ cwd = GlobalUtil.root.root() })
					end,
					desc = "Find Files (git-files)",
				},
				{
					"<leader>gc",
					function()
						builtin.git_commits({ cwd = GlobalUtil.root.root() })
					end,
					desc = "Git Commits",
				},
				{
					"<leader>gs",
					function()
						builtin.git_status({ cwd = GlobalUtil.root.root() })
					end,
					desc = "Git Status",
				},
				{ "<leader>sa", builtin.autocommands, desc = "Auto Commands" },
				-- search
				-- { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
				-- { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
				-- { "<leader>sg", require("telescope.builtin").live_grep, desc = "Grep (Root Dir)" },
				-- { "<leader>sG", require("telescope.builtin").live_grep({ root = false }), desc = "Grep (cwd)" },
				-- { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
				-- { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
				-- { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
				-- { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
				-- { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
				-- { "<leader>sw",  require("telescope.builtin").grep_string({ word_match = "-w" }), desc = "Word (Root Dir)" },
				-- { "<leader>sW",  require("telescope.builtin").grep_string({ root = false, word_match = "-w" }), desc = "Word (cwd)" },
				-- { "<leader>sw",  require("telescope.builtin").grep_string, mode = "v", desc = "Selection (Root Dir)" },
				-- { "<leader>sW",  require("telescope.builtin").grep_string({ root = false }), mode = "v", desc = "Selection (cwd)" },
				-- { "<leader>uC",  require("telescope.builtin").colorscheme({ enable_preview = true }), desc = "Colorscheme with Preview" },
				-- {
				--   "<leader>ss",
				--   function()
				--     require("telescope.builtin").lsp_document_symbols({
				--       symbols = GlobalUtil.get_kind_filter(),
				--     })
				--   end,
				--   desc = "Goto Symbol",
				-- },
				-- {
				--   "<leader>sS",
				--   function()
				--     require("telescope.builtin").lsp_dynamic_workspace_symbols({
				--       symbols = GlobalUtil.get_kind_filter(),
				--     })
				--   end,
				--   desc = "Goto Symbol (Workspace)",
				-- },
			}
		end,
		opts = function()
			local actions = require("telescope.actions")

			local function flash(prompt_bufnr)
				require("flash").jump({
					pattern = "^",
					label = { after = { 0, 0 } },
					search = {
						mode = "search",
						exclude = {
							function(win)
								return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
							end,
						},
					},
					action = function(match)
						local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
						picker:set_selection(match.pos[1] - 1)
					end,
				})
			end

			return {
				defaults = {
					cwd = GlobalUtil.root.root(),
					prompt_prefix = " ",
					selection_caret = " ",
					-- open files in the first window that is an actual file.
					-- use the current window if no other window is available.
					get_selection_window = function()
						local wins = vim.api.nvim_list_wins()
						table.insert(wins, 1, vim.api.nvim_get_current_win())
						for _, win in ipairs(wins) do
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].buftype == "" then
								return win
							end
						end
						return 0
					end,
					file_ignore_patterns = { "^%.git[/\\]", "[/\\]%.git[/\\]" },
					path_display = { "truncate" },
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = { prompt_position = "top", preview_width = 0.55 },
						vertical = { mirror = false },
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
					mappings = {
						i = {
							["<c-f>"] = flash,
							["<c-s>"] = actions.file_split,
							["<c-v>"] = actions.file_vsplit,
						},
						n = {
							["f"] = flash,
							["q"] = actions.close,
							["s"] = actions.file_split,
							["v"] = actions.file_vsplit,
							["h"] = actions.results_scrolling_left,
							["l"] = actions.results_scrolling_right,
						},
					},
				},
				pickers = {
					find_files = {
						cwd = GlobalUtil.root.root(),
					},
					oldfiles = {
						cwd = GlobalUtil.root.root(),
					},
					-- find_files = {
					-- 	find_command = find_command,
					-- 	hidden = true,
					-- },
				},
			}
		end,
	},
	-- better vim.ui with telescope
	{
		"stevearc/dressing.nvim",
		lazy = true,
		enabled = true,
		init = function()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.select = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.select(...)
			end
			---@diagnostic disable-next-line: duplicate-set-field
			vim.ui.input = function(...)
				require("lazy").load({ plugins = { "dressing.nvim" } })
				return vim.ui.input(...)
			end
		end,
	},
}

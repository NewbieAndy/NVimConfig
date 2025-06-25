return {
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-path",
			{
				"garymjr/nvim-snippets",
				opts = {
					friendly_snippets = true,
				},
				dependencies = { "rafamadriz/friendly-snippets" },
			},
			{
				"zbirenbaum/copilot-cmp",
				enabled = true,
				opts = {},
				config = function(_, opts)
					local copilot_cmp = require("copilot_cmp")
					copilot_cmp.setup(opts)
					-- attach cmp source whenever copilot attaches
					-- fixes lazy-loading issues with the copilot cmp source
					GlobalUtil.lsp.on_attach(function()
						copilot_cmp._on_insert_enter({})
					end, "copilot")
				end,
			},
		},
		opts = function()
			vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
			local cmp = require("cmp")
			local defaults = require("cmp.config.default")()
			local auto_select = true
			--光标前是否有字符
			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			--这里配置补全源
			local cmp_sources = {
				{
					name = "copilot",
					group_index = 1,
					priority = 100,
					icon = GlobalUtil.icons.kinds.Copilot,
				},
				{
					name = "copilot",
					group_index = 1,
					priority = 100,
					icon = GlobalUtil.icons.kinds.Copilot,
				},
				{
					name = "lazydev",
					group_index = 0,
					icon = GlobalUtil.icons.kinds.Dev,
				},
				{
					name = "nvim_lsp",
					group_index = 1,
					icon = GlobalUtil.icons.kinds.Lsp,
				},
				{
					name = "path",
					group_index = 1,
					icon = GlobalUtil.icons.kinds.Path,
				},
				{
					name = "buffer",
					group_index = 1,
					icon = GlobalUtil.icons.kinds.Buffer,
				},
				{
					name = "snippets",
					group_index = 1,
					icon = GlobalUtil.icons.kinds.Snippet,
				},
				{
					name = "render-markdown",
					icon = GlobalUtil.icons.kinds.Markdown,
				},
			}
			-- 获取源图标
			function get_source_icon(item_name)
				for _, value in pairs(cmp_sources) do
					if value.name == item_name then
						return value.icon
					end
				end
				return GlobalUtil.icons.kinds.Apple
			end

			return {
				native_menu = false, -- 或 true
				auto_brackets = { "python" }, -- configure any filetype to auto add brackets
				completion = {
					completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
				},
				preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<ESC>"] = function(fallback)
						cmp.abort()
						fallback()
					end,
					["<CR>"] = cmp.mapping(function(fallback)
						GlobalUtil.create_undo()
						if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
							cmp.confirm({
								select = true,
								behavior = cmp.ConfirmBehavior.Insert,
							})
						--有代码片段触发代码片段
						elseif vim.snippet.active({ direction = 1 }) then
							vim.schedule(function()
								vim.snippet.jump(1)
							end)
						else
							fallback()
						end
					end, { "i", "c", "s" }),
					["<Tab>"] = cmp.mapping(function(fallback)
						GlobalUtil.create_undo()
						if require("copilot.suggestion").is_visible() then
							require("copilot.suggestion").accept()
						elseif cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
							cmp.confirm({
								select = true,
								behavior = cmp.ConfirmBehavior.Insert,
							})
						--有代码片段触发代码片段
						elseif vim.snippet.active({ direction = 1 }) then
							vim.schedule(function()
								vim.snippet.jump(1)
							end)
						--光标前有字符，没有弹出窗口则呼出窗口
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "c", "s" }),
				}),
				sources = cmp_sources,
				formatting = {
					format = function(entry, item)
						local icons = GlobalUtil.icons.kinds
						if icons[item.kind] then
							item.kind = icons[item.kind] .. item.kind
						end
						item.menu = get_source_icon(entry.source.name)

						local widths = {
							abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
							menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
						}

						for key, width in pairs(widths) do
							if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
								item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
							end
						end
						return item
					end,
				},
				experimental = {
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
				sorting = defaults.sorting,
			}
		end,
		main = "utils.cmp",
	},
}

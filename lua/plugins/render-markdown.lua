return {
	"MeanderingProgrammer/render-markdown.nvim",
	lazy = false,
	init = function()
		if vim.fn.exists(":Markview") == 0 then
			vim.api.nvim_create_user_command("Markview", function()
				require("render-markdown").toggle()
			end, { desc = "兼容旧的 Markview 切换命令" })
		end
	end,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"mini.icons",
	},
	opts = {
		enabled = true,
		render_modes = { "n", "c" },
		file_types = { "markdown" },
		anti_conceal = {
			enabled = false,
		},
		win_options = {
			conceallevel = {
				default = vim.o.conceallevel,
				rendered = 3,
			},
			concealcursor = {
				default = vim.o.concealcursor,
				rendered = "nc",
			},
		},
		heading = {
			sign = false,
		},
		checkbox = {
			enabled = true,
			render_modes = false,
			bullet = false,
			left_pad = 0,
			right_pad = 1,
			unchecked = {
				icon = "󰄱 ",
				highlight = "RenderMarkdownUnchecked",
				scope_highlight = nil,
			},
			checked = {
				icon = "󰱒 ",
				highlight = "RenderMarkdownChecked",
				scope_highlight = nil,
			},
			custom = {
				todo = { raw = "[/]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
			},
			scope_priority = nil,
		},
		code = {
			sign = false,
		},
	},
}

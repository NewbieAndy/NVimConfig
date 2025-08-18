return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		-- require("tokyonight").setup({
			-- on_highlights = function(hl, c)
			-- 	-- hl.WinSeparator = { fg = "#ff0000", bg = "NONE" }
			-- 	-- 调整补全弹窗背景和选中项，提升对比度
			-- 	hl.Pmenu = { bg = "#22243b", fg = c.fg_dark }
			-- end,
		-- })
		vim.cmd([[colorscheme tokyonight]])
	end,
}

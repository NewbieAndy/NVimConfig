return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("markview").setup({
			-- 使用内部图标提供器
			preview = {
        enable = false,
				icon_provider = "internal", -- 可选 "mini" (需要 mini.icons) 或 "devicons" (需要 nvim-web-devicons)
			},
			-- 启用混合模式，允许编辑时预览
			modes = { "n", "no", "c" },
			hybrid_modes = { "n" },
			-- 自动回调
			callbacks = {
				on_enable = function(_, win)
					vim.wo[win].conceallevel = 2
					vim.wo[win].concealcursor = "c"
				end,
			},
		})
	end,
}

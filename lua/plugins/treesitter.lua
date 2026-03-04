return {
	"nvim-treesitter/nvim-treesitter",
	main = "nvim-treesitter.configs",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"toml",
			"vim",
			"vimdoc",
			"yaml",
			"gitcommit",
			"dockerfile",
			"sql",
		},
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
	},
}

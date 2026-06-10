return {
	{
		"folke/edgy.nvim",
		optional = true,
		opts = function(_, opts)
			opts.right = opts.right or {}
			table.insert(opts.right, {
				ft = "codecompanion",
				title = "CodeCompanion",
				size = { width = 50 },
			})
		end,
	},
}

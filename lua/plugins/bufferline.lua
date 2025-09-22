return {
	"NewbieAndy/bufferline.nvim",
	event = "VeryLazy",
	opts = {
		options = {
      -- stylua: ignore
      close_command = function(n) Snacks.bufdelete(n) end,
			right_mouse_command = function(n)
				Snacks.bufdelete(n)
			end,
			diagnostics = "nvim_lsp",
			always_show_bufferline = false,
			diagnostics_indicator = function(_, _, diag)
				local icons = GlobalUtil.icons.diagnostics
				local ret = (diag.error and icons.Error .. diag.error .. " " or "")
					.. (diag.warning and icons.Warn .. diag.warning or "")
				return vim.trim(ret)
			end,
			offsets = {
				{
					filetype = "snacks_layout_box",
				},
        {
					filetype = "neo-tree",
					text = function()
						local basename = GlobalUtil.root.cwd_basename()
						if basename == "" then
							basename = "ROOT"
						end
						return GlobalUtil.icons.kinds.Apple .. basename
					end,
					highlight = "Directory",
					text_align = "left",
				},
			},
			---@param opts bufferline.IconFetcherOpts
			get_element_icon = function(opts)
				return GlobalUtil.icons.ft[opts.filetype]
			end,
		},
	},
	config = function(_, opts)
		require("bufferline").setup(opts)

		-- Fix bufferline when restoring a session
		vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
			callback = function()
				vim.schedule(function()
					pcall(nvim_bufferline)
				end)
			end,
		})
	end,
}

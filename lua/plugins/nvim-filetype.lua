return {
	"NewbieAndy/nvim-filetype",
	opts = {
		-- Commonly used filetypes, prioritized in the selection queue. Default is empty.
		filetypes = { "json", "python", "java" },
		-- Whether to show all filetypes. If false, only configured filetypes are shown. Default is true.
		show_all_filetypes = true,
		-- Icon for the selected filetype. Default is '*'.
		selected_icon = " ",
	},
}

-- 下载插件管理器
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
--添加rtp
vim.opt.rtp:prepend(lazypath)
--设置leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. 禁用空格键的默认行为（在 VSCode 中特别重要）
vim.keymap.set({'n', 'v'}, '<Space>', '<Nop>', { silent = true })

--启动插件
require("lazy").setup({
	spec = {
		{ import = "vscode-config.plugins" },
	},
	install = {}, -- automatically check for plugin updates
	checker = { enabled = true, notify = false },
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
require("vscode-config.options")
require("vscode-config.keymaps")
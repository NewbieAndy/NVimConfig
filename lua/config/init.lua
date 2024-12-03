-- 下载插件管理器
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
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

--全局工具
_G.GlobalUtil = require("utils")
--启动插件
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "tokyonight", "habamax" } }, -- automatically check for plugin updates
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
--延迟通知
GlobalUtil.lazy_notify()
--加载通用设置
require("config.options")
--加载自动命令
require("config.autocmds")
--加载键盘映射
require("config.keymaps")

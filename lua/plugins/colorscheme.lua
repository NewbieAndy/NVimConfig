return {
  "folke/tokyonight.nvim",
  opts = { style = "moon" },
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme tokyonight]])
  end,
}

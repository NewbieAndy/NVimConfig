return {
  {
    "folke/flash.nvim",
    opts = {
      modes = {
        char = {
          keys = {},
        },
        -- 开启搜索增强
        search = {
          enabled = true,
        },
      },
      prompt = {
        enabled = false,
      }
    },
    keys = function()
      return {
        {
          "f",
          mode = { "n", "x", "o" },
          function()
            require("flash").jump()
          end,
          desc = "Flash",
        },
        {
          "F",
          mode = { "n", "x", "o" },
          function()
            require("flash").treesitter()
          end,
          desc = "Flash Treesitter",
        }
      }
    end,
  },
}

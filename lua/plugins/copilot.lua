return {
  recommended = true,
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    enabled = true,
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = true,
        keymap = {
          accept = false, -- handled by nvim-cmp / blink.cmp
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },

  -- blink.cmp
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      {
        "giuxtaposition/blink-cmp-copilot",
        enabled = vim.g.ai_cmp, -- only enable if needed
        specs = {
          {
            "blink.cmp",
            optional = true,
            opts = {
              sources = {
                providers = {
                  copilot = { name = "copilot", module = "blink-cmp-copilot" },
                },
                completion = {
                  enabled_providers = { "copilot" },
                },
              },
            },
          },
        },
      },
    },
  },
}

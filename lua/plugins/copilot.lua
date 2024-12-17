return {
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
        accept = false,
      },
    },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}

return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",   -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
    -- because `cwd` is not set up properly.
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("Neotree_start_directory", { clear = true }),
      desc = "Start Neo-tree with directory",
      once = true,
      callback = function()
        if package.loaded["neo-tree"] then
          return
        else
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end
      end,
    })
  end,
  opts = {
    sources = { "filesystem" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
    default_component_configs = {
      indent = {
        with_expanders = true,
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      git_status = {
        symbols = {
          unstaged = "󰄱",
          staged = "󰱒",
        },
      },
      name = {
        trailing_slash = false,
        use_git_status_colors = true,
        highlight = "NeoTreeDileame",
      },
    },
    window = {
      mappings = {
        ["<bs>"] = "navigate_up",
        ["H"] = "set_root",
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["o"] = "open",
        ["O"] = {
          function(state)
            require("lazy.util").open(state.tree:get_node().path, { system = true })
          end,
          desc = "系统应用打开",
        },
        ["."] = "toggle_hidden",
        ["<tab>"] = { "preview", config = { use_float = true } },
        ["<C-f>"] = { "scroll_preview", config = { direction = -10 } },
        ["<C-b>"] = { "scroll_preview", config = { direction = 10 } },
        ["<space>"] = "noop",
        -- ["<cr>"] = { "open", config = { expand_nested_files = true } }, -- expand nested file takes precedence
        ["<esc>"] = "cancel",   -- close preview or floating neo-tree window
        ["P"] = "noop",
        ["l"] = "focus_preview",
        ["s"] = "open_split",
        ["v"] = "open_vsplit",
        ["t"] = "noop",
        ["w"] = "noop",
        ["C"] = "noop",
        ["z"] = "close_all_nodes",
        ["R"] = "refresh",
        ["a"] = "add",
        ["A"] = "add_directory",
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
          end,
          desc = "复制文件路径到粘贴板",
        },
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["c"] = "copy",
        ["m"] = "move",
        ["e"] = "noop",
        ["q"] = "noop",
        ["?"] = "show_help",
        ["<"] = "noop",
        [">"] = "noop",
      },
    },
    filesystem = {
      hide_gitignored = false,
      bind_to_cwd = true,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
      window = {
        mappings = {
          ["/"] = "fuzzy_finder",
          ["D"] = "fuzzy_finder_directory",
          ["#"] = "noop",
          ["f"] = "filter_on_submit",
          ["<C-c>"] = "clear_filter",
          ["<C-x>"] = "noop",
          ["<bs>"] = "navigate_up",
          ["[g"] = "noop",
          ["]g"] = "noop",
          ["i"] = "show_file_details",
          ["oc"] = "noop",
          ["od"] = "noop",
          ["og"] = "noop",
          ["om"] = "noop",
          ["on"] = "noop",
          ["os"] = "noop",
          ["ot"] = "noop",
        },
        fuzzy_finder_mappings = {   -- define keymaps for filter popup window in fuzzy_finder_mode
          ["<down>"] = "move_cursor_down",
          ["<up>"] = "move_cursor_up",
        },
      }
    },
  },
  config = function(_, opts)
    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end

    local events = require("neo-tree.events")
    opts.event_handlers = opts.event_handlers or {}
    vim.list_extend(opts.event_handlers, {
      { event = events.FILE_MOVED,   handler = on_move },
      { event = events.FILE_RENAMED, handler = on_move },
    })
    require("neo-tree").setup(opts)
    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit",
      callback = function()
        if package.loaded["neo-tree.sources.git_status"] then
          require("neo-tree.sources.git_status").refresh()
        end
      end,
    })
  end
}

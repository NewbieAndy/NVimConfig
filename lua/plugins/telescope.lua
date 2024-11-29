-- 未处理
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    enabled = true,
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = true,
        config = function(plugin)
          GlobalUtil.on_load("telescope.nvim", function()
            local ok, err = pcall(require("telescope").load_extension, "fzf")
            if not ok then
              local lib = plugin.dir .. "/build/libfzf." .. (GlobalUtil.is_win() and "dll" or "so")
              if not vim.uv.fs_stat(lib) then
                GlobalUtil.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
                require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
                  GlobalUtil.info("Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim.")
                end)
              else
                GlobalUtil.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
              end
            end
          end)
        end,
      },
    },
    keys = function()
      local builtin = require("telescope.builtin");
      return {
        {
          "<leader>,",
          "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
          desc = "切换 Buffer",
        },
        { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "History Commands" },
        { "<leader><space>", builtin.live_grep, desc = "Grep (Root Dir)" },
        -- find
        { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "切换 Buffer" },
        { "<leader>ff", require("telescope.builtin").find_files, desc = "搜索文件" },
        -- { "<leader>fF", require("telescope.builtin").find_files({ root = false }), desc = "当前目录搜索文件" },
        { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
        -- { "<leader>fR", require("telescope.builtin").oldfiles({ cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
        -- git
        { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
        -- { "<leader>gc", require("telescope.builtin").git_commits, desc = "Commits" },
        { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
        -- search
        { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
        { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
        { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
        { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
        { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
        { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
        { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
        { "<leader>sg", require("telescope.builtin").live_grep, desc = "Grep (Root Dir)" },
        -- { "<leader>sG", require("telescope.builtin").live_grep({ root = false }), desc = "Grep (cwd)" },
        { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
        { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
        { "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
        { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
        { "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
        { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
        { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
        { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
        { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
        { "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
        -- { "<leader>sw",  require("telescope.builtin").grep_string({ word_match = "-w" }), desc = "Word (Root Dir)" },
        -- { "<leader>sW",  require("telescope.builtin").grep_string({ root = false, word_match = "-w" }), desc = "Word (cwd)" },
        -- { "<leader>sw",  require("telescope.builtin").grep_string, mode = "v", desc = "Selection (Root Dir)" },
        -- { "<leader>sW",  require("telescope.builtin").grep_string({ root = false }), mode = "v", desc = "Selection (cwd)" },
        -- { "<leader>uC",  require("telescope.builtin").colorscheme({ enable_preview = true }), desc = "Colorscheme with Preview" },
        {
          "<leader>ss",
          function()
            require("telescope.builtin").lsp_document_symbols({
              symbols = GlobalUtil.get_kind_filter(),
            })
          end,
          desc = "Goto Symbol",
        },
        {
          "<leader>sS",
          function()
            require("telescope.builtin").lsp_dynamic_workspace_symbols({
              symbols = GlobalUtil.get_kind_filter(),
            })
          end,
          desc = "Goto Symbol (Workspace)",
        },
      }
    end,
    opts = function()
      local actions = require("telescope.actions")

      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win)
                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
              end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end

      local actions = require("telescope.actions")

      local open_with_trouble = function(...)
        return require("trouble.sources.telescope").open(...)
      end
      -- local find_files_no_ignore = function()
      --   local action_state = require("telescope.actions.state")
      --   local line = action_state.get_current_line()
      --   require("telescope.builtin").find_files({ no_ignore = true, default_text = line })()
      -- end

      -- local find_files_with_hidden = function()
      --   local action_state = require("telescope.actions.state")
      --   local line = action_state.get_current_line()
      --   GlobalUtil.pick("find_files", { hidden = true, default_text = line })()
      -- end

      local function find_command()
        if 1 == vim.fn.executable("rg") then
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        elseif 1 == vim.fn.executable("fd") then
          return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("fdfind") then
          return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
          return { "find", ".", "-type", "f" }
        elseif 1 == vim.fn.executable("where") then
          return { "where", "/r", ".", "*" }
        end
      end

      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          file_ignore_patterns = { "^%.git[/\\]", "[/\\]%.git[/\\]" },
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<c-t>"] = open_with_trouble,
              ["<a-t>"] = open_with_trouble,
              -- ["<a-i>"] = find_files_no_ignore,
              -- ["<a-h>"] = find_files_with_hidden,
              ["<D-k>"] = actions.preview_scrolling_up,
              ["<D-j>"] = actions.preview_scrolling_down,
              ["<D-h>"] = actions.preview_scrolling_left,
              ["<D-l>"] = actions.preview_scrolling_right,
              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,
              ["<M-f>"] = actions.results_scrolling_left,
              ["<M-k>"] = actions.results_scrolling_right,
              ["<c-s>"] = flash
            },
            n = {
              s = flash,
              ["q"] = actions.close,
              ["<D-k>"] = actions.preview_scrolling_up,
              ["<D-j>"] = actions.preview_scrolling_down,
              ["<D-h>"] = actions.preview_scrolling_left,
              ["<D-l>"] = actions.preview_scrolling_right,
              ["h"] = actions.results_scrolling_left,
              ["l"] = actions.results_scrolling_right,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
        },
      }
    end,
  },
  -- better vim.ui with telescope
  {
    "stevearc/dressing.nvim",
    lazy = true,
    enabled = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
}

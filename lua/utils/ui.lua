---@class utils.ui
local M = {}

-- optimized treesitter foldexpr for Neovim >= 0.10.0
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then
      return "0"
    end
    vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

function M.maximize()
  ---@type {k:string, v:any}[]?
  local maximized = nil
  return Snacks.toggle({
    name = "Maximize",
    get = function()
      return maximized ~= nil
    end,
    set = function(state)
      if state then
        maximized = {}
        local function set(k, v)
          table.insert(maximized, 1, { k = k, v = vim.o[k] })
          vim.o[k] = v
        end
        set("winwidth", 999)
        set("winheight", 999)
        set("winminwidth", 10)
        set("winminheight", 4)
        vim.cmd("wincmd =")
        -- `QuitPre` seems to be executed even if we quit a normal window, so we don't want that
        -- `VimLeavePre` might be another consideration? Not sure about differences between the 2
        vim.api.nvim_create_autocmd("ExitPre", {
          once = true,
          group = vim.api.nvim_create_augroup("lazyvim_restore_max_exit_pre", { clear = true }),
          desc = "Restore width/height when close Neovim while maximized",
          callback = function()
            M.maximize.set(false)
          end,
        })
      else
        for _, opt in ipairs(maximized) do
          vim.o[opt.k] = opt.v
        end
        maximized = nil
        vim.cmd("wincmd =")
      end
    end,
  })
end

return M

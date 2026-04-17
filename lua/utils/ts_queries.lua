local M = {}

-- Load all .scm query files under given directory.
-- Expected layout: <dir>/<lang>/*.scm
-- For each file, call require('nvim-treesitter.query').set_query(lang, group, content)
-- path may be absolute or contain ~; this function expands it.
---@param dir string
function M.load_dir(dir)
  if not dir or dir == '' then
    return
  end
  local path = vim.fn.expand(dir)
  if vim.fn.isdirectory(path) == 0 then
    return
  end

  local ts_query = require('nvim-treesitter.query')

  -- glob for files like /path/lang/group.scm
  local files = vim.fn.globpath(path, '*/*.scm', true, true)
  for _, f in ipairs(files) do
    -- extract lang and group name
    -- pattern: /.../<lang>/<group>.scm
    local lang, group = string.match(f, path .. '/([^/]+)/([^/]+)%.scm$')
    if not lang then
      -- fallback: try generic capture
      lang, group = string.match(f, '.*/([^/]+)/([^/]+)%.scm$')
    end
    if lang and group then
      local content = table.concat(vim.fn.readfile(f), '\n')
      -- set_query replaces existing query for the given group
      pcall(ts_query.set_query, lang, group, content)
    end
  end
end

return M

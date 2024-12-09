-- 使用 plenary.nvim 的路径功能
-- local Path = require('plenary.path')
-- vim.notify("open running..")
local M = {}

-- -- 自定义路径补全函数
-- function M.CustomPathComplete(arg_lead, cmd_line, cursor_pos)
--   local dir = arg_lead == '' and '.' or arg_lead
--   local p = Path:new(dir)
--   local items = {}
--   if p:is_dir() then
--     for _, child in ipairs(p:iter()) do
--       table.insert(items, tostring(child))
--     end
--   end
--   return items
-- end

function M.completeion()
   vim.notify("completion....")
end

function M.submit()
   vim.notify("submit....")
end

function M.show_box()
  -- 创建一个新的 buffer
  -- local buf = vim.api.nvim_create_buf(false, true)
  -- vim.notify("vim buf".. buf)
  -- -- 获取当前窗口大小
  -- local width = vim.api.nvim_get_option("columns")
  -- local height = vim.api.nvim_get_option("lines")
  -- -- 计算输入框的大小和位置
  -- local win_width = math.ceil(width * 0.5)
  -- local win_height = 1
  -- local row = math.ceil((height - win_height) / 2)
  -- local col = math.ceil((width - win_width) / 2)

  -- 创建一个浮动窗口
  -- local win = vim.api.nvim_open_win(buf, true, {
  --   relative = 'editor',
  --   width = win_width,
  --   height = win_height,
  --   row = row,
  --   col = col,
  --   style = 'minimal'
  -- })
  --
  -- 设置输入框的键盘映射
  -- vim.api.nvim_buf_set_keymap(buf, 'i', '<Tab>', ':lua require("utils").completion()<CR>', {noremap = true, silent = true})
  -- vim.api.nvim_buf_set_keymap(buf, 'i', '<Tab>', ':lua vim.notify("hello world") <CR>', {noremap = true, silent = false})
  -- vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', ':lua require("utils").submit()<CR>', {noremap = true, silent = true})
  -- vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')
  -- vim.fn.prompt_setprompt(buf, 'Path: ')
  -- vim.cmd('startinsert')
  vim.ui.input({prompt = "File Path:",completion = "dir"},function (input)
    vim.notify("input:"..input)
  end)
end

function M.test()
  vim.notify("open test running..")
  M.show_box()
end
-- 示例用法：绑定到快捷键
return M

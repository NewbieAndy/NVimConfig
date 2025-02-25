local option = vim.opt
 -- 与系统剪贴板同步
vim.opt.clipboard = "unnamedplus"
 -- 使用空格代替制表符
vim.opt.expandtab = true
--启用鼠标
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true -- Don't ignore case with capitals
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.opt.timeoutlen = 500-- Lower than default (1000) to quickly trigger which-key
vim.opt.updatetime = 300 -- Save swap file and trigger CursorHold

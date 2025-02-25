vim.keymap.set('n', '<leader><space>', function()
    -- 调用 VSCode 的快速打开命令
    vim.fn.VSCodeNotify('workbench.action.quickOpen')
end, { silent = true, desc = "Quick Open File (like Cmd+P)" })
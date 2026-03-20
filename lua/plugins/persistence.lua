-- TODO: 未处理
return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
        { "<leader>Ss", function() require("persistence").load() end,                desc = "Restore Session" },
        { "<leader>SS", function() require("persistence").select() end,              desc = "Select Session" },
        { "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
        { "<leader>Sd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
    },
    config = function(_, opts)
        require("persistence").setup(opts)

        local function kill_dir_bufs()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_is_valid(buf) then
                    local name = vim.api.nvim_buf_get_name(buf)
                    if name ~= "" and vim.fn.isdirectory(name) == 1 then
                        pcall(vim.api.nvim_buf_delete, buf, { force = true })
                    end
                end
            end
        end

        -- 保存前清除目录 buffer，避免写入 session 文件
        vim.api.nvim_create_autocmd("User", {
            pattern = "PersistenceSavePre",
            callback = kill_dir_bufs,
        })

        -- 加载后清除目录 buffer，兜底旧 session 文件中残留的目录 buffer
        vim.api.nvim_create_autocmd("User", {
            pattern = "PersistenceLoadPost",
            callback = function()
                vim.schedule(kill_dir_bufs)
            end,
        })
    end,
}

return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {
		-- 至少打开 1 个文件 buffer 才保存 session（避免保存空会话）
		need = 1,
		-- 按 git branch 区分 session，同一项目不同分支独立保存
		branch = true,
	},
	-- stylua: ignore
	keys = {
		{ "<leader>Ss", function() require("persistence").load() end,                desc = "恢复当前目录 Session" },
		{ "<leader>SS", function() require("persistence").select() end,              desc = "选择 Session" },
		{ "<leader>Sl", function() require("persistence").load({ last = true }) end, desc = "恢复上次 Session" },
		{ "<leader>Sd", function() require("persistence").stop() end,                desc = "本次退出不保存 Session" },
	},
	config = function(_, opts)
		require("persistence").setup(opts)

		-- 清理不应写入 session 的 buffer（目录 buffer、无名 buffer 等）
		local function clean_bufs_before_save()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if not vim.api.nvim_buf_is_valid(buf) then
					goto continue
				end
				local name = vim.api.nvim_buf_get_name(buf)
				local bt = vim.bo[buf].buftype
				-- 目录 buffer：vim 会把目录当普通文件打开，sessionoptions 无法过滤
				local is_dir = name ~= "" and vim.fn.isdirectory(name) == 1
				-- nofile / nowrite / terminal buftype 不应被 mksession 保存
				local is_tmp = bt == "nofile" or bt == "nowrite" or bt == "terminal"
				if is_dir or is_tmp then
					pcall(vim.api.nvim_buf_delete, buf, { force = true })
				end
				::continue::
			end
		end

		-- 保存前清理，确保脏 buffer 不写入 .vim session 文件
		vim.api.nvim_create_autocmd("User", {
			pattern = "PersistenceSavePre",
			callback = clean_bufs_before_save,
		})

		-- 加载后清理，兜底旧 session 文件中已保存的脏 buffer
		vim.api.nvim_create_autocmd("User", {
			pattern = "PersistenceLoadPost",
			callback = function()
				vim.schedule(clean_bufs_before_save)
			end,
		})
	end,
}

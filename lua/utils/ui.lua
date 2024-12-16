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

function M.close()
	-- 获取当前窗口，当前buffer
	local cur_win = vim.api.nvim_get_current_win()
	local cur_buf = vim.api.nvim_get_current_buf()
	-- 当前buf的buftype
	local cur_buftype = vim.api.nvim_buf_get_option(cur_buf, "buftype")
	if cur_buftype ~= "" then
		--执行:q退出
		vim.cmd([[q]])
		return
	end
	-- 所以的缓冲区
	local bufs = vim.api.nvim_list_bufs()
	--普通缓冲区列表
	local normal_bufs = {}
	for _, buf in ipairs(bufs) do
		local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
		if buftype == "" then
			table.insert(normal_bufs, buf)
		end
	end

	-- 当前窗口的buffer 打开窗口数量
	local cur_buf_win_count = 0
	-- 普通buffer的窗口数量
	local normal_buf_win_count = 0
	-- 获取当前所有窗口
	local wins = vim.api.nvim_list_wins()
	-- 遍历窗口
	for _, win in ipairs(wins) do
		-- 获取窗口的 buffer
		local buf = vim.api.nvim_win_get_buf(win)
		-- 获取buffer的buftype
		local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
		if buftype == "" then
			normal_buf_win_count = normal_buf_win_count + 1
			if buf == cur_buf then
				cur_buf_win_count = cur_buf_win_count + 1
			end
		end
	end
	-- buffer在多个窗口打开，关闭窗口不关闭buffer
	if 1 < cur_buf_win_count then
		-- 仅关闭当前窗口,不关闭buffer
		vim.api.nvim_win_close(cur_win, true)
	elseif 1 == cur_buf_win_count then
		--关闭当前buffer
		Snacks.bufdelete(cur_buf)
		if 1 < normal_buf_win_count then
			--关闭当前窗口
			vim.api.nvim_win_close(cur_win, true)
		end
	end
end

return M

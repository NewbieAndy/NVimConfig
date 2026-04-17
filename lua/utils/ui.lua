---@class utils.ui
--- UI 相关工具函数模块
--- 提供折叠、窗口管理等 UI 功能
local M = {}

--- 注意：close() 内置健壮性处理，在缺少 Snacks 时自动回退到内置 bdelete

--- 优化的 Treesitter 折叠表达式
--- 为 Neovim >= 0.10.0 提供更好的折叠性能
--- @return string 返回折叠级别字符串
--- 
--- 优化点：
--- 1. 使用缓存避免重复检查 treesitter 可用性
--- 2. 提前返回，避免不必要的计算
function M.foldexpr()
	local buf = vim.api.nvim_get_current_buf()
	
	-- 缓存 treesitter 可用性检查结果
	if vim.b[buf].ts_folds == nil then
		-- 如果还没有文件类型，不检查 treesitter（肯定不可用）
		if vim.bo[buf].filetype == "" then
			return "0"
		end
		-- 检查是否有可用的 treesitter 解析器
		vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
	end
	
	return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

--- 智能关闭缓冲区或窗口
--- 根据缓冲区类型和窗口数量智能决定关闭行为：
--- - 对于特殊缓冲区（如帮助、终端等），直接关闭窗口
--- - 对于普通缓冲区：
---   - 如果在多个窗口中打开，只关闭当前窗口
---   - 如果只在当前窗口打开，关闭缓冲区
---   - 如果是最后一个普通窗口，同时关闭窗口
--- 
--- 优化点：
--- 1. 添加了详细的逻辑说明
--- 2. 改进了变量命名以提高可读性
--- 3. 优化了窗口和缓冲区的统计逻辑
function M.close()
	local current_win = vim.api.nvim_get_current_win()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_buftype = vim.bo[current_buf].buftype
	
	-- 特殊类型的缓冲区（如帮助、终端等），直接关闭窗口
	if current_buftype ~= "" then
		vim.cmd([[q]])
		return
	end
	
	-- 收集所有普通缓冲区（buftype 为空）
	local all_bufs = vim.api.nvim_list_bufs()
	local normal_bufs = {}
	for _, buf in ipairs(all_bufs) do
		if vim.bo[buf].buftype == "" then
			table.insert(normal_bufs, buf)
		end
	end

	-- 统计窗口信息
	local current_buf_win_count = 0  -- 当前缓冲区打开的窗口数
	local normal_buf_win_count = 0   -- 所有普通缓冲区的窗口总数
	
	local all_wins = vim.api.nvim_list_wins()
	for _, win in ipairs(all_wins) do
		local buf = vim.api.nvim_win_get_buf(win)
		local buftype = vim.bo[buf].buftype
		
		if buftype == "" then
			normal_buf_win_count = normal_buf_win_count + 1
			if buf == current_buf then
				current_buf_win_count = current_buf_win_count + 1
			end
		end
	end
	
	-- 决定关闭行为
	if current_buf_win_count > 1 then
		-- 当前缓冲区在多个窗口中打开，只关闭当前窗口
		vim.api.nvim_win_close(current_win, true)
	elseif current_buf_win_count == 1 then
		-- 当前缓冲区只在当前窗口打开
		-- 关闭缓冲区
		-- 安全删除缓冲区：优先使用 Snacks.bufdelete，不存在则回退到内置命令
		if GlobalUtil.has("snacks.nvim") and pcall(require, "snacks") then
			Snacks.bufdelete(current_buf)
		else
			vim.cmd(("bdelete! %d"):format(current_buf))
		end
		
		-- 如果还有其他普通窗口，也关闭当前窗口
		if normal_buf_win_count > 1 then
			vim.api.nvim_win_close(current_win, true)
		end
	end
end

return M

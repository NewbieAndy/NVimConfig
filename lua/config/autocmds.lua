--创建分组
local function augroup(name)
	return vim.api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- 离开插入模式后自动保存
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
	group = augroup("auto_save"),
	pattern = "*",
	command = "silent! write",
})

local previous_input_method = ""
-- 离开插入模式自动切换到英文输入法
local auto_switch_input_method_group = augroup("auto_switch_input_method")
-- 获取当前输入法
function get_and_cache_current_input_method()
	local ok, handle = pcall(function()
		return io.popen('hs -c "getCurrentInputMetho1d()"')
	end)

	if not ok then
		return nil
	end
	-- vim.notify("current_input_method handle:" .. vim.inspect(handle))
	local result = handle:read("*a")
	vim.notify("result process," .. result)
	-- vim.notify("current_input_method result:" .. vim.inspect(result))
	handle:close()
	local current_input_method = ''
	if result and "" ~= result then
		vim.notify("result process," .. result)
		local lines = vim.split(result, "\n", { trimempty = true })
		current_input_method = lines[#lines]
	end
	return current_input_method
end
--
-- -- 缓存当前输入法
-- function CacheCurrentInputMethod()
--     previous_input_method = GetCurrentInputMethod()
-- end
--
-- -- 恢复之前的输入法
-- function RestorePreviousInputMethod()
--     if previous_input_method ~= "" then
--         local command = 'osascript -e \'tell application "System Events" to set input method of current input source to "' .. previous_input_method .. '"\''
--         os.execute(command)
--     end
-- end
--
-- -- 设置自动命令
-- vim.api.nvim_exec([[
--     augroup InputMethod
--         autocmd!
--         autocmd InsertEnter * lua CacheCurrentInputMethod()
--         autocmd InsertLeave * lua RestorePreviousInputMethod()
--     augroup END
-- ]], false)

-- vim.api.nvim_create_autocmd({ "InsertLeave"}, {
-- 	group = auto_switch_input_method_group,
-- 	pattern = "*",
--   callback = function()
--     --记录当前输入法
--     --切换到英文
--     os.execute('open "hammerspoon://switchInputMethod2ABC"')
--   end,
-- })

--判断是否需要重新加载
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})
--
-- y复制是高亮
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

--分屏重置标签大小
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

--光标自动回复上次关闭的位置
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc_flag then
			return
		end
		vim.b[buf].last_loc_flag = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- q直接退出部分缓冲区
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"snacks_win",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

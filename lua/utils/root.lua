---@class utils.root
--- 项目根目录检测工具
--- 提供多种策略检测项目根目录：LSP、文件模式、当前工作目录等
---@overload fun(): string
local M = setmetatable({}, {
	__call = function(m)
		return m.get()
	end,
})

---@class LazyRoot
---@field paths string[] 检测到的根目录路径列表
---@field spec LazyRootSpec 使用的检测规范

---@alias LazyRootFn fun(buf: number): (string|string[])

---@alias LazyRootSpec string|string[]|LazyRootFn

--- 根目录检测规范列表
--- 按优先级从高到低排列：
--- 1. "lsp" - 使用 LSP 服务器的工作目录
--- 2. {".git", "lua"} - 查找包含这些文件/目录的父目录
--- 3. "cwd" - 使用当前工作目录
---@type LazyRootSpec[]
M.spec = { "lsp", { ".git", "lua" }, "cwd" }

--- 根目录检测器集合
M.detectors = {}

--- 缓存的项目根路径
M.root_path = nil

--- 重新加载根目录路径
--- @param path string|nil 指定的路径，如果为 nil 则使用当前工作目录
--- 
--- 优化点：添加了路径验证
function M.reload_root_path(path)
  -- 验证路径是否存在
  if path and vim.uv.fs_stat(path) then
    M.root_path = M.realpath(path)
  else
    M.root_path = M.realpath(vim.uv.cwd())
  end
end

--- 当前工作目录检测器
--- @return string[] 返回当前工作目录
function M.detectors.cwd()
	return { vim.uv.cwd() }
end

--- LSP 工作目录检测器
--- 从附加到缓冲区的 LSP 客户端获取根目录
--- @param buf number 缓冲区编号
--- @return string[] 返回检测到的根目录列表
--- 
--- 优化点：
--- 1. 添加了空值检查
--- 2. 简化了过滤逻辑
function M.detectors.lsp(buf)
	local bufpath = M.bufpath(buf)
	if not bufpath then
		return {}
	end
	
	local roots = {} ---@type string[]
	local clients = GlobalUtil.lsp.get_clients({ bufnr = buf })
	
	-- 过滤掉被忽略的 LSP 客户端
	clients = vim.tbl_filter(function(client)
		return not vim.tbl_contains(vim.g.root_lsp_ignore or {}, client.name)
	end, clients)
	
	-- 收集所有客户端的根目录
	for _, client in pairs(clients) do
		-- 从 workspace_folders 获取
		local workspace = client.config.workspace_folders
		if workspace then
			for _, ws in pairs(workspace) do
				roots[#roots + 1] = vim.uri_to_fname(ws.uri)
			end
		end
		
		-- 从 root_dir 获取
		if client.root_dir then
			roots[#roots + 1] = client.root_dir
		end
	end
	
	-- 过滤出包含当前文件的根目录
	return vim.tbl_filter(function(path)
		path = GlobalUtil.norm(path)
		return path and bufpath:find(path, 1, true) == 1
	end, roots)
end

--- 文件模式检测器
--- 向上查找包含指定文件或模式的目录
--- @param buf number 缓冲区编号
--- @param patterns string|string[] 要查找的文件名或模式列表
--- @return string[] 返回找到的根目录列表
--- 
--- 优化点：
--- 1. 改进了模式匹配逻辑
--- 2. 添加了通配符支持的说明
function M.detectors.pattern(buf, patterns)
	patterns = type(patterns) == "string" and { patterns } or patterns
	local path = M.bufpath(buf) or vim.uv.cwd()
	
	-- 向上查找匹配的文件或目录
	local pattern = vim.fs.find(function(name)
		for _, p in ipairs(patterns) do
			-- 精确匹配
			if name == p then
				return true
			end
			-- 通配符匹配（以 * 开头）
			if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
				return true
			end
		end
		return false
	end, { path = path, upward = true })[1]
	
	return pattern and { vim.fs.dirname(pattern) } or {}
end

--- 获取缓冲区的真实文件路径
--- @param buf number 缓冲区编号
--- @return string|nil 返回规范化的文件路径，如果无效则返回 nil
function M.bufpath(buf)
	return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

--- 获取缓存的根目录
--- @return string|nil 返回根目录路径
function M.root()
	return M.root_path
end

--- 获取当前工作目录
--- @return string 返回规范化的当前工作目录
function M.cwd()
	return M.realpath(vim.uv.cwd()) or ""
end

--- 获取当前工作目录的基本名称
--- @return string 返回目录名称（不含路径）
function M.cwd_basename()
	local cwd = M.cwd()
	return vim.fn.fnamemodify(cwd, ":t")
end

--- 获取路径的真实路径
--- 解析符号链接并规范化路径
--- @param path string|nil 输入路径
--- @return string|nil 返回真实路径，如果路径无效则返回 nil
--- 
--- 优化点：添加了空字符串的检查
function M.realpath(path)
	if path == "" or path == nil then
		return nil
	end
	
	path = vim.uv.fs_realpath(path) or path
	return GlobalUtil.norm(path)
end

--- 解析根目录检测规范
--- 将规范转换为检测函数
--- @param spec LazyRootSpec 检测规范
--- @return LazyRootFn 返回检测函数
function M.resolve(spec)
	-- 预定义的检测器
	if M.detectors[spec] then
		return M.detectors[spec]
	end
	
	-- 自定义函数
	if type(spec) == "function" then
		return spec
	end
	
	-- 文件模式检测器
	return function(buf)
		return M.detectors.pattern(buf, spec)
	end
end

--- 检测项目根目录
--- 使用多种策略检测，返回所有匹配的根目录
--- @param opts table|nil 选项
---   - buf: 缓冲区编号，默认为当前缓冲区
---   - spec: 检测规范列表，默认使用 M.spec
---   - all: 是否返回所有匹配的根目录，默认 false 只返回第一个
--- @return LazyRoot[] 返回检测到的根目录列表
--- 
--- 优化点：
--- 1. 改进了选项处理
--- 2. 添加了更清晰的注释
function M.detect(opts)
	opts = opts or {}
	opts.spec = opts.spec or type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
	opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

	local results = {} ---@type LazyRoot[]
	
	for _, spec in ipairs(opts.spec) do
		-- 执行检测函数
		local paths = M.resolve(spec)(opts.buf)
		paths = paths or {}
		paths = type(paths) == "table" and paths or { paths }
		
		-- 规范化并去重路径
		local roots = {} ---@type string[]
		for _, p in ipairs(paths) do
			local pp = M.realpath(p)
			if pp and not vim.tbl_contains(roots, pp) then
				roots[#roots + 1] = pp
			end
		end
		
		-- 按路径长度降序排序（更深的路径优先）
		table.sort(roots, function(a, b)
			return #a > #b
		end)
		
		if #roots > 0 then
			results[#results + 1] = { spec = spec, paths = roots }
			-- 如果不需要所有结果，找到第一个就返回
			if opts.all == false then
				break
			end
		end
	end
	
	return results
end

--- 显示根目录检测信息
--- 在浮动窗口中显示所有检测到的根目录及其优先级
--- @return string 返回最高优先级的根目录路径
function M.info()
	local spec = type(vim.g.root_spec) == "table" and vim.g.root_spec or M.spec
	local roots = M.detect({ all = true })
	local lines = {} ---@type string[]
	local first = true
	
	-- 格式化输出每个检测到的根目录
	for _, root in ipairs(roots) do
		for _, path in ipairs(root.paths) do
			lines[#lines + 1] = ("- [%s] `%s` **(%s)**"):format(
				first and "x" or " ",
				path,
				type(root.spec) == "table" and table.concat(root.spec, ", ") or root.spec
			)
			first = false
		end
	end
	
	-- 显示当前配置
	lines[#lines + 1] = "```lua"
	lines[#lines + 1] = "vim.g.root_spec = " .. vim.inspect(spec)
	lines[#lines + 1] = "```"
	
	GlobalUtil.info(lines, { title = "LazyVim Roots" })
	return roots[1] and roots[1].paths[1] or vim.uv.cwd()
end

--- 根目录缓存
--- 缓存每个缓冲区检测到的根目录，避免重复检测
---@type table<number, string>
M.cache = {}

--- 获取项目根目录
--- 基于以下策略（按优先级）：
--- 1. LSP 工作目录
--- 2. 当前文件的根目录（通过文件模式检测）
--- 3. 当前工作目录
--- @param opts table|nil 选项
---   - normalize: 是否规范化路径
---   - buf: 缓冲区编号
--- @return string 返回检测到的根目录路径
--- 
--- 优化点：
--- 1. 添加了缓存机制
--- 2. 改进了选项处理
function M.get(opts)
	opts = opts or {}
	local buf = opts.buf or vim.api.nvim_get_current_buf()
	local cached = M.cache[buf]
	
	if not cached then
		local roots = M.detect({ all = false, buf = buf })
		cached = roots[1] and roots[1].paths[1] or vim.uv.cwd()
		M.cache[buf] = cached
	end
	
	return cached
end

--- 获取 Git 仓库根目录
--- 从当前根目录向上查找 .git 目录
--- @return string 返回 Git 仓库根目录，如果未找到则返回当前根目录
function M.git()
	local root = M.get()
	local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
	return git_root and vim.fn.fnamemodify(git_root, ":h") or root
end

return M

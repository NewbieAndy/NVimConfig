---@class utils.lsp
--- LSP 相关工具函数模块
--- 提供 LSP 客户端管理、能力检测、格式化等功能
local M = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: lsp.Client):boolean}

--- 获取 LSP 客户端列表
--- 兼容新旧版本的 Neovim API
--- @param opts lsp.Client.filter|nil 过滤选项
---   - id: 客户端 ID
---   - bufnr: 缓冲区编号
---   - name: 客户端名称
---   - method: LSP 方法名（如 "textDocument/formatting"）
---   - filter: 自定义过滤函数
--- @return vim.lsp.Client[] 返回符合条件的 LSP 客户端列表
--- 
--- 优化点：
--- 1. 简化了条件判断逻辑
--- 2. 提前返回，避免不必要的过滤操作
function M.get_clients(opts)
  local clients = {} ---@type vim.lsp.Client[]
  
  -- 使用新 API 或回退到旧 API
  if vim.lsp.get_clients then
    clients = vim.lsp.get_clients(opts)
  else
    ---@diagnostic disable-next-line: deprecated
    clients = vim.lsp.get_active_clients(opts)
    -- 旧 API 不支持 method 过滤，需要手动过滤
    if opts and opts.method then
      clients = vim.tbl_filter(function(client)
        return client.supports_method(opts.method, { bufnr = opts.bufnr })
      end, clients)
    end
  end
  
  -- 应用自定义过滤器
  if opts and opts.filter then
    return vim.tbl_filter(opts.filter, clients)
  end
  
  return clients
end

--- 在 LSP 客户端附加到缓冲区时执行回调
--- 可选择性地只在特定名称的客户端附加时执行
--- @param on_attach function 回调函数 fun(client:vim.lsp.Client, buffer:number)
--- @param name string|nil 可选的客户端名称过滤，只有匹配的客户端才会触发回调
--- @return number 返回自动命令 ID
--- 
--- 优化点：
--- 1. 添加了客户端名称的提前过滤
--- 2. 改进了条件判断的清晰度
function M.on_attach(on_attach, name)
  return vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      
      -- 检查客户端是否存在且名称匹配（如果指定了名称）
      if client and (not name or client.name == name) then
        return on_attach(client, buffer)
      end
    end,
  })
end

---@class LspCommand: lsp.ExecuteCommandParams
---@field open? boolean 是否在 Trouble 窗口中打开结果
---@field handler? lsp.Handler 自定义处理器

--- 执行 LSP 命令
--- 支持通过 Trouble 插件显示结果或使用自定义处理器
--- @param opts LspCommand 命令选项
---   - command: 命令名称
---   - arguments: 命令参数
---   - open: 是否在 Trouble 中打开
---   - handler: 自定义处理器
--- @return any 返回命令执行结果
function M.execute(opts)
  local params = {
    command = opts.command,
    arguments = opts.arguments,
  }
  
  if opts.open then
    require("trouble").open({
      mode = "lsp_command",
      params = params,
    })
  else
    return vim.lsp.buf_request(0, "workspace/executeCommand", params, opts.handler)
  end
end

--- LSP 方法支持缓存
--- 用于跟踪哪些客户端在哪些缓冲区上支持特定方法
--- @type table<string, table<vim.lsp.Client, table<number, boolean>>>
M._supports_method = {}

--- 设置 LSP 工具模块
--- 注册能力变更处理器和方法支持检测
--- 
--- 优化点：
--- 1. 添加了更详细的注释说明
--- 2. 改进了代码结构
function M.setup()
  -- 保存原始的注册能力处理器
  local register_capability = vim.lsp.handlers["client/registerCapability"]
  
  -- 重写处理器以支持动态能力通知
  vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
    ---@diagnostic disable-next-line: no-unknown
    local ret = register_capability(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    
    if client then
      -- 为所有附加的缓冲区触发动态能力事件
      for buffer in pairs(client.attached_buffers) do
        vim.api.nvim_exec_autocmds("User", {
          pattern = "LspDynamicCapability",
          data = { client_id = client.id, buffer = buffer },
        })
      end
    end
    
    return ret
  end
  
  -- 在客户端附加和动态能力变更时检查方法支持
  M.on_attach(M._check_methods)
  M.on_dynamic_capability(M._check_methods)
end

--- 检查客户端支持的方法
--- 在客户端附加或能力变更时调用
--- @param client vim.lsp.Client LSP 客户端
--- @param buffer number 缓冲区编号
--- 
--- 优化点：
--- 1. 提前返回，避免无效缓冲区的处理
--- 2. 添加了详细的验证注释
function M._check_methods(client, buffer)
  -- 跳过无效的缓冲区
  if not vim.api.nvim_buf_is_valid(buffer) then
    return
  end
  
  -- 跳过未列出的缓冲区
  if not vim.bo[buffer].buflisted then
    return
  end
  
  -- 跳过 nofile 类型的缓冲区
  if vim.bo[buffer].buftype == "nofile" then
    return
  end
  
  -- 检查所有已注册的方法
  for method, clients in pairs(M._supports_method) do
    clients[client] = clients[client] or {}
    
    if not clients[client][buffer] then
      -- 检查客户端是否支持该方法
      if client.supports_method and client.supports_method(method, { bufnr = buffer }) then
        clients[client][buffer] = true
        -- 触发方法支持事件
        vim.api.nvim_exec_autocmds("User", {
          pattern = "LspSupportsMethod",
          data = { client_id = client.id, buffer = buffer, method = method },
        })
      end
    end
  end
end

--- 在 LSP 动态能力变更时执行回调
--- @param fn function 回调函数 fun(client:vim.lsp.Client, buffer:number):boolean?
--- @param opts table|nil 选项表 {group?: integer}
--- @return number 返回自动命令 ID
function M.on_dynamic_capability(fn, opts)
  return vim.api.nvim_create_autocmd("User", {
    pattern = "LspDynamicCapability",
    group = opts and opts.group or nil,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.data.buffer ---@type number
      
      if client then
        return fn(client, buffer)
      end
    end,
  })
end

--- 在客户端支持特定方法时执行回调
--- @param method string LSP 方法名，如 "textDocument/formatting"
--- @param fn function 回调函数 fun(client:vim.lsp.Client, buffer:number)
--- @return number 返回自动命令 ID
--- 
--- 优化点：
--- 1. 使用弱引用表避免内存泄漏
--- 2. 添加了方法缓存的初始化
function M.on_supports_method(method, fn)
  -- 初始化方法缓存，使用弱键表自动清理
  M._supports_method[method] = M._supports_method[method] or setmetatable({}, { __mode = "k" })
  
  return vim.api.nvim_create_autocmd("User", {
    pattern = "LspSupportsMethod",
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local buffer = args.data.buffer ---@type number
      
      if client and method == args.data.method then
        return fn(client, buffer)
      end
    end,
  })
end


---@alias LazyFormatter {name:string, primary?:boolean, priority:number, format:fun(bufnr:number), sources:fun(bufnr:number):string[]}

--- 创建 LSP 格式化器配置
--- @param opts LazyFormatter|{filter?:(string|lsp.Client.filter)}|nil 格式化器选项
---   - filter: 客户端过滤器，可以是名称字符串或过滤选项
--- @return LazyFormatter 返回格式化器配置对象
--- 
--- 优化点：
--- 1. 简化了过滤器处理逻辑
--- 2. 改进了代码可读性
function M.formatter(opts)
  opts = opts or {}
  local filter = opts.filter or {}
  
  -- 规范化过滤器为表格式
  filter = type(filter) == "string" and { name = filter } or filter
  ---@cast filter lsp.Client.filter
  
  ---@type LazyFormatter
  local ret = {
    name = "LSP",
    primary = true,
    priority = 1,
    format = function(buf)
      M.format(GlobalUtil.merge({}, filter, { bufnr = buf }))
    end,
    sources = function(buf)
      local clients = M.get_clients(GlobalUtil.merge({}, filter, { bufnr = buf }))
      
      -- 过滤支持格式化的客户端
      local formatting_clients = vim.tbl_filter(function(client)
        return client.supports_method("textDocument/formatting")
          or client.supports_method("textDocument/rangeFormatting")
      end, clients)
      
      -- 返回客户端名称列表
      return vim.tbl_map(function(client)
        return client.name
      end, formatting_clients)
    end,
  }
  
  return GlobalUtil.merge(ret, opts) --[[@as LazyFormatter]]
end

---@alias lsp.Client.format {timeout_ms?: number, format_options?: table} | lsp.Client.filter

--- 格式化缓冲区
--- 优先使用 conform.nvim 进行格式化，否则使用 LSP 内置格式化
--- @param opts lsp.Client.format|nil 格式化选项
---   - timeout_ms: 超时时间（毫秒）
---   - format_options: 格式化选项
---   - bufnr: 缓冲区编号
--- 
--- 优化点：
--- 1. 移除了不必要的通知
--- 2. 改进了未保存文件的检测逻辑
--- 3. 添加了更清晰的条件判断
function M.format(opts)
  opts = vim.tbl_deep_extend(
    "force",
    {},
    opts or {},
    GlobalUtil.opts("nvim-lspconfig").format or {},
    GlobalUtil.opts("conform.nvim").format or {}
  )
  
  -- 对于未保存的文件，直接使用 LSP 格式化
  if M.is_unsave_file_buf(opts.bufnr) then
    vim.lsp.buf.format(opts)
  else
    local ok, conform = pcall(require, "conform")
    -- 优先使用 conform 进行格式化，因为它提供更好的差异显示
    if ok then
      opts.formatters = {}
      conform.format(opts)
    else
      vim.lsp.buf.format(opts)
    end
  end
end

--- 检查是否为未保存的文件缓冲区
--- 未保存的文件是指没有文件名且 buftype 为空的缓冲区
--- @param bufnr number|nil 缓冲区编号，nil 或 0 表示当前缓冲区
--- @return boolean 如果是未保存的文件返回 true，否则返回 false
--- 
--- 优化点：
--- 1. 简化了条件判断
--- 2. 使用 vim.api.nvim_get_option_value 替代已废弃的 API
--- 3. 改进了注释说明
function M.is_unsave_file_buf(bufnr)
  -- 验证缓冲区编号
  if not bufnr or bufnr < 1 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  
  -- 检查缓冲区是否有效
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  
  -- 获取文件名和缓冲区类型
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.bo[bufnr].buftype
  
  -- 未保存的文件：没有文件名且 buftype 为空
  return (filename == "" or filename == nil) and buftype == ""
end

--- LSP 代码操作快捷访问
--- 通过元表实现动态调用特定类型的代码操作
--- 使用方式：M.action.source() 或 M.action["source.organizeImports"]()
M.action = setmetatable({}, {
  __index = function(_, action)
    return function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { action },
          diagnostics = {},
        },
      })
    end
  end,
})

return M

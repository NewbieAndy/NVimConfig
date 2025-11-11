-- 代码格式化
local M = {}

M.formatters_by_ft = {
	lua = { "stylua" },
	fish = { "fish_indent" },
	sh = { "shfmt" },
	css = { "prettier" },
	graphql = { "prettier" },
	handlebars = { "prettier" },
	html = { "prettier" },
	javascript = { "prettier" },
	javascriptreact = { "prettier" },
	json = { "prettier", "jq" },
	jsonc = { "prettier" },
	less = { "prettier" },
	scss = { "prettier" },
	typescript = { "prettier" },
	typescriptreact = { "prettier" },
	vue = { "prettier" },
	yaml = { "prettier" },
	markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
	["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
	java = { "google-java-format" },
}

function M.has_prettier_config(ctx)
	vim.fn.system({ "prettier", "--find-config-path", ctx.filename })
	return vim.v.shell_error == 0
end

function M.is_support_prettier_ft(ft)
	for k, v in pairs(M.formatters_by_ft) do
		if k == ft and vim.tbl_contains(v, "prettier") then
			return true
		end
	end
	return false
end

--- Checks if a parser can be inferred for the given context:
--- * If the filetype is in the supported list, return true
--- * Otherwise, check if a parser can be inferred
function M.has_prettier_parser(ctx)
	local ret = vim.fn.system({ "prettier", "--file-info", ctx.filename })
	---@type boolean, string?
	local ok, parser = pcall(function()
		return vim.fn.json_decode(ret).inferredParser
	end)
	return ok and parser and parser ~= vim.NIL
end

M.is_support_prettier_ft = GlobalUtil.memoize(M.is_support_prettier_ft)
M.has_prettier_config = GlobalUtil.memoize(M.has_prettier_config)
M.has_prettier_parser = GlobalUtil.memoize(M.has_prettier_parser)

return {
	"stevearc/conform.nvim",
	dependencies = { "mason.nvim" },
	lazy = true,
	cmd = "ConformInfo",
	init = function()
		-- Install the conform formatter on VeryLazy
		GlobalUtil.on_very_lazy(function()
			GlobalUtil.format.register({
				name = "conform.nvim",
				priority = 100,
				primary = true,
				format = function(buf)
					require("conform").format({ bufnr = buf })
				end,
				sources = function(buf)
					local ret = require("conform").list_formatters(buf)
					---@param v conform.FormatterInfo
					return vim.tbl_map(function(v)
						return v.name
					end, ret)
				end,
			})
		end)
	end,
	opts = function()
		---@type conform.setupOpts
		local opts = {
			default_format_opts = {
				timeout_ms = 3000,
				async = false, -- not recommended to change
				quiet = false, -- not recommended to change
				lsp_format = "fallback", -- not recommended to change
			},
			formatters_by_ft = M.formatters_by_ft,
			-- The options you set here will be merged with the builtin formatters.
			-- You can also define any custom formatters here.
			---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
			formatters = {
				injected = { options = { ignore_errors = true } },

				jq = {
					command = "jq",
					args = { "." },
				},
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
						return false
					end,
				},
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
				prettier = {
					condition = function(_, ctx)
						local ft = vim.bo[ctx.buf].filetype
						-- default filetypes are always supported
						if M.is_support_prettier_ft(ft) then
							return true
						end
						return M.has_prettier_parser(ctx) and M.has_prettier_config(ctx)
					end,
				},

				-- Google Java Format：支持可执行文件或 JAR，两者其一即可
				["google-java-format"] = function(bufnr)
					local cmd, args, stdin = nil, {}, true
					local function read_project_cfg(root)
						local cfg = { aosp = false, length = nil }
						local cfg_file = root .. "/.nvim/java.json"
						if vim.uv.fs_stat(cfg_file) then
							local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(cfg_file), "\n"))
							if ok and type(data) == "table" and type(data.google_java_format) == "table" then
								cfg.aosp = data.google_java_format.aosp or cfg.aosp
								cfg.length = data.google_java_format.length or cfg.length
							end
						end
						return cfg
					end

					local root = vim.fs.root(bufnr, { 
						".nvim/java.json", "pom.xml", "build.gradle", "gradlew", "mvnw", ".git" 
					}) or vim.fn.getcwd()
					local cfg = read_project_cfg(root)

					if vim.fn.executable("google-java-format") == 1 then
						cmd = "google-java-format"
						if cfg.aosp then table.insert(args, "--aosp") end
						if cfg.length then table.insert(args, "--length"); table.insert(args, tostring(cfg.length)) end
						table.insert(args, "-") -- read from stdin
						return { command = cmd, args = args, stdin = true }
					else
						-- 尝试通过 JAR 运行（Mason 包或环境变量）
						local jar = os.getenv("GOOGLE_JAVA_FORMAT_JAR")
						if not jar then
							local mason_dir = GlobalUtil.get_pkg_path("google-java-format", "", { warn = false })
							if mason_dir and mason_dir ~= "" then
								local found = vim.fn.glob(mason_dir .. "/*.jar", true, true)
								if type(found) == "table" and #found > 0 then
									jar = found[1]
								end
							end
						end
						if jar then
							cmd = "java"
							args = { "-jar", jar }
							if cfg.aosp then table.insert(args, "--aosp") end
							if cfg.length then table.insert(args, "--length"); table.insert(args, tostring(cfg.length)) end
							table.insert(args, "-")
							return { command = cmd, args = args, stdin = true }
						end
					end
					-- 未找到任何可执行路径时，返回 nil 以跳过
					return nil
				end,
			},
		}
		return opts
	end,
	config = function(_, opts)
		require("conform").setup(opts)
	end,
}

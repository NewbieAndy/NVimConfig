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
			},
		}
		return opts
	end,
	config = function(_, opts)
		require("conform").setup(opts)
	end,
}

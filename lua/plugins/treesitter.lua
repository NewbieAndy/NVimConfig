-- nvim-treesitter v1.x 已完全重写，API 不兼容旧版。
-- 需要 Neovim 0.12+，highlight/indent 改为 FileType autocmd 启用。
return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false, -- v1.x 不支持懒加载
		build = ":TSUpdate",
		config = function()
			-- 安装解析器（异步，已安装则跳过）
			require("nvim-treesitter").install({
				"bash",
				"c",
				"cmake",
				"css",
				"diff",
				"dockerfile",
				"git_config",
				"gitattributes",
				"gitcommit",
				"git_rebase",
				"gitignore",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"html",
				"java",
				"javascript",
				"jsdoc",
				"json",
				"json5",
				-- jsonc 已在 v1.x 中移除，由 json 解析器处理
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"ninja",
				"nu",
				"printf",
				"python",
				"query",
				"regex",
				"rst",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"vue",
				"xml",
				"yaml",
			})

			-- 启用 treesitter 语法高亮（Neovim 内置）
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("custom_ts_highlight", { clear = true }),
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})

			-- 启用 treesitter 缩进（实验性）
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("custom_ts_indent", { clear = true }),
				callback = function(ev)
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<c-v>",
					},
					include_surrounding_whitespace = false,
				},
			})

			local sel = require("nvim-treesitter-textobjects.select")
			local map = GlobalUtil.safe_keymap_set

			-- 函数
			map({ "x", "o" }, "af", function()
				sel.select_textobject("@function.outer", "textobjects")
			end, { desc = "外层函数" })
			map({ "x", "o" }, "if", function()
				sel.select_textobject("@function.inner", "textobjects")
			end, { desc = "内层函数" })

			-- 块
			map({ "x", "o" }, "ab", function()
				sel.select_textobject("@block.outer", "textobjects")
			end, { desc = "外层块" })
			map({ "x", "o" }, "ib", function()
				sel.select_textobject("@block.inner", "textobjects")
			end, { desc = "内层块" })

			-- 类
			map({ "x", "o" }, "ac", function()
				sel.select_textobject("@class.outer", "textobjects")
			end, { desc = "外层类" })
			map({ "x", "o" }, "ic", function()
				sel.select_textobject("@class.inner", "textobjects")
			end, { desc = "内层类" })

			-- 作用域
			map({ "x", "o" }, "as", function()
				sel.select_textobject("@local.scope", "locals")
			end, { desc = "语言作用域" })
		end,
	},
}

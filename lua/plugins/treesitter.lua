return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	main = "nvim-treesitter.configs",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"javascript",
			"jsdoc",
			"json",
			"jsonc",
			"json5",
			"lua",
			"luadoc",
			"luap",
			"markdown",
			"markdown_inline",
			"printf",
			"python",
			"query",
			"regex",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
			"nu",
			"ninja",
			"rst",
			"cmake",
			"dockerfile",
			"git_config",
			"gitcommit",
			"git_rebase",
			"gitignore",
			"gitattributes",
			"go",
			"gomod",
			"gowork",
			"gosum",
			"java",
			"nu",
			"ninja",
			"rst",
			"sql",
			"vue",
			"css",
		},
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
		refactor = {
			-- 使用 Treesitter 高亮光标下标识符及其作用域，替代 LSP documentHighlight（零额外依赖）
			highlight_definitions = { enable = true, clear_on_cursor_move = true },
			highlight_current_scope = { enable = true },
		},

		playground = {
			enable = false, -- 关闭 playground 以减少运行期开销
		},
		textobjects = {
			select = {
				enable = true,

				-- Automatically jump forward to textobj, similar to targets.vim
				lookahead = true,

				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ab"] = "@block.outer",
					["ib"] = "@block.inner",
					["ac"] = "@class.outer",
					-- You can optionally set descriptions to the mappings (used in the desc parameter of
					-- nvim_buf_set_keymap) which plugins like which-key display
					["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
					-- You can also use captures from other query groups like `locals.scm`
					["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
				},
				-- You can choose the select mode (default is charwise 'v')
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * method: eg 'v' or 'o'
				-- and should return the mode ('v', 'V', or '<c-v>') or a table
				-- mapping query_strings to modes.
				selection_modes = {
					["@parameter.outer"] = "v", -- charwise
					["@function.outer"] = "V", -- linewise
					["@class.outer"] = "<c-v>", -- blockwise
				},
				-- If you set this to `true` (default is `false`) then any textobject is
				-- extended to include preceding or succeeding whitespace. Succeeding
				-- whitespace has priority in order to act similarly to eg the built-in
				-- `ap`.
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * selection_mode: eg 'v'
				-- and should return true of false
				include_surrounding_whitespace = false,
			},
		},
	},
}

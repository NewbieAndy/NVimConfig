-- blink.cmp 配置示例
-- 这是根据当前 nvim-cmp 配置转换而来的 blink.cmp 配置
-- 📝 此文件仅供参考，实际迁移时需要创建为 lua/plugins/blink-cmp.lua
if true then
  return {}
end

return {
	"saghen/blink.cmp",
	version = "1.*",
	dependencies = {
		-- Copilot 补全源（推荐方案）
		{
			"giuxtaposition/blink-cmp-copilot",
			dependencies = {
				"zbirenbaum/copilot.lua", -- 保留，用于 CopilotChat
			},
		},
		-- 代码片段库（保留现有配置）
		"rafamadriz/friendly-snippets",
	},

	event = "InsertEnter",

	opts = {
		-- 基础启用配置
		enabled = function()
			return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
		end,

		-- 键盘映射配置
		keymap = {
			preset = "default", -- 使用默认预设作为基础

			-- 自定义键盘映射（模仿当前 nvim-cmp 行为）
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },

			-- ESC 取消补全
			["<ESC>"] = { "cancel", "fallback" },

			-- Enter 确认补全（需要处理 snippet 跳转）
			["<CR>"] = {
				function(cmp)
					-- 创建撤销点
					GlobalUtil.create_undo()

					if cmp.is_visible() then
						return cmp.accept()
					elseif vim.snippet.active({ direction = 1 }) then
						vim.schedule(function()
							vim.snippet.jump(1)
						end)
						return true
					end
					return false -- fallback
				end,
				"fallback",
			},

			-- Tab 键多功能行为
			["<Tab>"] = {
				function(cmp)
					-- 创建撤销点
					GlobalUtil.create_undo()

					-- 1. 如果 Copilot suggestion 可见，接受建议
					if
						package.loaded["copilot"] and require("copilot.suggestion").is_visible()
					then
						require("copilot.suggestion").accept()
						return true
					end

					-- 2. 如果补全菜单可见，接受补全
					if cmp.is_visible() then
						return cmp.accept()
					end

					-- 3. 如果在 snippet 中，跳转到下一个占位符
					if vim.snippet.active({ direction = 1 }) then
						vim.schedule(function()
							vim.snippet.jump(1)
						end)
						return true
					end

					-- 4. 如果光标前有字符，显示补全
					local line, col = unpack(vim.api.nvim_win_get_cursor(0))
					if
						col ~= 0
						and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match(
							"%s"
						) == nil
					then
						cmp.show()
						return true
					end

					-- 5. 否则插入 Tab
					return false
				end,
				"fallback",
			},

			-- 手动触发补全
			["<F13>"] = { "show", "fallback" },
		},

		-- 补全配置
		completion = {
			-- 关键字配置
			keyword = {
				range = "prefix", -- 只匹配光标前的文本
			},

			-- 触发器配置
			trigger = {
				prefetch_on_insert = true, -- 进入插入模式时预加载
				show_in_snippet = true, -- 在 snippet 中显示补全
				show_on_keyword = true, -- 输入关键字时显示
				show_on_trigger_character = true, -- 触发字符时显示
			},

			-- 补全列表配置
			list = {
				max_items = 200,
				selection = {
					preselect = true, -- 自动选择第一项
					auto_insert = true, -- 自动插入选中项
				},
				cycle = {
					from_bottom = true,
					from_top = true,
				},
			},

			-- 接受补全配置
			accept = {
				dot_repeat = true, -- 支持 . 重复
				create_undo_point = true, -- 创建撤销点
				auto_brackets = {
					enabled = true,
					default_brackets = { "(", ")" },
					-- Python 自动括号
					force_on_filetype = { "python" },
					blocked_filetypes = { "typescriptreact", "javascriptreact", "vue" },
				},
			},

			-- 补全菜单配置
			menu = {
				enabled = true,
				min_width = 15,
				max_height = 10,
				border = "rounded", -- 使用圆角边框（与当前配置一致）
				winblend = 0,
				winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None",
				scrollbar = true,
				auto_show = true,
				auto_show_delay_ms = 0,

				-- 绘制配置（自定义显示格式）
				draw = {
					align_to = "label",
					padding = 1,
					gap = 1,

					-- 显示列配置
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
					},

					-- 自定义组件
					components = {
						kind_icon = {
							text = function(ctx)
								return ctx.kind_icon .. ctx.icon_gap
							end,
							highlight = function(ctx)
								return { { group = ctx.kind_hl, priority = 20000 } }
							end,
						},

						label = {
							width = { fill = true, max = 60 },
							text = function(ctx)
								return ctx.label .. ctx.label_detail
							end,
							highlight = function(ctx)
								local highlights = {
									{
										0,
										#ctx.label,
										group = ctx.deprecated and "BlinkCmpLabelDeprecated"
											or "BlinkCmpLabel",
									},
								}
								if ctx.label_detail then
									table.insert(highlights, {
										#ctx.label,
										#ctx.label + #ctx.label_detail,
										group = "BlinkCmpLabelDetail",
									})
								end
								for _, idx in ipairs(ctx.label_matched_indices) do
									table.insert(
										highlights,
										{ idx, idx + 1, group = "BlinkCmpLabelMatch" }
									)
								end
								return highlights
							end,
						},
					},
				},
			},

			-- 文档窗口配置
			documentation = {
				auto_show = false, -- 不自动显示（与当前配置一致）
				auto_show_delay_ms = 500,
				window = {
					border = "rounded",
					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
				},
			},

			-- Ghost text 配置
			ghost_text = {
				enabled = true, -- 启用幽灵文本
			},
		},

		-- 代码片段配置
		snippets = {
			preset = "default", -- 使用内置的 vim.snippet
			expand = function(snippet)
				vim.snippet.expand(snippet)
			end,
			active = function(filter)
				return vim.snippet.active(filter)
			end,
			jump = function(direction)
				vim.snippet.jump(direction)
			end,
		},

		-- 补全源配置
		sources = {
			-- 默认补全源
			default = { "lsp", "path", "snippets", "buffer" },

			-- 针对特定文件类型的补全源
			per_filetype = {
				-- Lua 开发增强
				lua = { "lsp", "path", "snippets", "buffer", "lazydev" },
			},

			-- 补全源提供者配置
			providers = {
				-- Copilot 源配置
				copilot = {
					name = "Copilot",
					module = "blink-cmp-copilot",
					score_offset = 100, -- 提高优先级
					async = true,
					transform_items = function(_, items)
						-- 添加 Copilot 图标
						for _, item in ipairs(items) do
							item.kind = require("blink.cmp.types").CompletionItemKind.Copilot
						end
						return items
					end,
				},

				-- Lazydev 源（Lua 开发）
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},

				-- LSP 源配置（自定义）
				lsp = {
					name = "LSP",
					module = "blink.cmp.sources.lsp",
					fallbacks = {}, -- 清空默认的 fallback，始终显示 LSP
				},

				-- Buffer 源配置
				buffer = {
					name = "Buffer",
					module = "blink.cmp.sources.buffer",
					max_items = 5, -- 限制 buffer 补全数量
					min_keyword_length = 3, -- 至少 3 个字符才触发
				},
			},

			-- 全局转换函数（可选）
			-- transform_items = function(_, items)
			--   -- 可以在这里过滤或转换补全项
			--   return items
			-- end,
		},

		-- 模糊匹配配置
		fuzzy = {
			-- 使用 Rust 实现（更快）
			use_typo_resistance = true,
			use_frecency = true,
			use_proximity = true,
			sorts = { "score", "sort_text" },
		},

		-- 外观配置
		appearance = {
			-- 使用 Nerd Font
			use_nvim_cmp_as_default = false,
			nerd_font_variant = "mono",

			-- 自定义 kind 图标（使用当前配置的图标）
			kind_icons = GlobalUtil.icons.kinds,
		},

		-- 命令行补全配置
		cmdline = {
			enabled = true,
			sources = {
				-- `:` 命令模式
				default = { "cmdline", "path" },
			},
		},
	},

	-- 配置完成后的初始化
	config = function(_, opts)
		local blink = require("blink.cmp")
		blink.setup(opts)

		-- 设置自定义高亮（如果需要）
		vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "Comment", default = true })
	end,
}

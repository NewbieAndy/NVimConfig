-- blink.cmp 主配置（基于现有项目结构，简洁且中文注释清晰）
-- 目标：用 blink.cmp 完美替换 nvim-cmp，并复刻现有键位逻辑（<CR>/<Tab>/<F13> 等）

return {
	"saghen/blink.cmp",
	version = "1.*",
	lazy = false,
	dependencies = {
		-- Copilot 菜单式补全源（避免 copilot-cmp 重复集成）
		"fang2hou/blink-copilot",
		-- 仅使用片段库（不使用 nvim-snippets 引擎，避免对 cmp 的隐式依赖）
		"rafamadriz/friendly-snippets",
	},

	opts = function()
		-- 复刻：判断光标前是否有字符（与旧 has_words_before 一致）
		local has_words_before = function()
			local line, col = unpack(vim.api.nvim_win_get_cursor(0))
			if col == 0 then
				return false
			end
			local ch = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col)
			return ch:match("%s") == nil
		end

		return {
			-- 外观：使用全局 kind 图标，统一视觉
			appearance = {
				use_nvim_cmp_as_default = false,
				nerd_font_variant = "mono",
				kind_icons = GlobalUtil.icons.kinds,
			},

			-- 模糊匹配：强制使用 Lua 实现，避免 Rust 警告
			fuzzy = { implementation = "lua" },

			-- 关键补全行为（尽量保持默认，减少配置性）
			completion = {
				keyword = { range = "prefix" },
				trigger = {
					prefetch_on_insert = false, -- 关闭进入插入模式即预取，避免首帧压力
					show_on_keyword = true,
					show_on_trigger_character = true,
					show_in_snippet = true,
				},
				list = {
					max_items = 80, -- 进一步限制候选数量，提升首帧
					selection = { preselect = true, auto_insert = true },
				},
					documentation = {
						auto_show = false,
						auto_show_delay_ms = 500,
						window = { border = "rounded", winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
					},
					menu = {
						enabled = true,
						border = "rounded",
						winhighlight = "Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None",
						auto_show = true,
						auto_show_delay_ms = 80, -- 略增延迟，减少频繁重绘
					},
				ghost_text = { enabled = false }, -- 关闭幽灵文本以减少插入态重绘
				accept = {
					dot_repeat = true,
					create_undo_point = true,
					auto_brackets = { enabled = true },
				},
			},

			-- 键位：严格复刻现有逻辑（条件与顺序一致）
			keymap = {
				-- 文档滚动
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				-- 取消补全
				["<ESC>"] = {
					function(cmp)
						local feed_esc = function()
							if vim.api.nvim_get_mode().mode ~= "n" then
								vim.api.nvim_feedkeys(
									vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
									"n",
									false
								)
							end
						end
						if cmp.is_visible() then
							cmp.cancel()
							vim.schedule(feed_esc) -- 等待 blink 完成取消后再退出插入模式，避免 E785
							return true
						end
						feed_esc()
						return true
					end,
				},
				-- Enter：优先接受补全；否则 snippet 跳转；否则 fallback
				["<CR>"] = {
					function(cmp)
						GlobalUtil.create_undo()
						if cmp.is_visible() then
							return cmp.accept()
						elseif GlobalUtil.cmp.actions.snippet_forward() then
							return true
						end
						return false -- fallback
					end,
					"fallback",
				},
				-- Tab：Copilot 可见则接受；其后依次为接受补全 → snippet 跳转 → 有词触发 show → fallback
				["<Tab>"] = {
					function(cmp)
						GlobalUtil.create_undo()
						if GlobalUtil.cmp.actions.ai_accept() then
							return true
						elseif cmp.is_visible() then
							return cmp.accept()
						elseif GlobalUtil.cmp.actions.snippet_forward() then
							return true
						elseif has_words_before() then
							cmp.show()
							return true
						end
						return false -- fallback
					end,
					"fallback",
				},
				-- F13：手动触发补全
				["<F13>"] = { "show", "fallback" },
			},

			-- 片段：使用 Neovim 内置（与现有逻辑一致）
			snippets = {
				preset = "default",
				expand = function(snippet)
					GlobalUtil.cmp.expand(snippet)
				end,
				active = function(filter)
					return vim.snippet.active(filter)
				end,
				jump = function(dir)
					vim.snippet.jump(dir)
				end,
			},

			-- 补全源：最小但够用，包含 Copilot
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "copilot" },
				providers = {
					-- LSP 源：限制候选数量避免过载
					lsp = {
						name = "lsp",
						module = "blink.cmp.sources.lsp",
						max_items = 80,
					},
					-- Buffer 源：限制候选数量与触发阈值，减轻大缓冲区扫描负载
					buffer = {
						name = "buffer",
						module = "blink.cmp.sources.buffer",
						max_items = 50,
						min_keyword_length = 2,
					},
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						score_offset = 100, -- 提高排序优先级
						async = true,
					},
					lazydev = GlobalUtil.has("lazydev.nvim") and {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					} or nil,
				},
			},

			-- 命令行补全（最小化启用）
			cmdline = {
				enabled = true,
				keymap = { preset = "cmdline", ["<Right>"] = false, ["<Left>"] = false },
				completion = { list = { selection = { preselect = false } } },
			},
		}
	end,

	config = function(_, opts)
		local blink = require("blink.cmp")
		blink.setup(opts)
		-- 统一幽灵文本高亮
		vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "Comment", default = true })

		-- 诊断：简单时序日志，定位弹窗延迟瓶颈（可在复现后移除）
		if vim.g.blink_diag ~= false then
			local logfile = "/tmp/blink_diag.log"
			local function log(msg)
				pcall(vim.fn.writefile, { os.date("%H:%M:%S ") .. msg }, logfile, "a")
			end
			-- 记录 LSP 请求耗时
			local orig_req = vim.lsp.buf_request
			vim.lsp.buf_request = function(buf, method, params, handler)
				local t0 = vim.uv.hrtime()
				local wrapped = function(err, result, ctx, cfg)
					local ms = (vim.uv.hrtime() - t0) / 1e6
					log(string.format("LSP %s %.1fms (client=%s)", method, ms, ctx and ctx.client_id or "-"))
					if handler then
						return handler(err, result, ctx, cfg)
					end
					local h = vim.lsp.handlers[method]
					return h and h(err, result, ctx, cfg)
				end
				return orig_req(buf, method, params, wrapped)
			end
			-- 记录 show→可见耗时（手动/自动均捕获）
			local orig_show = blink.show
			blink.show = function(...)
				local t0 = vim.uv.hrtime()
				local ret = orig_show(...)
				local tries = 0
				local function poll()
					tries = tries + 1
					if blink.is_visible() or tries > 50 then
						local ms = (vim.uv.hrtime() - t0) / 1e6
						log(string.format("MENU visible %.1fms (tries=%d)", ms, tries))
					else
						vim.defer_fn(poll, 5)
					end
				end
				vim.defer_fn(poll, 0)
				return ret
			end
			-- 输入事件
			vim.api.nvim_create_autocmd({ "TextChangedI", "InsertCharPre" }, {
				callback = function(ev)
					log("EV " .. ev.event .. " col=" .. vim.fn.col(".") .. " ft=" .. vim.bo.filetype)
				end,
			})
			log("--- blink diag start ---")
		end
	end,
}

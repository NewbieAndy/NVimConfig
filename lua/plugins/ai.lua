local function ai_model(default)
	return vim.env.NVIM_AI_MODEL or default
end

local function ai_api_key()
	local key = vim.env.NVIM_AI_API_KEY
	if type(key) ~= "string" or key == "" then
		return ""
	end
	key = key:gsub("^%s*[Bb]earer%s+", ""):gsub("%s+$", "")
	return key
end

local minuet_diag_log = "/tmp/minuet_diag.log"

local function log_minuet_diag(message)
	pcall(vim.fn.writefile, { os.date("%Y-%m-%d %H:%M:%S ") .. message }, minuet_diag_log, "a")
end

return {
	{
		"milanglacier/minuet-ai.nvim",
		cond = function()
			return ai_api_key() ~= ""
		end,
		-- Minuet 必须在首个缓冲区触发 FileType 前完成 setup，否则 virtual text
		-- 的 FileType 自动触发监听会错过当前缓冲区，导致 AI 内联补全无法启用。
		lazy = false,
		cmd = "Minuet",
		opts = function()
			return {
				provider = "openai_compatible",
				request_timeout = 8,
				throttle = 1000,
				debounce = 400,
				n_completions = 1,
				blink = {
					enable_auto_complete = true,
				},
				virtualtext = {
					auto_trigger_ft = { "*" },
					auto_trigger_ignore_ft = { "codecompanion", "markdown", "help", "gitcommit" },
					keymap = {
						accept = nil,
						accept_line = "<A-a>",
						accept_n_lines = "<A-z>",
						next = "<A-]>",
						prev = "<A-[>",
						dismiss = "<A-e>",
					},
					show_on_completion_menu = false,
				},
				provider_options = {
					openai_compatible = {
						name = "Kimi",
						api_key = ai_api_key,
						end_point = "https://api.moonshot.cn/v1/chat/completions",
						-- 实时代码补全优先低延迟；高速版与 K2.7 Code 能力相同。
						model = ai_model("kimi-k2.7-code-highspeed"),
						optional = {
							-- K2.7 Code 仅支持思考模式，需要为推理和实际补全文本预留空间。
							max_tokens = 512,
							top_p = 0.95,
						},
					},
				},
			}
		end,
		config = function(_, opts)
			local minuet = require("minuet")
			minuet.setup(opts)

			local provider = require("minuet.backends.openai_compatible")
			log_minuet_diag(
				("--- setup model=%s timeout=%ss provider_available=%s ---"):format(
					minuet.config.provider_options.openai_compatible.model,
					minuet.config.request_timeout,
					tostring(provider.is_available())
				)
			)

			-- 包装 provider 回调，诊断请求是否真正发出以及最终返回了多少候选。
			if not provider._nvim_diag_wrapped then
				provider._nvim_diag_wrapped = true
				local complete = provider.complete
				provider.complete = function(context, callback)
					local started = vim.uv.hrtime()
					log_minuet_diag(
						("request context_before=%d context_after=%d ft=%s"):format(
							#(context.lines_before or ""),
							#(context.lines_after or ""),
							vim.bo.filetype
						)
					)
					return complete(context, function(items)
						local elapsed = (vim.uv.hrtime() - started) / 1e6
						log_minuet_diag(
							("response elapsed=%.1fms items=%d"):format(elapsed, type(items) == "table" and #items or 0)
						)
						callback(items)
					end)
				end
			end

			vim.api.nvim_create_autocmd("User", {
				pattern = { "MinuetRequestStarted", "MinuetRequestFinished" },
				callback = function(event)
					local data = event.data or {}
					log_minuet_diag(
						("event=%s model=%s request=%s/%s"):format(
							event.match,
							data.model or "-",
							data.request_idx or "-",
							data.n_requests or "-"
						)
					)
				end,
			})
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		version = "^19.0.0",
		cmd = {
			"CodeCompanion",
			"CodeCompanionActions",
			"CodeCompanionChat",
			"CodeCompanionCLI",
			"CodeCompanionCmd",
		},
		dependencies = {
			{ "nvim-lua/plenary.nvim", branch = "master" },
			"nvim-treesitter/nvim-treesitter",
		},
		opts = function()
			local adapter = {
				name = "kimi",
				model = ai_model("kimi-k2.6"),
			}

			return {
				adapters = {
					http = {
						kimi = function()
							return require("codecompanion.adapters").extend("openai_compatible", {
								name = "kimi",
								formatted_name = "Kimi",
								env = {
									api_key = ai_api_key,
									url = "https://api.moonshot.cn",
									chat_url = "/v1/chat/completions",
									models_endpoint = "/v1/models",
								},
								schema = {
									model = {
										default = ai_model("kimi-k2.6"),
									},
									top_p = {
										default = 0.95,
									},
								},
							})
						end,
						opts = {
							show_presets = false,
							show_defaults = false,
						},
					},
				},
				interactions = {
					chat = {
						adapter = adapter,
						roles = {
							user = "Me",
							llm = function(active_adapter)
								return "CodeCompanion (" .. active_adapter.formatted_name .. ")"
							end,
						},
						opts = {
							completion_provider = "blink",
						},
						keymaps = {
							send = {
								modes = { n = "<CR>", i = "<C-s>" },
							},
							close = {
								modes = { n = "q", i = "<C-a>" },
							},
							clear = {
								modes = { n = "<C-x>" },
							},
						},
					},
					inline = {
						adapter = adapter,
						keymaps = {
							accept_change = {
								modes = { n = "<C-y>" },
								description = "Accept the suggested change",
							},
							reject_change = {
								modes = { n = "gr" },
								description = "Reject the suggested change",
							},
						},
					},
					cmd = {
						adapter = adapter,
					},
					background = {
						adapter = {
							name = "kimi",
							model = ai_model("kimi-k2.6"),
						},
					},
				},
				display = {
					action_palette = {
						provider = "snacks",
					},
					chat = {
						window = {
							layout = "vertical",
							width = 0.4,
						},
					},
					inline = {
						layout = "vertical",
					},
				},
				opts = {
					language = "Chinese",
					log_level = "WARN",
				},
			}
		end,
		keys = {
			{ "<c-s>", "<CR>", ft = "codecompanion", desc = "Submit Prompt", remap = true },
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<C-a>",
				"<cmd>CodeCompanionActions<cr>",
				desc = "AI Actions",
				mode = { "n", "v" },
			},
			{
				"<leader>aa",
				"<cmd>CodeCompanionChat Toggle<cr>",
				desc = "Toggle AI Chat",
				mode = { "n", "v" },
			},
			{
				"<leader>ai",
				"<cmd>CodeCompanion /explain<cr>",
				desc = "Explain Code",
				mode = { "n", "v" },
			},
			{
				"<leader>ax",
				"<cmd>CodeCompanionChat RefreshCache<cr>",
				desc = "Refresh AI Chat Cache",
				mode = { "n", "v" },
			},
			{
				"<leader>aq",
				function()
					vim.ui.input({ prompt = "Quick Chat: " }, function(input)
						if input and input ~= "" then
							vim.cmd("CodeCompanionChat " .. vim.fn.escape(input, '\\|"'))
						end
					end)
				end,
				desc = "Quick Chat",
				mode = { "n", "v" },
			},
			{
				"<leader>ap",
				"<cmd>CodeCompanionActions<cr>",
				desc = "Prompt Actions",
				mode = { "n", "v" },
			},
			{
				"<leader>am",
				"<cmd>CodeCompanionChat adapter=kimi<cr>",
				desc = "Select AI Model",
				mode = { "n", "v" },
			},
		},
	},
}

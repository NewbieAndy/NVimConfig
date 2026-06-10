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

return {
	{
		"milanglacier/minuet-ai.nvim",
		cond = function()
			return ai_api_key() ~= ""
		end,
		event = "InsertEnter",
		cmd = "Minuet",
		opts = function()
			return {
				provider = "openai_compatible",
				request_timeout = 3,
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
						model = ai_model("kimi-k2.6"),
						optional = {
							max_tokens = 256,
							top_p = 0.95,
						},
					},
				},
			}
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
							vim.cmd("CodeCompanionChat " .. vim.fn.escape(input, "\\|\""))
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

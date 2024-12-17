--未处理
return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		cmd = "CopilotChat",
		event = "VeryLazy",
		build = "make tiktoken",
		opts = function()
			local user = vim.env.USER or "User"
			user = user:sub(1, 1):upper() .. user:sub(2)
			return {
				auto_insert_mode = true,
				question_header = "  " .. user .. " ",
				answer_header = "  Copilot ",
				window = {
					width = 0.4,
				},

				prompts = {
					Explain = {
						prompt = "> /COPILOT_EXPLAIN\n\nIn Chinese write an explanation for the selected code as paragraphs of text.",
						mapping = "<leader>ae",
					},
					Review = {
						prompt = "> /COPILOT_REVIEW\n\nCheck the selected code and output the check result in Chinese.",
						mapping = "<leader>ar",
					},
					Fix = {
						prompt = "> /COPILOT_GENERATE\n\nThere is a problem in this code. Rewrite the code to show it with the bug fixed.Finally explain the code in Chinese",
					},
					Optimize = {
						prompt = "> /COPILOT_GENERATE\n\nOptimize the selected code to improve performance and readability.Finally explain the code in Chinese",
					},
					Docs = {
						prompt = "> /COPILOT_GENERATE\n\nPlease add Chinese documentation comments to the selected code.",
					},
					Tests = {
						prompt = "> /COPILOT_GENERATE\n\nPlease generate tests for my code.",
					},
					Commit = {
						prompt = "> #git:staged\n\nWrite Chinese commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
					},
					Translate = {
						prompt = "Translate selected code comments into Chinese.",
						mapping = "<leader>at",
					},
				},

				mappings = {
					close = {
						normal = "q",
						insert = "<c-a>",
					},
				},
			}
		end,
		keys = {
			{ "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
			{
				"<C-a>",
				function()
					local select = require("CopilotChat.select")
					local mode = vim.api.nvim_get_mode().mode
					return require("CopilotChat").toggle(
						(mode == "v" or mode == "V") and { selection = select.visual } or nil
					)
				end,
				desc = "Toggle (CopilotChat)",
				remap = true,
				mode = { "n", "v", "i" },
			},
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>aa",
				function()
					local select = require("CopilotChat.select")
					local mode = vim.api.nvim_get_mode().mode
					return require("CopilotChat").toggle(
						(mode == "v" or mode == "V") and { selection = select.visual } or nil
					)
				end,
				desc = "Toggle (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ai",
				function()
					local chat = require("CopilotChat")
					local select = require("CopilotChat.select")
					chat.ask("", {
						selection = select.visual,
						window = {
							layout = "float",
							relative = "cursor",
							width = 1,
							height = 0.4,
							row = 1,
						},
					})
				end,
				mode = { "v", "n" },
				desc = "CopilotChat - Inline chat",
			},
			{
				"<leader>ax",
				function()
					return require("CopilotChat").reset()
				end,
				desc = "Clear (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>aq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then
						local select = require("CopilotChat.select")
						local mode = vim.api.nvim_get_mode().mode
						require("CopilotChat").ask(
							input,
							(mode == "v" or mode == "V") and { selection = select.visual } or nil
						)
					end
				end,
				desc = "Quick Chat (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ap",
				function()
					local actions = require("CopilotChat.actions")
					local select = require("CopilotChat.select")
					local mode = vim.api.nvim_get_mode().mode
					require("CopilotChat.integrations.telescope").pick(
						actions.prompt_actions((mode == "v" or mode == "V") and { selection = select.visual } or nil)
					)
				end,
				desc = "Prompt Actions (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>am",
				function()
					return require("CopilotChat").select_model()
				end,
				desc = "Select Models (CopilotChat)",
				mode = { "n", "v" },
			},
		},

		config = function(_, opts)
			local chat = require("CopilotChat")
			local select = require("CopilotChat.select")
			-- Use unnamed register for the selection
			opts.selection = select.unnamed
			-- Custom buffer for CopilotChat
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = true
					vim.opt_local.number = true
					-- Get current filetype and set it to markdown if the current filetype is copilot-chat
					local ft = vim.bo.filetype
					if ft == "copilot-chat" then
						vim.bo.filetype = "markdown"
					end
				end,
			})
			chat.setup(opts)
		end,
	},

	-- {
	--   "folke/edgy.nvim",
	--   optional = true,
	--   opts = function(_, opts)
	--     opts.right = opts.right or {}
	--     table.insert(opts.right, {
	--       ft = "copilot-chat",
	--       title = "Copilot Chat",
	--       size = { width = 50 },
	--     })
	--   end,
	-- },
}

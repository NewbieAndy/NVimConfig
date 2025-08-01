-- if true then
--   return {}
-- end
---@param config {type?:string, args?:string[]|fun():string[]?}
local function get_args(config)
	local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
	local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

	config = vim.deepcopy(config)
	---@cast args string[]
	config.args = function()
		local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
		if config.type and config.type == "java" then
			---@diagnostic disable-next-line: return-type-mismatch
			return new_args
		end
		return require("dap.utils").splitstr(new_args)
	end
	return config
end
--- 检查指定虚拟环境目录下 python 是否存在且可执行
-- @param workdir string 工作目录（如 vim.fn.getcwd()）
-- @param venv_dir string 虚拟环境目录名（如 ".venv"）
-- @return boolean
local function has_venv_python(workdir, venv_dir)
	-- 拼接 python 路径
	local python_path = workdir .. "/" .. venv_dir .. "/bin/python"
	-- 判断路径下 python 是否可执行
	return vim.fn.executable(python_path) == 1
end

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
        -- stylua: ignore
        keys = {
            { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
            { "<leader>de", function() require("dapui").eval() end,     desc = "Eval",  mode = { "n", "v" } },
        },
				opts = {},
				config = function(_, opts)
					local dap = require("dap")
					local dapui = require("dapui")
					dapui.setup(opts)
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open({})
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close({})
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close({})
					end
				end,
			},
			{
				"jay-babu/mason-nvim-dap.nvim",
				dependencies = { "williamboman/mason.nvim" },
				cmd = { "DapInstall", "DapUninstall" },
				opts = {
					handlers = { python = function() end },
				},
			},
			"theHamsta/nvim-dap-virtual-text",
			{
				"mfussenegger/nvim-dap-python",
				ft = "python",
				config = function()
					GlobalUtil.root()
					local root_pwd = GlobalUtil.root()
					-- -- 优先使用当前项目的虚拟环境
					local venv = vim.fn.getenv("VIRTUAL_ENV")
					local venv_path = (venv and venv ~= "") and tostring(venv) or nil
					if venv_path and vim.fn.filereadable(venv_path .. "/bin/python") == 1 then
						require("dap-python").setup(venv_path .. "/bin/python")
					-- vim.notify("dap-python init virtual_env")
					elseif has_venv_python(root_pwd, ".venv") then
						require("dap-python").setup(root_pwd .. "/.venv/bin/python")
					-- vim.notify("dap-python init .venv")
					elseif has_venv_python(root_pwd, "venv") then
						require("dap-python").setup(root_pwd .. "/venv/bin/python")
					-- vim.notify("dap-python init venv")
					elseif vim.fn.exepath("python") then
						require("dap-python").setup(vim.fn.exepath("python"))
					-- vim.notify("dap-python init PATH")
					else
						require("dap-python").setup(GlobalUtil.get_pkg_path("debugpy", "/venv/bin/python"))
						-- vim.notify("dap-python init Mason")
					end
				end,
			},
			{
				"jbyuki/one-small-step-for-vimkind",
                -- stylua: ignore
                config = function()
                    local dap = require("dap")
                    dap.adapters.nlua = function(callback, conf)
                        local adapter = {
                            type = "server",
                            host = conf.host or "127.0.0.1",
                            port = conf.port or 8086,
                        }
                        if conf.start_neovim then
                            local dap_run = dap.run
                            dap.run = function(c)
                                adapter.port = c.port
                                adapter.host = c.host
                            end
                            require("osv").run_this()
                            dap.run = dap_run
                        end
                        callback(adapter)
                    end
                    dap.configurations.lua = {
                        {
                            type = "nlua",
                            request = "attach",
                            name = "Run this file",
                            start_neovim = {},
                        },
                        {
                            type = "nlua",
                            request = "attach",
                            name = "Attach to running Neovim instance (port = 8086)",
                            port = 8086,
                        },
                    }
                end,
			},
		},
        -- stylua: ignore
    keys = {
        { "<leader>d",  "",                                                                                   desc = "+debug",                 mode = { "n", "v" } },
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
        { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
        { "<leader>dc", function() require("dap").continue() end,                                             desc = "Run/Continue" },
        { "<leader>da", function() require("dap").continue({ before = get_args }) end,                        desc = "Run with Args" },
        { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
        { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to Line (No Execute)" },
        { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
        { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
        { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
        { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
        { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
        { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
        { "<leader>dp", function() require("dap").pause() end,                                                desc = "Pause" },
        { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
        { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
        { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
        { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
        { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end,                      desc = "Debug Nearest" }
    },

		config = function()
			-- load mason-nvim-dap here, after all adapters have been setup
			if GlobalUtil.has("mason-nvim-dap.nvim") then
				require("mason-nvim-dap").setup(GlobalUtil.opts("mason-nvim-dap.nvim"))
			end

			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			for name, sign in pairs(GlobalUtil.icons.dap) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
				)
			end

			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end
		end,
	},
}

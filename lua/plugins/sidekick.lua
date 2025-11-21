-- Sidekick.nvim 配置
-- GitHub Copilot CLI 的终端助手集成
if true then
  return {}
end

return {
	{
		"folke/sidekick.nvim",
		opts = {
			-- 下一次编辑建议配置
			nes = {
				-- 启用下一次编辑建议功能
				enabled = false,
			},
			-- CLI 命令行界面配置
			cli = {
				-- 多路复用器配置
				mux = {
          backend = "zellij", -- 使用 zellij 作为多路复用器后端
					enabled = true, -- 启用多路复用器支持
				},
			},
		},
		-- 快捷键映射
		keys = {
			{
				"<C-q>",
				function()
					-- 切换 Copilot CLI 窗口并聚焦
					require("sidekick.cli").toggle({ name = "copilot", focus = true })
				end,
				desc = "切换 Sidekick CLI",
			},
			{
				"<leader>acc",
				function()
					-- 切换 Copilot CLI 窗口并聚焦
					require("sidekick.cli").toggle({ name = "copilot", focus = true })
				end,
				desc = "切换 Sidekick CLI",
			},
			{
				"<leader>acs",
				function()
					-- 选择 CLI 工具
					-- require("sidekick.cli").select()
					-- 或者仅选择已安装的工具:
					require("sidekick.cli").select({ filter = { installed = true } })
				end,
				desc = "选择 CLI 工具",
			},
			{
				"<leader>acd",
				function()
					-- 关闭 CLI 会话
					require("sidekick.cli").close()
				end,
				desc = "关闭 CLI 会话",
			},
			{
				"<leader>act",
				function()
					-- 发送当前内容到 CLI
					require("sidekick.cli").send({ msg = "{this}" })
				end,
				mode = { "x", "n" }, -- 在可视模式和普通模式下都可用
				desc = "发送当前内容",
			},
			{
				"<leader>acf",
				function()
					-- 发送当前文件到 CLI
					require("sidekick.cli").send({ msg = "{file}" })
				end,
				desc = "发送文件",
			},
			{
				"<leader>acv",
				function()
					-- 发送可视选择到 CLI
					require("sidekick.cli").send({ msg = "{selection}" })
				end,
				mode = { "x" }, -- 仅在可视模式下可用
				desc = "发送可视选择",
			},
			{
				"<leader>acp",
				function()
					-- 打开提示选择器
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" }, -- 在普通模式和可视模式下都可用
				desc = "选择 Sidekick 提示",
			},
		},
	},
}

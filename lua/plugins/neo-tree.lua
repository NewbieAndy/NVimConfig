-- 已迁移到 snacks.explorer，保留此文件供参考
if true then return {} end

return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	deactivate = function()
		vim.cmd([[Neotree close]])
	end,
	init = function()
		-- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
		-- because `cwd` is not set up properly.
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("custom_neotree_start_directory", { clear = true }),
			desc = "Start Neo-tree with directory",
			once = true,
			callback = function()
				if package.loaded["neo-tree"] then
					return
				else
					local stats = vim.uv.fs_stat(vim.fn.argv(0))
					if stats and stats.type == "directory" then
						require("neo-tree")
					end
				end
			end,
		})
	end,
	opts = {
		sources = { "filesystem" },
		open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
		default_component_configs = {
			indent = {
				with_expanders = true,
				expander_collapsed = "",
				expander_expanded = "",
				expander_highlight = "NeoTreeExpander",
			},
			git_status = {
				symbols = {
					unstaged = "󰄱",
					staged = "󰱒",
				},
			},
			name = {
				trailing_slash = false,
				use_git_status_colors = true,
				highlight = "NeoTreeDileame",
			},
		},
		window = {
			mappings = {
				-- ["<bs>"] = "navigate_up",
				-- ["H"] = "set_root",
				["<bs>"] = {
					function(state)
						local utils = require("neo-tree.utils")
						local parent_path, _ = utils.split_path(state.path)
						if not utils.truthy(parent_path) then
							return
						end
						local cc = require("neo-tree.sources.filesystem.commands")
						cc.navigate_up(state)
						GlobalUtil.root.reload_root_path(parent_path)
					end,
					desc = "退回上级目录",
				},
				["<cr>"] = {
					function(state)
						local node = state.tree:get_node()
						local cc = require("neo-tree.sources.filesystem.commands")
						cc.set_root(state)
						if node.type == "directory" then
							GlobalUtil.root.reload_root_path(node.path)
						end
					end,
					desc = "设置根目录",
				},
				["<2-LeftMouse>"] = "open",
				-- ["<cr>"] = "open",
				["o"] = "open",
				["O"] = {
					function(state)
						require("lazy.util").open(state.tree:get_node().path, { system = true })
					end,
					desc = "系统应用打开",
				},
				["."] = "toggle_hidden",
				["<tab>"] = { "preview", config = { use_float = true } },
				["<C-f>"] = { "scroll_preview", config = { direction = -10 } },
				["<C-b>"] = { "scroll_preview", config = { direction = 10 } },
				["<space>"] = "noop",
				-- ["<cr>"] = { "open", config = { expand_nested_files = true } }, -- expand nested file takes precedence
				["<esc>"] = "cancel", -- close preview or floating neo-tree window
				["P"] = "noop",
				["l"] = "open",
				["s"] = "open_split",
				["v"] = "open_vsplit",
				["t"] = "noop",
				["w"] = "noop",
				["C"] = "noop",
				["z"] = "close_all_nodes",
				["R"] = "refresh",
				["a"] = "add",
				["A"] = "add_directory",
				["d"] = {
					function(state)
						local node = state.tree:get_node()
						if node.type == "message" then
							return
						end

						-- 收集选中节点，无多选时取当前节点
						local paths = {}
						for _, n in ipairs(state.tree:get_nodes()) do
							if n._is_selected then
								table.insert(paths, n.path)
							end
						end
						if #paths == 0 then
							table.insert(paths, node.path)
						end

						local names = vim.tbl_map(function(p)
							return vim.fn.fnamemodify(p, ":t")
						end, paths)

						local msg = #paths == 1
							and string.format("移入回收站：%s", names[1])
							or string.format("移入回收站 %d 个项目", #paths)

						vim.ui.select({ "Y  确认", "N  取消" }, {
							prompt = msg,
							snacks = {
								-- 去掉 snacks picker 默认的 "1. 2." 序号前缀
								format = function(item)
									return { { "  " .. tostring(item.item) } }
								end,
							},
						}, function(choice)
							if not vim.startswith(choice or "", "Y") then
								return
							end

							local result = vim.fn.system(vim.list_extend({ "trash" }, paths))
							if vim.v.shell_error ~= 0 then
								vim.notify("回收站失败：" .. result, vim.log.levels.ERROR, { title = "neo-tree" })
								return
							end

							for _, p in ipairs(paths) do
								for _, buf in ipairs(vim.api.nvim_list_bufs()) do
									if vim.api.nvim_buf_is_loaded(buf) then
										local bname = vim.api.nvim_buf_get_name(buf)
										if bname == p or vim.startswith(bname, p .. "/") then
											vim.api.nvim_buf_delete(buf, { force = true })
										end
									end
								end
							end
							require("neo-tree.sources.manager").refresh("filesystem")
						end)
					end,
					desc = "移入回收站",
				},
				["r"] = "rename",
				["y"] = "copy_to_clipboard",
				["Y"] = {
					function(state)
						local node = state.tree:get_node()
						local path = node:get_id()
						vim.fn.setreg("+", path, "c")
					end,
					desc = "复制文件路径到粘贴板",
				},
				["x"] = "cut_to_clipboard",
				["p"] = "paste_from_clipboard",
				["c"] = "copy",
				["m"] = "move",
				["e"] = "noop",
				["q"] = "noop",
				["?"] = "show_help",
				["<"] = "noop",
				[">"] = "noop",
			},
		},
		filesystem = {
			hide_gitignored = false,
			bind_to_cwd = false,
			follow_current_file = { enabled = true },
			use_libuv_file_watcher = true,
			window = {
				mappings = {
					["/"] = "fuzzy_finder",
					["D"] = "fuzzy_finder_directory",
					["#"] = "noop",
					["f"] = "filter_on_submit",
					["<C-c>"] = "clear_filter",
					["<C-x>"] = "noop",
					["[g"] = "noop",
					["]g"] = "noop",
					["i"] = "show_file_details",
					["oc"] = "noop",
					["od"] = "noop",
					["og"] = "noop",
					["om"] = "noop",
					["on"] = "noop",
					["os"] = "noop",
					["ot"] = "noop",
				},
				fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
					["<down>"] = "move_cursor_down",
					["<up>"] = "move_cursor_up",
				},
			},
		},
	},
	config = function(_, opts)
		local function on_move(data)
			Snacks.rename.on_rename_file(data.source, data.destination)
		end

		local events = require("neo-tree.events")
		opts.event_handlers = opts.event_handlers or {}
		vim.list_extend(opts.event_handlers, {
			{ event = events.FILE_MOVED, handler = on_move },
			{ event = events.FILE_RENAMED, handler = on_move },
		})
		require("neo-tree").setup(opts)
		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*lazygit",
			callback = function()
				if package.loaded["neo-tree.sources.git_status"] then
					require("neo-tree.sources.git_status").refresh()
				end
			end,
		})
	end,
}

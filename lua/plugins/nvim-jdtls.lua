-- Java LSP (jdtls) 轻量集成（仅代码跳转，不含 DAP/测试）
-- 使用说明：
-- 1. JDK 路径默认读取 $JAVA_HOME，也可在 opts.jdtls_jdk 中指定启动 jdtls 的 JDK（需 >= 21）
-- 2. 项目配置（<项目根>/.nvim/java.json）支持以下字段：
--      project_jdk          项目 JDK 路径，未配置取 $JAVA_HOME
--      maven_settings       Maven 用户级 settings.xml 路径（镜像、私服认证等）
--      maven_global_settings Maven 全局 settings.xml 路径
--      maven_offline        true 启用离线模式，默认 false
--      lombok_jar           lombok.jar 路径
-- 3. 注意：jdtls 使用内置 m2e 导入 Maven 项目，不依赖系统 mvn，Maven 版本随 jdtls 固定
-- 4. 打开 .java 文件后 jdtls 自动启动，运行 :LspInfo 确认状态
-- 5. 可选 Lombok：优先取 .nvim/java.json 的 lombok_jar → opts.lombok_jar → mason 包 "lombok" 自动检测
if true then
	return false
end
local M = {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	event = { "VimEnter" },
	opts = {
		-- 启动 jdtls 所用 JDK 路径，nil 时自动读取 $JAVA_HOME（需 >= 21）
		jdtls_jdk = nil,
		-- Maven 用户级 settings.xml 全局路径（可被 .nvim/java.json 的 maven_settings 覆盖）
		maven_settings = nil,
		-- 是否全局启用 Maven 离线模式（可被 .nvim/java.json 的 maven_offline 覆盖）
		maven_offline = false,
		lombok_jar = nil,
	},
	config = function(_, opts)
		-- ── 以下代码只在插件首次加载时执行一次 ──────────────────────────

		-- 解析 jdtls 启动 JDK：opts.jdtls_jdk → $JAVA_HOME；两者均未配置则报错并退出
		local jdtls_jdk = opts.jdtls_jdk or os.getenv("JAVA_HOME")
		if not jdtls_jdk then
			vim.notify(
				"[nvim-jdtls] 未检测到 jdtls JDK，请设置 $JAVA_HOME 或在 opts.jdtls_jdk 中配置路径",
				vim.log.levels.ERROR,
				{ title = "nvim-jdtls" }
			)
			return
		end

		-- 解析 Mason jdtls 安装路径及 launcher jar（直接使用约定路径，不依赖 mason-registry API）
		local mason_packages = vim.fn.stdpath("data") .. "/mason/packages"
		local jdtls_path = mason_packages .. "/jdtls"

		local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
		if launcher == "" then
			vim.notify(
				"[nvim-jdtls] launcher jar 未找到，请通过 :Mason 安装 jdtls",
				vim.log.levels.ERROR,
				{ title = "nvim-jdtls" }
			)
			return
		end

		-- 解析全局 lombok：opts.lombok_jar → mason 自动检测
		-- 使用 -javaagent 加载，让 jdtls 能识别 @Data/@Builder 等注解生成的成员
		local global_lombok = opts.lombok_jar
		if not global_lombok then
			local found = vim.fn.glob(mason_packages .. "/lombok/*.jar")
			global_lombok = found ~= "" and found or nil
		end
		if not global_lombok then
			vim.notify(
				"[nvim-jdtls] 未找到 lombok.jar，Lombok 注解将无法解析\n"
					.. "可在 .nvim/java.json 配置 lombok_jar，或通过 :Mason 安装 lombok",
				vim.log.levels.WARN,
				{ title = "nvim-jdtls" }
			)
		end

		-- 静态 JVM 参数（不含 -javaagent/-jar/-data，这三项在每次 make_config 中追加）
		local base_cmd = {
			jdtls_jdk .. "/bin/java",
			"-Dfile.encoding=UTF-8",
			"-XX:+UseZGC",
			"-XX:+UseStringDeduplication",
			"-Xms256m",
			"-Xmx2048m",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
		}

		-- ── 以下函数每次打开 Java 文件时调用，只处理与当前 buffer/项目相关的部分 ──

		local function make_config()
			-- 仅使用基础 LSP 能力（支持代码跳转），不引入 blink.cmp 的补全能力
			local caps = vim.lsp.protocol.make_client_capabilities()
			caps.general = caps.general or {}
			caps.general.positionEncodings = { "utf-16" } -- jdtls 期望 utf-16

			-- 发现项目根目录（依赖当前 buffer，必须每次获取）
			-- 优先找 .git / wrapper 脚本（多模块项目的真正根），再 fallback 到最近的 pom.xml
			local buf = vim.api.nvim_get_current_buf()
			local root = vim.fs.root(buf, { "gradlew", "mvnw", ".git" })
				or vim.fs.root(buf, { "pom.xml", "build.gradle" })
				or vim.fn.getcwd()

			-- 每个项目独立 workspace，避免索引缓存互相污染
			local workspace = vim.fn.stdpath("data") .. "/jdtls/workspace/" .. vim.fn.fnamemodify(root, ":t")

			-- 读取项目配置文件 .nvim/java.json
			local project_jdk = nil
			local maven_user_settings = nil
			local maven_global_settings = nil
			local maven_offline = false
			local lombok_jar = nil
			local cfg_file = root .. "/.nvim/java.json"
			if vim.uv.fs_stat(cfg_file) then
				local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(cfg_file), "\n"))
				if ok and type(data) == "table" then
					if type(data.project_jdk) == "string" and data.project_jdk ~= "" then
						project_jdk = data.project_jdk
					end
					if type(data.maven_settings) == "string" and data.maven_settings ~= "" then
						maven_user_settings = data.maven_settings
					end
					if type(data.maven_global_settings) == "string" and data.maven_global_settings ~= "" then
						maven_global_settings = data.maven_global_settings
					end
					if type(data.maven_offline) == "boolean" then
						maven_offline = data.maven_offline
					end
					if type(data.lombok_jar) == "string" and data.lombok_jar ~= "" then
						lombok_jar = data.lombok_jar
					end
				end
			end

			-- 解析项目 JDK：.nvim/java.json → $JAVA_HOME
			project_jdk = project_jdk or os.getenv("JAVA_HOME")
			if not project_jdk then
				vim.notify(
					"[nvim-jdtls] 未检测到项目 JDK，请设置 $JAVA_HOME 或在 .nvim/java.json 中配置 project_jdk",
					vim.log.levels.WARN,
					{ title = "nvim-jdtls" }
				)
			end

			-- 解析 Maven 配置：.nvim/java.json → opts 全局配置
			maven_user_settings = maven_user_settings or opts.maven_settings
			if not maven_offline then
				maven_offline = opts.maven_offline
			end

			-- 构建最终 cmd：复制静态参数，追加项目级 lombok 和 launcher
			-- .nvim/java.json 的 lombok_jar 可覆盖全局 global_lombok
			local cmd = vim.list_extend({}, base_cmd)
			local lombok = lombok_jar or global_lombok
			if lombok then
				table.insert(cmd, string.format("-javaagent:%s", lombok))
			end
			vim.list_extend(cmd, {
				"-jar",
				launcher,
				"-configuration",
				jdtls_path .. "/config_mac",
				"-data",
				workspace,
			})

			return {
				cmd = cmd,
				root_dir = root,
				capabilities = caps,
				-- bundles 留空：不加载 java-debug / vscode-java-test 扩展
				init_options = { bundles = {} },
				settings = {
					java = {
						-- jdtls 使用内置 m2e（非系统 mvn），Maven 版本随 jdtls 版本固定
						import = {
							maven = {
								java = { home = project_jdk },
								userSettings = maven_user_settings,
								globalSettings = maven_global_settings,
								offline = maven_offline,
							},
							gradle = { java = { home = project_jdk } },
						},
					},
				},
			}
		end

		-- 每次打开 Java 文件时附加 jdtls（支持同时打开多个 Java 文件）
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				if vim.bo.buftype ~= "" then
					return
				end
				require("jdtls").start_or_attach(make_config())
			end,
		})

		-- config 函数在首个 Java 文件触发插件加载时执行，此时 FileType 事件已过，需手动附加当前缓冲区
		if vim.bo.filetype == "java" and vim.bo.buftype == "" then
			require("jdtls").start_or_attach(make_config())
		end

		-- 打开 Maven/Gradle 项目时自动预热 jdtls，无需等到第一个 Java 文件
		local function prewarm()
			local cwd = vim.fn.getcwd()
			-- 仅在 Maven/Gradle 项目目录下触发（检查 cwd 或其父级）
			if
				not (
					vim.uv.fs_stat(cwd .. "/pom.xml")
					or vim.uv.fs_stat(cwd .. "/build.gradle")
					or vim.uv.fs_stat(cwd .. "/gradlew")
					or vim.uv.fs_stat(cwd .. "/mvnw")
				)
			then
				return
			end
			-- 与 make_config() 保持一致：优先 .git/wrapper，再 pom.xml
			local root = vim.fs.root(0, { "gradlew", "mvnw", ".git" })
				or vim.fs.root(0, { "pom.xml", "build.gradle" })
				or cwd
			-- 该根目录已有 jdtls 实例则跳过
			for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
				if client.config.root_dir == root then
					return
				end
			end
			require("jdtls").start_or_attach(make_config())
		end

		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			callback = function()
				vim.schedule(prewarm)
			end,
		})
		-- 若 config() 本身由 VimEnter 触发，VimEnter autocmd 不会再次触发，直接执行
		vim.schedule(prewarm)
	end,
}

return M

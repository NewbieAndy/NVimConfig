-- Java LSP (jdtls) 轻量集成（仅代码跳转，不含 DAP/测试）
-- 使用说明：
-- 1. JDK 路径默认读取 $JAVA_HOME，也可在 opts.jdtls_jdk 中指定启动 jdtls 的 JDK（需 >= 21）
-- 2. 项目 JDK：在 <项目根>/.nvim/java.json 中配置 { "project_jdk": "/path/to/jdk" }，未配置时取 $JAVA_HOME
-- 3. 打开 .java 文件后 jdtls 自动启动，运行 :LspInfo 确认状态
-- 4. 可选 Lombok：在 .nvim/java.json 中配置 { "lombok_jar": "/path/to/lombok.jar" }
--    未配置时取 opts.lombok_jar，再未配置则尝试 mason 包 "lombok" 自动检测
local M = {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	dependencies = { "mason-org/mason.nvim" },
	opts = {
		-- 启动 jdtls 所用 JDK 路径，nil 时自动读取 $JAVA_HOME（需 >= 21）
		jdtls_jdk = nil,
		lombok_jar = nil,
	},
	config = function(_, opts)
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

		-- 构建单次附加所需的 jdtls 配置（每次 FileType 事件调用一次）
		local function make_config()
			-- 仅使用基础 LSP 能力（支持代码跳转），不引入 blink.cmp 的补全能力
			local caps = vim.lsp.protocol.make_client_capabilities()
			caps.general = caps.general or {}
			caps.general.positionEncodings = { "utf-16" } -- jdtls 期望 utf-16

			-- 发现项目根目录
			local buf = vim.api.nvim_get_current_buf()
			local root = vim.fs.root(buf, { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" })
				or vim.fn.getcwd()

			-- 每个项目独立 workspace，避免索引缓存互相污染
			local workspace = vim.fn.stdpath("data")
				.. "/jdtls/workspace/"
				.. vim.fn.fnamemodify(root, ":t")

			-- 读取项目配置文件 .nvim/java.json
			local project_jdk = nil
			local maven_user_settings = nil
			local lombok_jar = nil
			local cfg_file = root .. "/.nvim/java.json"
			if vim.uv.fs_stat(cfg_file) then
				local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(cfg_file), "\n"))
				if ok and type(data) == "table" then
					if type(data.project_jdk) == "string" then
						project_jdk = data.project_jdk
					end
					if type(data.maven_settings) == "string" then
						maven_user_settings = data.maven_settings
					end
					if type(data.lombok_jar) == "string" then
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

			-- 解析 Mason jdtls 安装路径
			local mr_ok, mr = pcall(require, "mason-registry")
			local jdtls_path
			if mr_ok and mr.has_package("jdtls") then
				jdtls_path = mr.get_package("jdtls"):get_install_path()
			else
				jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
			end

			local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
			if launcher == "" then
				vim.notify(
					"[nvim-jdtls] launcher jar 未找到，请通过 :Mason 安装 jdtls",
					vim.log.levels.ERROR,
					{ title = "nvim-jdtls" }
				)
				return nil
			end

			-- Lombok：.nvim/java.json → opts.lombok_jar → mason 自动检测
			-- 使用 -javaagent 加载，让 jdtls 能识别 @Data/@Builder 等注解生成的成员
			local lombok = lombok_jar or opts.lombok_jar
			if not lombok and mr_ok and mr.has_package("lombok") then
				local found = vim.fn.glob(mr.get_package("lombok"):get_install_path() .. "/*.jar")
				lombok = found ~= "" and found or nil
			end
			if not lombok then
				vim.notify(
					"[nvim-jdtls] 未找到 lombok.jar，Lombok 注解将无法解析\n"
						.. "可在 .nvim/java.json 配置 lombok_jar，或通过 :Mason 安装 lombok",
					vim.log.levels.WARN,
					{ title = "nvim-jdtls" }
				)
			end

			-- 构建 JVM 启动命令（使用 jdtls_jdk 启动服务，与项目 JDK 无关）
			local cmd = {
				jdtls_jdk .. "/bin/java",
				"-Dfile.encoding=UTF-8",
				"-XX:+UseZGC",
				"-XX:+UseStringDeduplication",
				"-Xms256m",
				"-Xmx2048m",
				"--add-opens", "java.base/java.util=ALL-UNNAMED",
				"--add-opens", "java.base/java.lang=ALL-UNNAMED",
			}
			if lombok then
				table.insert(cmd, string.format("-javaagent:%s", lombok))
			end
			vim.list_extend(cmd, {
				"-jar", launcher,
				"-configuration", jdtls_path .. "/config_mac",
				"-data", workspace,
			})

			return {
				cmd = cmd,
				root_dir = root,
				capabilities = caps,
				-- bundles 留空：不加载 java-debug / vscode-java-test 扩展
				init_options = { bundles = {} },
				settings = {
					java = {
						-- 告知 jdtls 用哪个 JDK 导入 Maven/Gradle 项目（影响依赖解析和类路径，跳转依赖此项）
						import = {
							maven = {
								java = { home = project_jdk },
								userSettings = maven_user_settings,
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
				local cfg = make_config()
				if cfg then
					require("jdtls").start_or_attach(cfg)
				end
			end,
		})

		-- config 函数在首个 Java 文件触发插件加载时执行，此时 FileType 事件已过，需手动附加当前缓冲区
		if vim.bo.filetype == "java" and vim.bo.buftype == "" then
			local cfg = make_config()
			if cfg then
				require("jdtls").start_or_attach(cfg)
			end
		end
	end,
}

return M

-- Java LSP (jdtls) lightweight integration (no DAP/test)
-- Usage:
-- 1. Ensure JDK21 installed at /Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home (configurable via opts.jdtls_jdk).
-- 2. For per-project JDK (JDK8), create <project>/.nvim/java.json with { "project_jdk": "/path/to/jdk8" }
--    or set in .neoconf.json: { "java": { "projectJDK": "/path/to/jdk8" } }.
-- 3. Open a .java file; jdtls will start automatically. Run :LspInfo to verify.
-- 4. Change opts.jdtls_jdk to switch the runtime used for launching jdtls.
-- 5. Optional Lombok: place lombok.jar path into opts.lombok_jar or install mason package "lombok".

local M = {
	"mfussenegger/nvim-jdtls",
	ft = { "java" },
	dependencies = { "mason-org/mason.nvim" },
	opts = {
		jdtls_jdk = "/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home", -- LSP run JDK
		lombok_jar = nil, -- e.g. vim.fn.expand("~/lib/lombok.jar") or mason lombok jar auto-detected
	},
	config = function(_, opts)
		-- 获取并合并 LSP 能力（补全、编码位置等），保持与全局 blink.cmp 一致
		local function get_capabilities()
			local caps = (pcall(require, "blink.cmp") and require("blink.cmp").get_lsp_capabilities())
				or vim.lsp.protocol.make_client_capabilities()
			caps.general = caps.general or {}
			caps.general.positionEncodings = { "utf-16" } -- 与多数 Java 语言服务期望一致
			return caps
		end
		-- 发现项目根目录：优先构建/版本控制标记
		local function find_root(markers)
			markers = markers or { "gradlew", "mvnw", "pom.xml", "build.gradle", ".git" }
			local buf = vim.api.nvim_get_current_buf()
			return vim.fs.root(buf, markers) or vim.fn.getcwd()
		end
		-- 为每个项目生成独立 workspace 目录，避免缓存互相污染
		local function java_workspace_dir(root)
			local name = vim.fn.fnamemodify(root, ":t")
			return vim.fn.stdpath("data") .. "/jdtls/workspace/" .. name
		end

		local root = find_root()
		if not root then
			return
		end

		-- 每项目解析 JDK（用于编译/代码分析），优先 .nvim/java.json
		local project_jdk = nil
		-- 每项目 Maven 用户级 settings.xml：优先 .nvim/java.json 的 maven_settings；若未配置则使用默认配置
		local maven_user_settings = nil

    -- 读取项目配置文件 .nvim/java.json
		local cfg_file = root .. "/.nvim/java.json"
		if vim.loop.fs_stat(cfg_file) then
			local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(cfg_file), "\n"))
			if ok and type(data) == "table" then
				if type(data.project_jdk) == "string" then
					project_jdk = data.project_jdk
				end
				if type(data.maven_settings) == "string" then
					maven_user_settings = data.maven_settings
				end
			end
		end

		project_jdk = project_jdk or os.getenv("JAVA_HOME")
		if not project_jdk then
			-- 未找到项目 JDK，提示用户配置（不会阻止 jdtls 启动，但可能缺少正确的编译目标）
			vim.notify(
				"[nvim-jdtls] 未检测到项目 JDK，请设置 JAVA_HOME 或在 .nvim/java.json 中提供 { 'project_jdk': '/path/to/jdk' }",
				vim.log.levels.WARN,
				{ title = "nvim-jdtls" }
			)
		end

		-- Mason jdtls path (robust across mason versions)
		local mr_ok, mr = pcall(require, "mason-registry")
		local jdtls_path
		if mr_ok and mr.has_package("jdtls") then
			local jdtls_pkg = mr.get_package("jdtls")
			jdtls_path = (jdtls_pkg.get_install_path and jdtls_pkg:get_install_path())
				or jdtls_pkg.install_path
				or (vim.fn.stdpath("data") .. "/mason/packages/jdtls")
		else
			jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
		end

		-- Launcher & config
		local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
		if launcher == "" then
			return
		end

		local config_dir = jdtls_path .. "/config_mac" -- macOS

		-- Lombok autodetect if not provided
		local lombok = opts.lombok_jar
		if not lombok and mr.has_package("lombok") then
			local lpkg = mr.get_package("lombok")
			lombok = vim.fn.glob(lpkg:get_install_path() .. "/*.jar")
			if lombok == "" then
				lombok = nil
			end
		end

		-- 使用 JDK21 启动 jdtls（与项目 JDK 无关），可在 opts.jdtls_jdk 中修改
		local cmd = { opts.jdtls_jdk .. "/bin/java" }
		-- JVM 启动参数：编码、内存、以及 --add-opens 以兼容部分反射/代理库
		vim.list_extend(cmd, {
			"-Dfile.encoding=UTF-8",
			"-XX:+UseZGC",
			"-XX:+UseStringDeduplication",
			"-Xms256m",
			"-Xmx2048m",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
		})
		if lombok then
			table.insert(cmd, string.format("-javaagent:%s", lombok))
		end
		table.insert(cmd, "-jar")
		table.insert(cmd, launcher)
		table.insert(cmd, "-configuration")
		table.insert(cmd, config_dir)
		table.insert(cmd, "-data")
		table.insert(cmd, java_workspace_dir(root))

		-- jdtls 运行时配置：声明项目支持的 JDK 版本，默认使用 21（用于语言服务特性），保留 1.8 保持兼容
		local runtimes = {
			{ name = "JavaSE-1.8", path = project_jdk },
			{ name = "JavaSE-21", path = opts.jdtls_jdk, default = true },
		}

		-- jdtls 设置：runtimes + Maven/Gradle 导入配置（仅指定项目 JDK 与用户级 settings.xml）
		local settings = {
			java = {
				configuration = { runtimes = runtimes },
				import = {
					maven = {
						java = { home = project_jdk },
						userSettings = maven_user_settings,
					},
					gradle = { java = { home = project_jdk } },
				},
			},
		}

		local jdtls_config = {
			cmd = cmd,
			root_dir = root,
			settings = settings,
			capabilities = get_capabilities(),
		}

		-- 重要说明：以下调用会触发 jdtls 对项目进行导入/配置解析。
		-- jdtls 在解析 Maven/Gradle 项目并建立类路径时，可能在项目根目录生成：
		--  - .settings/              （Eclipse 项目偏好，例如 org.eclipse.jdt.core.prefs）
		--  - .project / .classpath   （Eclipse 项目描述与类路径文件）
		-- 这些文件由 jdtls 服务端（Eclipse JDT/m2e）写入，不是 Lua 代码直接创建；
		-- 生成行为与以下设置有关：
		--  - settings.java.configuration.updateBuildConfiguration = "automatic"
		--  - settings.java.import.maven.enabled = true / gradle.enabled = true
		-- 当在普通文件缓冲区附着 jdtls 时，上述导入流程被触发。
		-- Only attach in normal file buffers
		if vim.bo.buftype == "" then
			require("jdtls").start_or_attach(jdtls_config)
		end
	end,
}

return M

local M = {}

M.servers = {
	"ts_ls",
	"html",
	"cssls",
	"lua_ls",
	"graphql",
	"basedpyright",
	"eslint",
	"gopls",
	"templ",
	"terraformls",
	"yamlls",
	"bashls",
	"rust_analyzer",
	"omnisharp",
}

M.setup = function()
	require("nvchad.configs.lspconfig").defaults()

	vim.lsp.config.ts_ls = {
		init_options = {
			preferences = {
				importModuleSpecifierPreference = "non-relative",
				importModuleSpecifierEnding = "minimal",
			},
		},
	}

	vim.lsp.config.basedpyright = {
		-- Override basedpyright-langserver with local basedbasedpyrigth-langserver symlinked binary.
		-- To link, run `npm link` in ~/personal-projects/basedpyright/packages/pyright
		cmd = { "basedbasedpyright-langserver", "--stdio" },
		settings = {
			basedpyright = {
				analysis = {
					typeCheckingMode = "basic",
				},
			},
		},
	}

	vim.lsp.enable(M.servers)
end

return M

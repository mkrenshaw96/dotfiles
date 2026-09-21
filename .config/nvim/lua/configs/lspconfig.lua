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
	"marksman",
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

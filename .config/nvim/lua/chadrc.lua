---@diagnostic disable: cast-local-type

-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

local stl_utils = require "nvchad.stl.utils"
local lspconfig = require "configs.lspconfig"

--@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "gruvchad",

	transparency = true,

	hl_add = {
		FlashMatch = { fg = "cyan", bg = "transparent" },
		FlashCurrent = { fg = "cyan", bg = "transparent" },
		FlashLabel = { fg = "pink", bg = "transparent" },
		SnacksIndent = { fg = "black2" },
		SnacksIndentScope = { fg = "light_grey" },
		StMode = { fg = "black", bg = "white" },
		StGit = { fg = "grey", bg = "transparent" },
		STSpacer = { fg = "transparent", bg = "transparent" },
		StWinbar = { fg = "white", bg = "transparent" },
		MiniTablineCurrent = { fg = "white", bg = "transparent" },
		MiniTablineVisible = { fg = "white", bg = "transparent" },
		MiniTablineHidden = { fg = "grey", bg = "transparent" },
		MiniTablineModifiedCurrent = { fg = "white", bg = "transparent" },
		MiniTablineModifiedVisible = { fg = "white", bg = "transparent" },
		MiniTablineModifiedHidden = { fg = "grey", bg = "transparent" },
		MiniTablineFill = { fg = "transparent", bg = "transparent" },
	},

	hl_override = {
		StText = { fg = "white", bg = "transparent" },
		St_Lsp = { fg = "white", bg = "transparent" },
	},

	changed_themes = {
		gruvchad = {
			base_30 = {
				white = "#fbf1c7",
				transparent = "black",
			},
		},
		catppuccin = {
			base_30 = {
				white = "#fbf1c7",
				transparent = "black",
			},
		},
	},
}

M.ui = {
	lsp = {
		signature = false,
	},

	statusline = {
		theme = "vscode_colored",

		order = { "mode", "git", "spacer", "diagnostics", "lsp" },

		modules = {
			mode = function()
				if not stl_utils.is_activewin() then
					return ""
				end

				local modes = stl_utils.modes

				local m = vim.api.nvim_get_mode().mode

				return "%#StMode#" .. " " .. modes[m][1]:sub(1, 1) .. " "
			end,

			relative_path = function()
				return "%#StText#" .. " " .. vim.fn.expand "%:." .. " "
			end,

			lsp = function()
				return "%#St_Lsp#" .. stl_utils.lsp():gsub("  LSP ~", ""):gsub(" ", "")
			end,

			git = function()
				if not vim.b[stl_utils.stbufnr()].gitsigns_head or vim.b[stl_utils.stbufnr()].gitsigns_git_status then
					return ""
				end

				local git_status = vim.b[stl_utils.stbufnr()].gitsigns_status_dict

				local branch_name = " " .. git_status.head

				return "%#STGit#" .. " " .. branch_name .. " "
			end,

			diagnostics = function()
				if not rawget(vim, "lsp") then
					return ""
				end

				local err = #vim.diagnostic.get(stl_utils.stbufnr(), { severity = vim.diagnostic.severity.ERROR })
				local warn = #vim.diagnostic.get(stl_utils.stbufnr(), { severity = vim.diagnostic.severity.WARN })
				local hints = #vim.diagnostic.get(stl_utils.stbufnr(), { severity = vim.diagnostic.severity.HINT })
				local info = #vim.diagnostic.get(stl_utils.stbufnr(), { severity = vim.diagnostic.severity.INFO })

				err = (err and err > 0) and ("%#StText#" .. " " .. err .. " ") or ""
				warn = (warn and warn > 0) and ("%#StText#" .. " " .. warn .. " ") or ""
				hints = (hints and hints > 0) and ("%#StText#" .. " " .. hints .. " ") or ""
				info = (info and info > 0) and ("%#StText#" .. " " .. info .. " ") or ""

				return " " .. err .. warn .. hints .. info
			end,

			spacer = function()
				return "%#STSpacer#" .. "%="
			end,
		},
	},

	tabufline = {
		enabled = false,
	},

	mason = {
		-- Merge LSP servers and formatters for conform.nvim
		pkgs = vim.list_extend(vim.deepcopy(lspconfig.servers), {
			"prettierd",
			"stylua",
			"shfmt",
			"black",
		}),
	},
}

return M

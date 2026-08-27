return {
	{
		"christoomey/vim-tmux-navigator",
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
		},
		config = function()
			vim.g.tmux_navigator_disable_when_zoomed = 1
		end,
	},
	{
		"folke/which-key.nvim",
		opts = {
			plugins = {
				spelling = {
					enabled = true,
					suggestions = 20,
				},
			},
		},
	},
	{
		"hrsh7th/nvim-cmp",
		config = function(_, opts)
			require("configs.cmp").setup(opts)
		end,
		-- From https://github.com/NvChad/NvChad/discussions/2662#discussioncomment-8436932
		dependencies = {
			{
				"hrsh7th/cmp-cmdline",
				event = { "CmdLineEnter" },
				opts = { history = true, updateevents = "CmdlineEnter,CmdlineChanged" },
				config = function()
					local cmp = require "cmp"

					cmp.setup.cmdline("/", {
						mapping = cmp.mapping.preset.cmdline(),
						sources = {
							{ name = "buffer" },
						},
					})

					cmp.setup.cmdline(":", {
						mapping = cmp.mapping.preset.cmdline(),
						sources = cmp.config.sources({
							{ name = "path" },
						}, {
							{
								name = "cmdline",
								option = {
									ignore_cmds = { "Man", "!" },
								},
								keyword_length = 2,
							},
						}),
					})
				end,
			},
		},
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "echasnovski/mini.icons" },
		opts = {
			keymaps = {
				["<ESC>"] = "actions.close",
				["<leader>e"] = "actions.close",
				["<BS>"] = "actions.parent",
			},
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git" or name == ".DS_Store"
				end,
			},
			win_options = {
				wrap = true,
				winbar = "%!v:lua.get_oil_winbar()",
			},
		},
		event = "VeryLazy",
		cmd = "Oil",
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		-- @type Flash.Config
		opts = {
			label = {
				uppercase = false,
			},
			modes = {
				char = {
					jump_labels = true,
				},
			},
		},
	},
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {},
	},
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			keywords = {
				FIX = {
					alt = { "LOOK", "HERE" },
				},
			},
		},
	},
	{
		"echasnovski/mini.tabline",
		event = "VeryLazy",
		version = "*",
		opts = {
			show_icons = false,
			format = function(buf_id, label)
				local suffix = vim.bo[buf_id].modified and " " or ""
				return MiniTabline.default_format(buf_id, label) .. suffix
			end,
		},
	},
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		version = "*",
		dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
		config = function()
			require("mini.ai").setup {
				custom_textobjects = {
					-- Function definition (needs treesitter queries with these captures)
					f = require("mini.ai").gen_spec.treesitter { a = "@function.outer", i = "@function.inner" },
					F = require("mini.ai").gen_spec.treesitter { a = "@call.outer", i = "@call.inner" },
				},
			}
		end,
	},
	{
		"echasnovski/mini.surround",
		event = "VeryLazy",
		version = "*",
		opts = {
			mappings = {
				add = "as",
				delete = "",
				replace = "",
				find = "",
				find_left = "",
				highlight = "",
				update_n_lines = "",
			},
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				signature = {
					enabled = false,
				},
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {},
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "BufReadPost",
		opts = {
			mode = "cursor",
			max_lines = 3,
		},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			lazygit = {
				configure = false,
			},
			indent = {
				enabled = true,
			},
			input = {
				enabled = true,
			},
			notifier = {
				enabled = true,
			},
			bigfile = {
				enabled = true,
			},
		},
	},
	{
		"folke/sidekick.nvim",
		opts = {
			cli = {
				-- notify Neovim of file changes done by AI CLI tools
				watch = true,
				mux = {
					backend = "tmux",
					enabled = true,
				},
				win = {
					split = {
						width = 0,
						height = 0,
					},
				},
			},
			nes = {
				enabled = false,
			},
		},
		keys = {
			{
				"<leader>st",
				function()
					require("sidekick.cli").toggle { name = "claude", focus = true }
				end,
				desc = "Sidekick Toggle",
			},
			{
				"<leader>ss",
				function()
					require("sidekick.cli").send { name = "claude", focus = true, msg = "{this}" }
				end,
				mode = { "x", "n" },
				desc = "Sidekick Send Visual Selection",
			},
			{
				"<leader>sf",
				function()
					require("sidekick.cli").send { name = "claude", focus = true, msg = "{file}" }
				end,
				desc = "Sidekick Send File",
			},
			{
				"<leader>sp",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lspconfig").setup()
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"json",
				"javascript",
				"typescript",
				"tsx",
				"yaml",
				"html",
				"css",
				"prisma",
				"markdown",
				"markdown_inline",
				"svelte",
				"graphql",
				"bash",
				"lua",
				"vim",
				"dockerfile",
				"gitignore",
				"query",
				"vimdoc",
				"c",
				"python",
				"terraform",
				"hcl",
				"regex",
			},
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				sh = { "shfmt" },
				javascript = { "prettierd" },
				javascriptreact = { "prettierd" },
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				vue = { "prettierd" },
				css = { "prettierd" },
				scss = { "prettierd" },
				less = { "prettierd" },
				html = { "prettierd" },
				json = { "prettierd" },
				jsonc = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				["markdown.mdx"] = { "prettierd" },
				graphql = { "prettierd" },
				handlebars = { "prettierd" },
				toml = { "prettierd" },
				svelte = { "prettierd" },
				-- Python is formatted by AutoCMD using black
				-- python = { "black" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
}

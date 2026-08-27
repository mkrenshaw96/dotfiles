require "nvchad.mappings"

local nomap = vim.keymap.del
local map = vim.keymap.set

nomap("n", "<leader>v")
nomap("n", "<leader>h")
nomap("n", "<leader>n")
nomap("n", "<leader>rn")
nomap("n", "<leader>e")
nomap("n", "<C-n>")
nomap("n", "<leader>gt")

-- General
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })
map("n", "<leader>q", "<cmd> copen<CR>", { desc = "Open quickfix list" })
map("n", "<leader>Q", "<cmd> cclose<CR>", { desc = "Close quickfix list" })
map({ "n", "v" }, "<tab>", "<cmd>bnext<CR>", { desc = "buffer goto next" })
map({ "n", "v" }, "<S-tab>", "<cmd>bprev<CR>", { desc = "buffer goto prev" })
map({ "n", "v" }, "<leader>x", "<cmd>bwipeout<CR>", { desc = "buffer close" })

-- LSP
map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP rename" })
map("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
map("n", "<leader>lf", vim.diagnostic.open_float, { desc = "LSP floating diagnostics" })
map("n", "<leader>d", vim.lsp.buf.hover, { desc = "LSP hover" })

-- Navigation
map({ "n", "x", "o" }, "J", "}", { desc = "Move to next paragrah" })
map({ "n", "x", "o" }, "K", "{", { desc = "Move to prev paragrah" })
map("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { desc = "Window left" })
map("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>", { desc = "Window right" })
map("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>", { desc = "Window down" })
map("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>", { desc = "Window up" })

map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Telescope
map("n", "<leader>km", "<cmd> Telescope keymaps<CR>", { desc = "Telescope keymaps" })
map("n", "<leader>fe", function()
	require("telescope.builtin").live_grep {
		additional_args = function()
			return { "--word-regexp", "--case-sensitive" }
		end,
	}
end, { desc = "Telescope live grep exact word with case match" })

-- Flash
map({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })

-- Trouble
map("n", "<leader>t", "<CMD>Trouble diagnostics toggle<CR>", { desc = "Toggle diagnostics" })

-- Todo Comments
map("n", "<leader>td", "<CMD>TodoTelescope keywords=HERE,LOOK<CR>", { desc = "Todo Comments" })
map("n", "<leader>tda", "<CMD>TodoTelescope<CR>", { desc = "Todo Comments" })

-- Oil
map("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Persistence
map("n", "<leader>sr", function()
	require("persistence").load()
end, { desc = "Session Restore restore session for cwd" })

-- Snacks
map("n", "<leader>gb", function()
	Snacks.git.blame_line()
end, { desc = "Snacks Git Blame Line" })
map("n", "<leader>lg", function()
	Snacks.lazygit()
end, { desc = "Snacks Lazygit" })
map("n", "<leader>gh", function()
	Snacks.lazygit.log_file()
end, { desc = "Snacks Lazygit Current File History" })

-- Gitsigns
map("n", "<leader>ph", function()
	require("gitsigns").preview_hunk()
end, { desc = "Gitsigns preview hunk" })
map("n", "<leader>rh", function()
	require("gitsigns").reset_hunk()
end, { desc = "Gitsigns reset hunk" })

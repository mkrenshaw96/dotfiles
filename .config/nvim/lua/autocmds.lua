require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Black format on save using local black installation
autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("BlackFormatter", { clear = true }),
	pattern = "*.py",
	command = [[:silent !black %]],
})

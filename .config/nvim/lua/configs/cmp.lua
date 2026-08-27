local cmp = require "cmp"

local utils = require "utils"

local M = {}

-- From https://github.com/NvChad/NvChad/discussions/2760#discussioncomment-8924561
M.setup = function(opts)
	opts.snippet.expand = nil

	opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_next_item()
		else
			fallback()
		end
	end, { "i", "s" })

	opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
		if cmp.visible() then
			cmp.select_prev_item()
		else
			fallback()
		end
	end, { "i", "s" })

	utils.removeFromTable(opts.sources, "luasnip")
	utils.removeFromTable(opts.sources, "buffer")

	cmp.setup(opts)
end

return M

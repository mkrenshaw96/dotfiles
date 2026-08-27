-- Declare a global function to retrieve the current directory
function _G.get_oil_winbar()
	local dir = require("oil").get_current_dir()
	if dir then
		return vim.fn.fnamemodify(dir, ":~")
	else
		-- If there is no current directory (e.g. over ssh), just show the buffer name
		return vim.api.nvim_buf_get_name(0)
	end
end

function _G.get_winbar()
	return string.gsub("%#StWinbar#" .. " " .. vim.fn.expand "%:." .. " ", "/", "  ")
end

local M = {}

M.getIndex = function(tab, val)
	local index = nil

	for i, v in ipairs(tab) do
		if v.name == val then
			index = i
		end
	end

	return index
end

M.removeFromTable = function(tab, val)
	local idx = M.getIndex(tab, val)

	if idx == nil then
		print "Key does not exist"
	else
		table.remove(tab, idx)
	end
end

return M

local M = {}

-- Create a single namespace for all our highlights
local ns_id = vim.api.nvim_create_namespace("GitConflictsHighlight")

function M.highlight_region(start_line, end_line, bg_color)
	-- Generate a unique name for this highlight group
	local hl_group_name = "GitConflictsHighlight" .. bg_color:gsub("#", "")

	-- Define the highlight group with only background color
	vim.api.nvim_set_hl(0, hl_group_name, { bg = bg_color })

	-- Apply background highlight to the entire region
	for line = start_line, end_line do
		vim.api.nvim_buf_add_highlight(0, ns_id, hl_group_name, line - 1, 0, -1)
	end
end

local function find_conflict_regions()
	local conflict_regions = {}
	local current_conflict = nil
	local current_buffer = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)

	for i, line in ipairs(lines) do
		if line:match("^<<<<<<<") then
			current_conflict = { start = i }
		elseif line:match("^=======") and current_conflict then
			current_conflict.mid = i
		elseif line:match("^>>>>>>>") and current_conflict and current_conflict.mid then
			current_conflict["end"] = i
			table.insert(conflict_regions, current_conflict)
			current_conflict = nil
		end
	end

	return conflict_regions
end

function M.highlight_conflicts()
	local regions = find_conflict_regions()
	for _, region in ipairs(regions) do
		-- set background color for above
		M.highlight_region(region["start"], region["mid"] - 1, "#405d7e")
		-- set background color for below
		M.highlight_region(region["mid"] + 1, region["end"], "#314753")
	end
end

function M.clear_highlights()
	-- Clear all highlights in this namespace
	vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M

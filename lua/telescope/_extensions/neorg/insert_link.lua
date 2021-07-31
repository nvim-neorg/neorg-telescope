local actions = require('telescope.actions')
local actions_set = require('telescope.actions.set')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

local neorg_loaded, _ = pcall(require, 'neorg.modules')

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_linkables()
	local ret = {}

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

	for i, line in ipairs(lines) do
		local heading = { line:match("^%s*(%*+%s+(.+))$") }
		if not vim.tbl_isempty(heading) then
			table.insert(ret, { line = i, linkable = heading[2], display = heading[1] })
		end

		local marker_or_drawer = { line:match("^%s*(%|%|?%s+(.+))$") }
		if not vim.tbl_isempty(marker_or_drawer) then
			table.insert(ret, { line = i, linkable = marker_or_drawer[2], display = marker_or_drawer[1] })
		end
	end

	return ret
end

return function(opts)
    opts = opts or {}

	pickers.new(opts, {
		prompt_title = "Insert Link",
        results_title = "Linkables",
        finder = finders.new_table({
            results = get_linkables(),
            entry_maker = function(entry)
                return {
                    value = entry.line,
                    display = entry.display,
                    ordinal = entry.linkable,
                    lnum = entry.line,
                }
            end,
        }),
        -- I couldn't get syntax highlight to work with this :(
        previewer = nil,
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions_set.select:replace(function()
                local entry = actions.get_selected_entry()
				actions.close(prompt_bufnr)
                vim.api.nvim_put({ "[" .. entry.ordinal:gsub(":$", "") .. "]" .. "(" .. entry.display:gsub("^(%W+)%s+.+", "%1") .. entry.ordinal:gsub("[%*#%|_]", "\\%1") .. ")" }, "c", false, true)
                vim.api.nvim_feedkeys("f)a", "t", false)
            end)
            return true
        end,
	}):find()
end

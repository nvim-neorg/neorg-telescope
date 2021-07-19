local neorg_loaded, neorg = pcall(require, 'neorg.modules')

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_current_workspace()
	local dirman = neorg.modules.get_module("core.norg.dirman")

	if dirman then
		local current_workspace = dirman.get_current_workspace()[2]

		return current_workspace
	end

	return nil
end

local function pick_headings(opts)
    opts = opts or {}

	local current_workspace = get_current_workspace()

	if current_workspace then
		require('telescope.builtin').grep_string({
			search = "^\\s*\\*+\\s+",
			use_regex = true,
			search_dirs = { current_workspace }
		})
	end
end

return pick_headings

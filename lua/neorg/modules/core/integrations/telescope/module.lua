--[[
	A Neorg module designed to integrate telescope.nvim
--]]

local neorg = require("neorg.core")

local module = neorg.modules.create("core.integrations.telescope")

module.setup = function()
    return { success = true, requires = { "core.dirman" } }
end

-- To add a new picker:
-- - Choose a name to add to this list (eg. <picker>)
-- - Create a file in `lua/telescope/_extensions/neorg/<picker>.lua`
-- - Add the picker to `lua/telescope/_extensions/neorg.lua`
-- - Add it to the list in the README

local pickers = {
    "find_linkable",
    "find_norg_files",
    "insert_link",
    "insert_file_link",
    "search_headings",
    "find_project_tasks",
    "find_aof_project_tasks",
    "find_aof_tasks",
    "find_context_tasks",
    "switch_workspace",
    "backlinks.file_backlinks",
    "backlinks.header_backlinks",
}

module.load = function()
    local telescope_loaded, telescope = pcall(require, "telescope")

    assert(telescope_loaded, telescope)

    telescope.load_extension("neorg")

    for _, picker in ipairs(pickers) do
        vim.keymap.set("", ("<Plug>(neorg.telescope.%s)"):format(picker), module.public[picker])
    end
end

module.config.public = {
    insert_file_link = {
        show_title_preview = true,
    },
}

module.public = {}

for _, picker in ipairs(pickers) do
    module.public[picker] = require(("telescope._extensions.neorg.%s"):format(picker))
end

return module

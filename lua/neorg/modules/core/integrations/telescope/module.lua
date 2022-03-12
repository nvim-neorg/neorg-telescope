--[[
	A Neorg module designed to integrate telescope.nvim
--]]

require("neorg.modules.base")

local module = neorg.modules.create("core.integrations.telescope")

module.setup = function()
    return { success = true, requires = { "core.keybinds", "core.norg.dirman" } }
end

module.load = function()
    local telescope_loaded, telescope = pcall(require, "telescope")

    assert(telescope_loaded, telescope)

    telescope.load_extension("neorg")

    module.required["core.keybinds"].register_keybinds(
        module.name,
        { "find_linkable", "insert_link", "insert_file_link", "search_headings", "find_project_tasks" }
    )
end

module.public = {
    find_linkable = require("telescope._extensions.neorg.find_linkable"),
    insert_link = require("telescope._extensions.neorg.insert_link"),
    insert_file_link = require("telescope._extensions.neorg.insert_file_link"),
    search_headings = require("telescope._extensions.neorg.search_headings"),
    find_project_tasks = require("telescope._extensions.neorg.find_project_tasks"),
}

module.on_event = function(event)
    if event.split_type[2] == "core.integrations.telescope.find_linkable" then
        module.public.find_linkable()
    elseif event.split_type[2] == "core.integrations.telescope.insert_link" then
        module.public.insert_link()
    elseif event.split_type[2] == "core.integrations.telescope.insert_file_link" then
        module.public.insert_file_link()
    elseif event.split_type[2] == "core.integrations.telescope.search_headings" then
        module.public.search_headings()
    elseif event.split_type[2] == "core.integrations.telescope.find_project_tasks" then
        module.public.find_project_tasks()
    end
end

module.events.subscribed = {
    ["core.keybinds"] = {
        ["core.integrations.telescope.find_linkable"] = true,
        ["core.integrations.telescope.insert_link"] = true,
        ["core.integrations.telescope.insert_file_link"] = true,
        ["core.integrations.telescope.search_headings"] = true,
        ["core.integrations.telescope.find_project_tasks"] = true,
    },
}

return module

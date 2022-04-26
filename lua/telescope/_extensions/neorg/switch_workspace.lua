local themes = require("telescope.themes")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local state = require("telescope.actions.state")
local conf = require("telescope.config").values

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

return function(options)
    local opts = options
        or themes.get_dropdown({
            border = true,
            previewer = false,
            shorten_path = false,
            prompt_prefix = " ◈  ",
            -- prompt_prefix = "  ",
            layout_config = {
                prompt_position = "top",
            },
        })

    local results = neorg.modules.get_module("core.norg.dirman").get_workspaces()
    results = vim.tbl_keys(results)

    pickers.new(opts, {
        prompt_title = "Choose workspace",
        finder = finders.new_table({
            results = results,
            entry_maker = opts.entry_maker,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            action_set.select:replace(function()
                local entry = state.get_selected_entry()
                actions.close(prompt_bufnr)
                neorg.modules.get_module("core.norg.dirman").open_workspace(entry[1])
            end)
            return true
        end,
    }):find()
end

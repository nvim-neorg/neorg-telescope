local neorg_loaded, neorg = pcall(require, "neorg.core")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_current_workspace()
    local dirman = neorg.modules.get_module("core.dirman")

    if dirman then
        local current_workspace = dirman.get_current_workspace()[2]

        return current_workspace
    end

    return nil
end

return function(opts)
    local current_workspace = get_current_workspace()
    if not current_workspace then
        return
    end

    local utils = require("telescope._extensions.neorg.utils")
    local pickers = require("telescope.pickers")
    local conf = require("telescope.config").values
    local make_entry = require("telescope.make_entry")

    local search = "^\\s*(\\*+|\\|{1,2}|\\${1,2})\\s+"

    opts = utils.copy_table(opts or {})
    opts.prompt_title = opts.prompt_title or "Find in Norg files"
    opts.entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)

    pickers
        .new(opts, {
            finder = utils.new_norg_finder(search, current_workspace, opts),
            previewer = utils.new_norg_previewer(),
            sorter = conf.generic_sorter(opts),
        })
        :find()
end

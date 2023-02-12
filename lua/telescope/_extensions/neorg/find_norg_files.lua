local neorg_loaded, _ = pcall(require, "neorg.modules")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values -- allows us to use the values from the users config
local make_entry = require("telescope.make_entry")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

--- Get a list of all norg files in current workspace. Returns { workspace_path, norg_files }
--- @return table?
local function get_norg_files()
    local dirman = neorg.modules.get_module("core.norg.dirman")

    if not dirman then
        return nil
    end

    local current_workspace = dirman.get_current_workspace()

    local norg_files = dirman.get_norg_files(current_workspace[1])

    return { current_workspace[2], norg_files }
end

return function(opts)
    opts = opts or {}

    local files = get_norg_files()

    if not (files and files[2]) then
        return
    end

    opts.entry_maker = opts.entry_maker or make_entry.gen_from_file(opts)

    pickers
        .new(opts, {
            prompt_title = opts.prompt_title or "Find Norg Files",
            cwd = files[1],
            finder = finders.new_table({
                results = files[2],
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.file_sorter(opts),
        })
        :find()
end

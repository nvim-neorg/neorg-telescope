local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local neorg_loaded, neorg = pcall(require, "neorg.core")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

--- Get a list of all norg files in current workspace. Returns { workspace_path, norg_files }
--- @return table
local function get_norg_files()
    local dirman = neorg.modules.get_module("core.dirman")

    if not dirman then
        return nil
    end

    local current_workspace = dirman.get_current_workspace()

    local norg_files = dirman.get_norg_files(current_workspace[1])

    return { current_workspace[2], norg_files }
end

--- Generate links for telescope
--- @return table
local function generate_links()
    local res = {}
    local dirman = neorg.modules.get_module("core.dirman")

    if not dirman then
        return nil
    end

    local files = get_norg_files()

    if not files[2] then
        return
    end
    if not (pcall(require, "pathlib")) then
        error("neorg-telescope Dependency Error: pysan3/pathlib.nvim is a required dependency.")
    end

    local ts = neorg.modules.get_module("core.integrations.treesitter")

    local Path = require("pathlib")
    for _, file in pairs(files[2]) do
        local bufnr = dirman.get_file_bufnr(tostring(file))

        local title = nil
        local title_display = ""
        if ts then
            local metadata = ts.get_document_metadata(bufnr)
            if metadata and metadata.title then
                title = metadata.title
                title_display = " [" .. title .. "]"
            end
        end

        if vim.api.nvim_get_current_buf() ~= bufnr then
            file = Path(file)
            local relative = file:relative_to(Path(files[1]))
            local links = {
                file = file,
                display = "$/" .. relative .. title_display,
                relative = relative:remove_suffix(".norg"),
                title = title,
            }
            table.insert(res, links)
        end
    end

    return res
end

return function(opts)
    opts = opts or {}

    pickers
        .new(opts, {
            prompt_title = "Insert Link to Neorg File",
            results_title = "Linkables",
            finder = finders.new_table({
                results = generate_links(),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry.display,
                        ordinal = entry.display,
                        relative = entry.relative,
                        title = entry.title,
                    }
                end,
            }),
            -- I couldn't get syntax highlight to work with this :(
            previewer = nil,
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions_set.select:replace(function()
                    local entry = state.get_selected_entry()

                    actions.close(prompt_bufnr)

                    vim.api.nvim_put({
                        "{" .. ":$/" .. entry.relative .. ":" .. "}" .. "[" .. (entry.title or entry.relative) .. "]",
                    }, "c", false, true)
                    vim.api.nvim_feedkeys("hf]a", "t", false)
                end)
                return true
            end,
        })
        :find()
end

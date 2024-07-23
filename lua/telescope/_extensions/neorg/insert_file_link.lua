local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local neorg_loaded, neorg = pcall(require, "neorg.core")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

--- Get a list of all norg files in current workspace. Returns { workspace_path, norg_files }
--- @return table|nil
local function get_norg_files()
    local dirman = neorg.modules.get_module("core.dirman")

    if not dirman then
        return nil
    end

    local current_workspace = dirman.get_current_workspace()

    local norg_files = dirman.get_norg_files(current_workspace[1])

    return { current_workspace[2], norg_files }
end

--- Get the title set in the metadata block of file
--- @param file string
--- @return string?
local function get_file_title(file)
    local dirman = neorg.modules.get_module("core.dirman")
    if not dirman then
        return nil
    end

    local ts = neorg.modules.get_module("core.integrations.treesitter")
    if not ts then
        return nil
    end

    local metadata = ts.get_document_metadata(file)
    if not metadata or not metadata.title then
        return nil
    end
    return metadata.title
end

--- Generate links for telescope
--- @return table|nil
local function generate_links(preview)
    local res = {}
    local dirman = neorg.modules.get_module("core.dirman")

    if not dirman then
        return nil
    end

    local files = get_norg_files()

    if not (files and files[2]) then
        return nil
    end
    if not (pcall(require, "pathlib")) then
        error("neorg-telescope Dependency Error: pysan3/pathlib.nvim is a required dependency.")
    end

    local Path = require("pathlib")
    for _, file in pairs(files[2]) do
        local bufnr = dirman.get_file_bufnr(tostring(file))
        if vim.api.nvim_get_current_buf() ~= bufnr then
            local title = nil
            local title_display = ""
            if preview then
                title = get_file_title(file)
                if title then
                    title_display = " [" .. title .. "]"
                end
            end

            file = Path(file)
            local relative = file:relative_to(Path(files[1])):tostring()

            local links = {
                file = file,
                display = "$/" .. relative .. title_display,
                relative = relative,
                title = title,
            }
            table.insert(res, links)
        end
    end

    return res
end

return function(opts)
    opts = opts or {}
    local config = require("neorg").modules.get_module_config("core.integrations.telescope").insert_file_link

    pickers
        .new(opts, {
            prompt_title = "Insert Link to Neorg File",
            results_title = "Linkables",
            finder = finders.new_table({
                results = generate_links(config.show_title_preview),
                entry_maker = function(entry)
                    return {
                        value = entry,
                        path = entry.file:tostring(),
                        display = entry.display,
                        ordinal = entry.display,
                        relative = entry.relative,
                        file = entry.file,
                        title = entry.title,
                    }
                end,
            }),
            previewer = conf.file_previewer(opts),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions_set.select:replace(function()
                    local entry = state.get_selected_entry()

                    actions.close(prompt_bufnr)
                    local title = entry.title
                    if not config.show_title_preview then
                        title = get_file_title(entry.file)
                    end

                    vim.api.nvim_put({
                        "{" .. ":$/" .. entry.relative .. ":" .. "}" .. "[" .. (title or entry.relative) .. "]",
                    }, "c", false, true)
                    vim.api.nvim_feedkeys("hf]a", "t", false)
                end)
                return true
            end,
        })
        :find()
end

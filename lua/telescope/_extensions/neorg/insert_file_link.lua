local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local neorg_loaded, _ = pcall(require, "neorg.modules")

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

    for _, file in pairs(files[2]) do
        local full_path_file = files[1] .. "/" .. file
        local bufnr = dirman.get_file_bufnr(full_path_file)

        if vim.api.nvim_get_current_buf() ~= bufnr then
            local links = { file = file }
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
                        display = entry.file,
                        ordinal = entry.file,
                    }
                end,
            }),
            -- I couldn't get syntax highlight to work with this :(
            previewer = nil,
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions_set.select:replace(function()
                    local entry = state.get_selected_entry()

                    local path_no_extension

                    if entry then
                        path_no_extension, _ = entry.value.file:gsub("%.norg$", "")
                    else
                        path_no_extension = state.get_current_line()
                    end

                    actions.close(prompt_bufnr)

                    local file_name, _ = path_no_extension:gsub(".*%/", "")

                    vim.api.nvim_put({
                        "{" .. ":$/" .. path_no_extension .. ":" .. "}" .. "[" .. file_name .. "]",
                    }, "c", false, true)
                    vim.api.nvim_feedkeys("hf]a", "t", false)
                end)
                return true
            end,
        })
        :find()
end

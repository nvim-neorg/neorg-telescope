local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require('telescope.actions.state')
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

--- Get a list of all norg files in current workspace. Returns { workspace_path, norg_files }
--- @return table
local function get_norg_files()
    local dirman = neorg.modules.get_module("core.norg.dirman")

    if not dirman then
        return nil
    end

    local current_workspace = dirman.get_current_workspace()

    local norg_files = dirman.get_norg_files(current_workspace[1])

    return { current_workspace[2], norg_files }
end

--- Creates links for a `file` specified by `bufnr`
--- @param bufnr number
--- @param file string
--- @return table
local function get_linkables(bufnr, file)
    local ret = {}

    if file then
        file = file:gsub(".norg", "")
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

    for i, line in ipairs(lines) do
        local heading = { line:match("^%s*(%*+%s+(.+))$") }
        if not vim.tbl_isempty(heading) then
            table.insert(ret, { line = i, linkable = heading[2], display = heading[1], file = file })
        end

        local marker_or_drawer = { line:match("^%s*(%|%|?%s+(.+))$") }
        if not vim.tbl_isempty(marker_or_drawer) then
            table.insert(ret, { line = i, linkable = marker_or_drawer[2], display = marker_or_drawer[1], file = file })
        end
    end

    return ret
end

--- Generate links for telescope
--- @return table
local function generate_links()
    local res = {}
    local dirman = neorg.modules.get_module("core.norg.dirman")

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
        if not bufnr then
            return
        end

        vim.fn.bufload(full_path_file)

        -- Because we do not want file name to appear in a link to the same file
        local file_inserted = (function ()
            if vim.api.nvim_get_current_buf() == bufnr then
                return nil
            else
                return file
            end
        end)()

        local links = get_linkables(bufnr, file_inserted)

        if vim.api.nvim_get_current_buf() ~= bufnr then
            vim.cmd('bunload! ' .. bufnr)
        end

        vim.list_extend(res, links)
    end

    return res
end

return function(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = "Insert Link",
        results_title = "Linkables",
        finder = finders.new_table({
            results = generate_links(),
            entry_maker = function(entry)
                return {
                    value = entry.line,
                    display = entry.display,
                    ordinal = entry.linkable,
                    lnum = entry.line,
                    file = entry.file
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

                local inserted_file = (function ()
                    if entry.file then
                        return ":" .. entry.file .. ":"
                    else
                        return ""
                    end
                end)()

                vim.api.nvim_put(
                    {
                        "{"
                            .. inserted_file
                            .. entry.display:gsub("^(%W+)%s+.+", "%1 ")
                            .. entry.ordinal:gsub("[%*#%|_]", "\\%1")
                            .. "}"
                            .. "["
                            .. entry.ordinal:gsub(":$", "")
                            .. "]",
                    },
                    "c",
                    false,
                    true
                )
                vim.api.nvim_feedkeys("hf]a", "t", false)
            end)
            return true
        end,
    }):find()
end

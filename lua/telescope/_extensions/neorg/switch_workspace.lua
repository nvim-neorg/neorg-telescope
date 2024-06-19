local themes = require("telescope.themes")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local state = require("telescope.actions.state")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")

local neorg_loaded, neorg = pcall(require, "neorg.core")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local ns = vim.api.nvim_create_namespace("neorg-tele-workspace-preview")

local workspaces

return function(options)
    if not workspaces then
        workspaces = {}

        local workspaces_raw = neorg.modules.get_module("core.dirman").get_workspaces()
        for name, path in pairs(workspaces_raw) do
            table.insert(workspaces, { name = name, path = path })
        end
    end

    local opts = options
        or themes.get_dropdown({
            border = true,
            layout_config = {
                prompt_position = "top",
            },
        })

    local files = {}

    pickers
        .new(opts, {
            prompt_title = "Switch Workspace",
            preview_title = "Details",
            results_title = "Workspaces",
            finder = finders.new_table({
                results = workspaces,
                entry_maker = function(ws)
                    return {
                        value = ws,
                        display = ws.name,
                        ordinal = ws.name,
                    }
                end,
            }),
            sorter = conf.generic_sorter(opts),
            previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry, status)
                    local workspace = entry.value
                    local lines = {}
                    table.insert(lines, "Path:")
                    table.insert(lines, tostring(workspace.path))
                    table.insert(lines, "Files:")

                    if not files[workspace.name] then
                        files[workspace.name] = neorg.modules.get_module("core.dirman").get_norg_files(workspace.name)
                    end
                    for _, file in ipairs(files[workspace.name]) do
                        table.insert(lines, tostring(file))
                    end
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, lines)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Special", 0, 0, -1)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Special", 2, 0, -1)
                end,
            }),
            attach_mappings = function(prompt_bufnr)
                action_set.select:replace(function()
                    local entry = state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if entry then
                        neorg.modules.get_module("core.dirman").open_workspace(entry.value.name)
                    end
                end)
                return true
            end,
        })
        :find()
end

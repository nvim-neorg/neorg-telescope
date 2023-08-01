local utils = require("neorg.telescope_utils")
local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")

local ns = vim.api.nvim_create_namespace("neorg-gtd-picker")

local neorg_loaded, neorg = pcall(require, "neorg.core")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local states = utils.states

local function get_task_list(project)
    local project_tasks = utils.get_project_tasks()
    local raw_tasks = project_tasks[project.uuid]
    local tasks = {}
    local highlights = {}
    if raw_tasks == {} or not raw_tasks then
        return {}, {}
    end
    for _, task in ipairs(raw_tasks) do
        table.insert(tasks, states[task.state][1] .. task.content)
        table.insert(highlights, states[task.state][2])
    end
    return tasks, highlights
end

return function(opts)
    opts = opts or {}

    pickers
        .new(opts, {
            prompt_title = "Pick Neorg Gtd Projects",
            results_title = "Projects",
            preview_title = "Tasks inside project",
            finder = finders.new_table({
                results = utils.get_projects(),
                entry_maker = function(entry)
                    local displayer = entry_display.create({
                        items = {
                            { width = 100 },
                        },
                    })
                    local function make_display(ent)
                        return displayer({
                            {
                                entry.content,
                                function()
                                    --- check if there are no tasks in the project
                                    local tasks = get_task_list(ent)
                                    if #tasks == 0 then
                                        --- If no tasks highlight with "Comment"
                                        return { { { 0, 100 }, "Comment" } }
                                    --- Highlight with "Special"
                                    else
                                        return { { { 0, 100 }, "Special" } }
                                    end
                                end,
                            },
                        })
                    end

                    return {
                        value = entry,
                        display = function(tbl)
                            return make_display(tbl.value)
                        end,
                        ordinal = entry.content,
                    }
                end,
            }),
            previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry, status)
                    local tasks, highlights = get_task_list(entry.value)
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, tasks)
                    vim.bo[self.state.bufnr].filetype = "norg"
                    for i, highlight in ipairs(highlights) do
                        vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, highlight, i - 1, 0, 5)
                    end
                end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions_set.select:replace(function()
                    local entry = state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    local tasks = get_task_list(entry.value)
                    if #tasks == 0 then
                        neorg.modules.get_module("core.gtd.ui").callbacks.goto_task_function(entry.value)
                        return true
                    end

                    utils.pick_project_tasks(entry.value)
                end)
                return true
            end,
        })
        :find()
end

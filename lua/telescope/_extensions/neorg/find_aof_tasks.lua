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

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local states = utils.states

local function get_aof_projects()
    local projects = utils.get_projects()
    local projects_by_aof = neorg.modules.get_module("core.gtd.queries").sort_by("area_of_focus", projects)
    return projects_by_aof
end

local function get_aof_tasks(aof)
    local tasks_raw = neorg.modules.get_module("core.gtd.queries").get("tasks")
    tasks_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(tasks_raw, "task")
    local aof_tasks = neorg.modules.get_module("core.gtd.queries").sort_by("area_of_focus", tasks_raw)
    aof_tasks = aof_tasks[aof]
    local tasks = {}
    local highlights = {}
    for _, task in ipairs(aof_tasks) do
        table.insert(tasks, states[task.state][1] .. task.content)
        table.insert(highlights, states[task.state][2])
    end
    return tasks, highlights
end

local function pick_aof_tasks(aof)
    local tasks_raw = neorg.modules.get_module("core.gtd.queries").get("tasks")
    tasks_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(tasks_raw, "task")
    local aof_tasks = neorg.modules.get_module("core.gtd.queries").sort_by("area_of_focus", tasks_raw)
    local tasks = aof_tasks[aof]
    local opts = {}

    pickers
        .new(opts, {
            prompt_title = "Pick AOF Tasks: " .. aof,
            results_title = "Tasks",
            preview_title = "Task Details",
            finder = finders.new_table({
                results = tasks,
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
                                    return { { { 0, 100 }, states[entry.state][2] } }
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
                    local lines = {}
                    local line_nr = 1
                    local special_lines = {}
                    if entry.value.project_uuid then
                        table.insert(lines, "Project:")
                        table.insert(special_lines, line_nr)
                        line_nr = line_nr + 1
                        table.insert(lines, utils.get_project_name(entry.value.project_uuid))
                        line_nr = line_nr + 1
                    end
                    if entry.value.contexts then
                        table.insert(lines, "Contexts:")
                        table.insert(special_lines, line_nr)
                        line_nr = line_nr + 1
                        for _, context in ipairs(entry.value.contexts) do
                            table.insert(lines, context)
                            line_nr = line_nr + 1
                        end
                    end
                    if entry.value["waiting.for"] then
                        table.insert(lines, "Waiting for:")
                        table.insert(special_lines, line_nr)
                        line_nr = line_nr + 1
                        for _, waiting_for in ipairs(entry.value["waiting.for"]) do
                            table.insert(lines, waiting_for)
                            line_nr = line_nr + 1
                        end
                    end
                    if entry.value["time.start"] then
                        table.insert(lines, "Time start:")
                        table.insert(special_lines, line_nr)
                        line_nr = line_nr + 1
                        table.insert(lines, entry.value["time.start"][1])
                        line_nr = line_nr + 1
                    end
                    if entry.value["time.due"] then
                        table.insert(lines, "Time due:")
                        table.insert(special_lines, line_nr)
                        line_nr = line_nr + 1
                        table.insert(lines, entry.value["time.due"][1])
                        line_nr = line_nr + 1
                    end
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, lines)
                    for _, line_number in ipairs(special_lines) do
                        vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Special", line_number - 1, 0, -1)
                    end
                end,
            }),

            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions_set.select:replace(function()
                    local entry = state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    neorg.modules.get_module("core.gtd.ui").callbacks.goto_task_function(entry.value)
                end)
                return true
            end,
        })
        :find()
end

return function(opts)
    opts = opts or {}

    pickers
        .new(opts, {
            prompt_title = "Pick Area Of Focus",
            results_title = "AOFs",
            preview_title = "Tasks inside AOF",
            finder = finders.new_table({
                results = vim.tbl_keys(get_aof_projects()),
                entry_maker = function(entry)
                    local displayer = entry_display.create({
                        items = {
                            { width = 100 },
                        },
                    })
                    local function make_display(ent)
                        local display = ent.value
                        if display == "_" then
                            display = "Tasks without aof"
                        end
                        return displayer({
                            {
                                display,
                                function()
                                    --- check if there are no tasks in the project
                                    local aof_projects = get_aof_projects()
                                    if #aof_projects[ent.value] == 0 then
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
                        display = make_display,
                        ordinal = entry,
                    }
                end,
            }),
            previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry, status)
                    local tasks, highlights = get_aof_tasks(entry.value)
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

                    pick_aof_tasks(entry.value)
                end)
                return true
            end,
        })
        :find()
end

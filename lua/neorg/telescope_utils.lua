local utils = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local entry_display = require("telescope.pickers.entry_display")
local previewers = require("telescope.previewers")

local ns = vim.api.nvim_create_namespace("neorg-gtd-picker")

--- Neorg task states: `["<task-state>"] = { "- [<sth>] ",<highlight>}`
utils.states = {
    ["undone"] = { "- [ ] ", "NeorgTodoItem1Undone" },
    ["done"] = { "- [x] ", "NeorgTodoItem1Done" },
    ["pending"] = { "- [-] ", "NeorgTodoItem1Pending" },
    ["cancelled"] = { "- [_] ", "NeorgTodoItem1Cancelled" },
    ["uncertain"] = { "- [?] ", "NeorgTodoItem1Uncertain" },
    ["urgent"] = { "- [!] ", "NeorgTodoItem1Urgent" },
    ["recurring"] = { "- [+] ", "NeorgTodoItem1Recurring" },
    ["on_hold"] = { "- [=] ", "NeorgTodoItem1OnHold" },
}

--- Gets all gtd projects
---@return table projects
utils.get_projects = function()
    local projects_raw = neorg.modules.get_module("core.gtd.queries").get("projects")
    projects_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(projects_raw, "project")
    return projects_raw
end

--- Creates a picker with the tasks of a project
---@param project table Project
utils.pick_project_tasks = function(project)
    local project_tasks = utils.get_project_tasks()
    local tasks = project_tasks[project.uuid]
    local opts = {}

    pickers.new(opts, {
        prompt_title = "Picker Project Tasks: " .. project.content,
        results_title = "Tasks",
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
                                return { { { 0, 100 }, utils.states[entry.state][2] } }
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
    }):find()
end

--- Gets gtd tasks sorted after project_uuid
---@return table project_tasks
utils.get_project_tasks = function()
    local tasks_raw = neorg.modules.get_module("core.gtd.queries").get("tasks")
    tasks_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(tasks_raw, "task")
    local projects_tasks = neorg.modules.get_module("core.gtd.queries").sort_by("project_uuid", tasks_raw)
    return projects_tasks
end

return utils

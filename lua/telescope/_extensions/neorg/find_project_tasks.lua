local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")

local ns = vim.api.nvim_create_namespace("neorg-telescope_project_tasks")

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_project_tasks()
    local tasks_raw = neorg.modules.get_module("core.gtd.queries").get("tasks")
    tasks_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(tasks_raw, "task")
    local projects_tasks = neorg.modules.get_module("core.gtd.queries").sort_by("project_uuid", tasks_raw)
    return projects_tasks
end

local function get_projects()
    local projects_raw = neorg.modules.get_module("core.gtd.queries").get("projects")
    projects_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(projects_raw, "project")
    return projects_raw
end

local function pick_tasks(project)
    local project_tasks = get_project_tasks()
    local tasks = project_tasks[project.uuid]
    local opts = {}

    pickers.new(opts, {
        prompt_title = "Picker Project Tasks: " .. project.content,
        results_title = "Tasks",
        finder = finders.new_table({
            results = tasks,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.content,
                    ordinal = entry.content,
                }
            end,
        }),
        previewer = nil,
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

local function get_task_list(project)
    local project_tasks = get_project_tasks()
    local raw_tasks = project_tasks[project.uuid]
    local tasks = {}
    local highlights = {}
    local states = {
        ["undone"] = { "-[ ] ", "NeorgTodoItem1Undone" },
        ["done"] = { "-[x] ", "NeorgTodoItem1Done" },
        ["pending"] = { "-[-] ", "NeorgTodoItem1Pending" },
        ["cancelled"] = { "-[_] ", "NeorgTodoItem1Cancelled" },
        ["uncertain"] = { "-[?] ", "NeorgTodoItem1Uncertain" },
        ["urgent"] = { "-[!] ", "NeorgTodoItem1Urgent" },
        ["recurring"] = { "-[+] ", "NeorgTodoItem1Recurring" },
        ["on_hold"] = { "-[=] ", "NeorgTodoItem1OnHold" },
    }
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

    pickers.new(opts, {
        prompt_title = "Pick Neorg Gtd Projects",
        results_title = "Projects",
        finder = finders.new_table({
            results = get_projects(),
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
                pick_tasks(entry.value)
            end)
            return true
        end,
    }):find()
end

local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")

local ns = vim.api.nvim_create_namespace("neorg-telescope_context_tasks")

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

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

local function get_context_tasks()
    local tasks_raw = neorg.modules.get_module("core.gtd.queries").get("tasks")
    tasks_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(tasks_raw, "task")
    local context_tasks = neorg.modules.get_module("core.gtd.queries").sort_by("contexts", tasks_raw)
    return context_tasks
end

local function pick_tasks(context)
    local context_tasks = get_context_tasks()
    local tasks = context_tasks[context]
    local opts = {}
    local title = "Pick Context Tasks: " .. context
    if context == "_" then
        title = "Pick Tasks without context"
    end

    pickers.new(opts, {
        prompt_title = title,
        results_title = "Tasks",
        preview_title = "Details",
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

local function get_task_list(context)
    local project_tasks = get_context_tasks()
    local raw_tasks = project_tasks[context]
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

    pickers.new(opts, {
        prompt_title = "Pick Neorg Gtd Contexts",
        results_title = "Contexts",
        preview_title = "Tasks",
        finder = finders.new_table({
            results = vim.tbl_keys(get_context_tasks()),
            entry_maker = function(entry)
                local displayer = entry_display.create({
                    items = {
                        { width = 100 },
                    },
                })
                local function make_display(ent)
                    if ent == "_" then
                        ent = "Tasks without Context"
                    end
                    return displayer({
                        {
                            ent,
                            "Special",
                        },
                    })
                end

                return {
                    value = entry,
                    display = function(tbl)
                        return make_display(tbl.value)
                    end,
                    ordinal = entry,
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

                pick_tasks(entry.value)
            end)
            return true
        end,
    }):find()
end

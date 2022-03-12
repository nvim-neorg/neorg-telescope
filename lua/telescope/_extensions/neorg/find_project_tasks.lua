local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_project_tasks()
    local tasks_raw = neorg.modules.get_module("core.gtd.queries").get("tasks") -- or "tasks"
    tasks_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(tasks_raw, "task")
    local projects_tasks = neorg.modules.get_module("core.gtd.queries").sort_by("project_uuid", tasks_raw)
    return projects_tasks
end

local function get_projects()
    local projects_raw = neorg.modules.get_module("core.gtd.queries").get("projects") -- or "projects"
    projects_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(projects_raw, "project")
    return projects_raw
end

local function pick_tasks(project)
    local project_tasks = get_project_tasks()
    local tasks = project_tasks[project.uuid]
    local opts = {}

    pickers.new(opts, {
        prompt_title = "Picker Project Tasks:" .. project.content,
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
                dump(entry.value)
            end)
            return true
        end,
    }):find()
end

return function(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = "Pick Neorg Gtd Projects",
        results_title = "Projects",
        finder = finders.new_table({
            results = get_projects(),
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
                pick_tasks(entry.value)
            end)
            return true
        end,
    }):find()
end

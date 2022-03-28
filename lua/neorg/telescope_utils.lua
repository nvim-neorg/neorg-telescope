local utils = {}

--- Neorg task states: `["<task-state>"] = { "- [<sth>] ",<highlight>}`
utils.states = {
    ["undone"] = { "-[ ] ", "NeorgTodoItem1Undone" },
    ["done"] = { "-[x] ", "NeorgTodoItem1Done" },
    ["pending"] = { "-[-] ", "NeorgTodoItem1Pending" },
    ["cancelled"] = { "-[_] ", "NeorgTodoItem1Cancelled" },
    ["uncertain"] = { "-[?] ", "NeorgTodoItem1Uncertain" },
    ["urgent"] = { "-[!] ", "NeorgTodoItem1Urgent" },
    ["recurring"] = { "-[+] ", "NeorgTodoItem1Recurring" },
    ["on_hold"] = { "-[=] ", "NeorgTodoItem1OnHold" },
}

--- Gets all gtd projects
---@return table projects
utils.get_projects = function()
    local projects_raw = neorg.modules.get_module("core.gtd.queries").get("projects")
    projects_raw = neorg.modules.get_module("core.gtd.queries").add_metadata(projects_raw, "project")
    return projects_raw
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

return require("telescope").register_extension({
    exports = {
        find_linkable = require("neorg.modules.core.integrations.telescope.module").public.find_linkable,
        insert_link = require("neorg.modules.core.integrations.telescope.module").public.insert_link,
        insert_file_link = require("neorg.modules.core.integrations.telescope.module").public.insert_file_link,
        search_headings = require("neorg.modules.core.integrations.telescope.module").public.search_headings,
        find_context_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_context_tasks,
        find_project_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_project_tasks,
        find_aof_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_aof_tasks,
        find_aof_project_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_aof_project_tasks,
        switch_workspace = require("neorg.modules.core.integrations.telescope.module").public.switch_workspace
    },
})

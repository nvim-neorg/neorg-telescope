return require("telescope").register_extension({
    exports = {
        find_linkable = require("neorg.modules.core.integrations.telescope.module").public.find_linkable,
        find_norg_files = require("neorg.modules.core.integrations.telescope.module").public.find_norg_files,
        insert_link = require("neorg.modules.core.integrations.telescope.module").public.insert_link,
        insert_file_link = require("neorg.modules.core.integrations.telescope.module").public.insert_file_link,
        search_headings = require("neorg.modules.core.integrations.telescope.module").public.search_headings,
        find_context_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_context_tasks,
        find_project_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_project_tasks,
        find_aof_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_aof_tasks,
        find_aof_project_tasks = require("neorg.modules.core.integrations.telescope.module").public.find_aof_project_tasks,
        switch_workspace = require("neorg.modules.core.integrations.telescope.module").public.switch_workspace,
        find_backlinks = require("neorg.modules.core.integrations.telescope.module").public["backlinks.file_backlinks"],
        find_header_backlinks = require("neorg.modules.core.integrations.telescope.module").public["backlinks.header_backlinks"],
    },
})

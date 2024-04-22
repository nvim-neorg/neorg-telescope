local common = require("telescope._extensions.neorg.backlinks.common")
local utils = require("neorg.telescope_utils")

return function(config)
    return function()
        local current_workspace = utils.get_current_workspace()

        if not current_workspace then
            return
        end

        local current_file = vim.api.nvim_buf_get_name(0)

        require("telescope.builtin").grep_string({
            search = common.build_backlink_regex(current_workspace, current_file),
            use_regex = true,
            search_dirs = { tostring(current_workspace) },
            prompt_title = "File Backlinks",
        })
    end
end

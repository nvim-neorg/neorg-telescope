local common = require("telescope._extensions.neorg.backlinks.common")
local utils = require("neorg.telescope_utils")

return function()
    local current_workspace = utils.get_current_workspace()

    if not current_workspace then
        return
    end

    local current_file = vim.api.nvim_buf_get_name(0)
    local linenr = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(0, 0, linenr, false)
    local heading = nil

    -- HACK: iterate backward (up) over lines, and use the first heading we find. We should be using
    -- TS instead, but I'm not super familiar with how to do things like that.
    for i = #lines, 1, -1 do
        local line = lines[i]
        local potential_heading = line:match("^%s*%*+ .*$")
        if potential_heading then
            heading = potential_heading
            break
        end
    end

    if not heading then
        vim.notify("[Neorg Telescope] Couldn't find current heading", vim.log.levels.ERROR)
        return
    end

    require("telescope.builtin").grep_string({
        search = common.build_backlink_regex(current_workspace, current_file, heading),
        use_regex = true,
        search_dirs = { tostring(current_workspace) },
        prompt_title = "Header Backlinks (" .. heading .. ")",
    })
end

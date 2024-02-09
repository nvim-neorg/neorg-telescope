local neorg_loaded, neorg = pcall(require, "neorg.core")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local file_backlink_regex = require("telescope._extensions.neorg.backlinks.utils")

local function get_current_workspace()
    local dirman = neorg.modules.get_module("core.dirman")

    if dirman then
        local current_workspace = dirman.get_current_workspace()[2]

        return current_workspace
    end

    return nil
end

return function()
    local current_workspace = get_current_workspace()

    if not current_workspace then
        return
    end

    local current_file = vim.api.nvim_buf_get_name(0)

    require("telescope.builtin").grep_string({
        search = file_backlink_regex(current_workspace, current_file),
        use_regex = true,
        search_dirs = { current_workspace },
        prompt_title = "File Backlinks",
    })
end

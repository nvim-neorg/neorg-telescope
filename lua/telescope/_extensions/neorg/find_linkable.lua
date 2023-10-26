local neorg_loaded, neorg = pcall(require, "neorg.core")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_current_workspace()
    local dirman = neorg.modules.get_module("core.dirman")

    if dirman then
        local current_workspace = dirman.get_current_workspace()[2]

        return current_workspace
    end

    return nil
end

return function(opts)
    opts = opts or {}

    local current_workspace = get_current_workspace()

    if not current_workspace then
        return
    end

    require("telescope.builtin").grep_string({
        search = "^\\s*(\\*+|\\|{1,2}|\\${1,2})\\s+",
        use_regex = true,
        search_dirs = { current_workspace },
        prompt_title = "Find in Norg files",
    })
end

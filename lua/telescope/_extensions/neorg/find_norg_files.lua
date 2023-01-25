local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local function get_current_workspace()
    local dirman = neorg.modules.get_module("core.norg.dirman")

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

    require("telescope.builtin").find_files({
        search_dirs = { current_workspace },
        prompt_title = "Find Norg Files",
    })
end

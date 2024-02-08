---produce the rg regular expression used to find workspace relative paths to the given file.
---Optionally takes a header that should exist in the current file
---@param workspace_path string "/abs/path/to/workspace"
---@param current_file string "test.norg"
---@param heading string? "** heading"
---@return string
return function(workspace_path, current_file, heading)
    current_file = vim.api.nvim_buf_get_name(0)
    current_file = current_file:gsub("%.norg$", "")
    current_file = current_file:gsub("^" .. workspace_path .. "/", "")

    if not heading then
        return ([[\{:\$/%s:.*\}]]):format(current_file) -- {:$/workspace_path:}
    end

    local heading_prefix = heading:match("^%**")
    if heading_prefix then
        heading_prefix = heading_prefix:gsub("%*", "\\*")
    end
    local heading_text = heading:gsub("^%** ", "")
    heading_text = heading_text:gsub("^%(.%)%s?", "")
    return ([[\{:\$/%s:(#|%s) %s\}]]):format(current_file, heading_prefix, heading_text) -- {:$/workspace_path:(# heading or ** heading)}
end


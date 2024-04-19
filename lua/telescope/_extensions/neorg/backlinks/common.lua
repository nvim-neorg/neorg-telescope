local M = {}

---produce the regular expression used to find workspace relative paths to the given file.
---Optionally takes a header that should exist in the current file
---@param workspace_path string|PathlibPath "/abs/path/to/workspace"
---@param current_file string|PathlibPath "test.norg"
---@param heading string? "** heading"
---@return string
M.build_backlink_regex = function(workspace_path, current_file, heading)
    local Path = require("pathlib")

    current_file = Path(vim.api.nvim_buf_get_name(0))
    current_file:remove_suffix(".norg")
    current_file = current_file:relative_to(Path(workspace_path))

    if not heading then
        -- TODO: file sep may be `\` on Windows (currently in discussion)
        -- use `current_file:regex_string("[/\\]", Path.const.regex_charset.rust)` instead
        -- https://pysan3.github.io/pathlib.nvim/doc/PathlibPath.html#PathlibPath.regex_string
        return ([[\{:\$/%s:.*\}]]):format(current_file) -- {:$/workspace_path:}
    end

    local heading_prefix = heading:match("^%**")
    if heading_prefix then
        heading_prefix = heading_prefix:gsub("%*", "\\*")
    end
    local heading_text = heading:gsub("^%** ", "")
    heading_text = heading_text:gsub("^%(.%)%s?", "")
    -- TODO: file sep may be `\` on Windows (currently in discussion)
    -- use `current_file:regex_string("[/\\]", Path.const.regex_charset.rust)` instead
    return ([[\{:\$/%s:(#|%s) %s\}]]):format(current_file, heading_prefix, heading_text) -- {:$/workspace_path:(# heading or ** heading)}
end

return M

local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")

local ns_previewer = vim.api.nvim_create_namespace("telescope.neorg.previewers")

local utils = {}

utils.copy_table = function(table)
    return vim.tbl_map(function(value)
        return value
    end, table)
end

utils.new_norg_finder = function(search, directory, opts)
    local command_list = vim.tbl_flatten({
        conf.vimgrep_arguments,
        "-g", "*.norg",
        "--", search,
        vim.fn.expand(directory),
    })

    return finders.new_oneshot_job(command_list, opts)
end

utils.new_norg_previewer = function()
    return previewers.new_buffer_previewer({
        define_preview = function(self, entry, status)
            local jump_to_line = function(self, bufnr, lnum)
                pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns_previewer, 0, -1)
                if lnum and lnum > 0 then
                    pcall(vim.api.nvim_buf_add_highlight, bufnr, ns_previewer, "TelescopePreviewLine", lnum - 1, 0, -1)
                    pcall(vim.api.nvim_win_set_cursor, self.state.winid, { lnum, 0 })
                    vim.api.nvim_buf_call(bufnr, function()
                        vim.cmd("norm! zz")
                    end)
                end
            end

            local bufnr = self.state.bufnr
            require("telescope.previewers.utils").ts_highlighter(bufnr, "norg")

            previewers.buffer_previewer_maker(entry.filename, bufnr, {
                callback = function()
                    jump_to_line(self, bufnr, entry.lnum)
                end,
            })
        end,
    })
end

return utils

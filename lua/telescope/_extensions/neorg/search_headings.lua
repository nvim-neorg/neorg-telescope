-- parts of code from: https://github.com/nvim-telescope/telescope.nvim/blob/203bf5609137600d73e8ed82703d6b0e320a5f36/lua/telescope/builtin/__files.lua#L411
local themes = require("telescope.themes")
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local make_entry = require("telescope.make_entry")

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

return function(options)
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.fn.expand(vim.api.nvim_buf_get_name(bufnr))
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    local opts = options
        or themes.get_dropdown({
            border = true,
            previewer = false,
            shorten_path = false,
            prompt_prefix = " ◈  ",
            layout_config = {
                prompt_position = "top",
            },
        })
    opts.bufnr = bufnr

    local lines_with_numbers = {}
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

    for lnum, line in ipairs(lines) do
        local match = line:match("^%s*%*+%s+")
        if match then
            local text = vim.trim(line)
            table.insert(lines_with_numbers, {
                lnum = lnum,
                bufnr = bufnr,
                filename = filename,
                text = text,
            })
        end
    end

    local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")
    if ts_ok then
        filetype = ts_parsers.ft_to_lang(filetype)
    end
    local _, ts_configs = pcall(require, "nvim-treesitter.configs")

    local parser_ok, parser = pcall(vim.treesitter.get_parser, opts.bufnr, filetype)
    local query_ok, query =
        pcall(vim.treesitter.query.get and vim.treesitter.query.get or vim.treesitter.get_query, filetype, "highlights")
    if parser_ok and query_ok and ts_ok and ts_configs.is_enabled("highlight", filetype, opts.bufnr) then
        local root = parser:parse()[1]:root()

        local highlighter = vim.treesitter.highlighter.new(parser)
        local highlighter_query = highlighter:get_query(filetype)

        local line_highlights = setmetatable({}, {
            __index = function(t, k)
                local obj = {}
                rawset(t, k, obj)
                return obj
            end,
        })

        -- update to changes on Neovim master, see https://github.com/neovim/neovim/pull/19931
        -- TODO(max): remove when dropping support for Neovim 0.7
        for id, node in query:iter_captures(root, opts.bufnr, 0, -1) do
            local hl = query.captures[id]
            if hl and type(hl) ~= "number" then
                local row1, col1, row2, col2 = node:range()

                if row1 == row2 then
                    local row = row1 + 1

                    for index = col1, col2 do
                        line_highlights[row][index] = hl
                    end
                else
                    local row = row1 + 1
                    for index = col1, #lines[row] do
                        line_highlights[row][index] = hl
                    end

                    while row < row2 + 1 do
                        row = row + 1

                        for index = 0, #(lines[row] or {}) do
                            line_highlights[row][index] = hl
                        end
                    end
                end
            end
        end

        opts.line_highlights = line_highlights
    end

    pickers
        .new(opts, {
            prompt_title = "Search Headings",
            finder = finders.new_table({
                results = lines_with_numbers,
                entry_maker = opts.entry_maker or make_entry.gen_from_buffer_lines(opts),
            }),
            -- finder = finders.new_table(headings),
            sorter = conf.generic_sorter(opts),
            previewer = conf.grep_previewer(opts),
            attach_mappings = function()
                action_set.select:enhance({
                    post = function()
                        local selection = action_state.get_selected_entry()
                        vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
                    end,
                })

                return true
            end,
        })
        :find()
end

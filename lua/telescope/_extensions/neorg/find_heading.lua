local actions = require("telescope.actions")
local action_set = require("telescope.actions.set")
local action_state = require('telescope.actions.state')
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local make_entry = require "telescope.make_entry"

local neorg_loaded, _ = pcall(require, "neorg.modules")

assert(neorg_loaded, "Neorg is not loaded - please make sure to load Neorg first")

local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

local headings = {}

for row, line in ipairs(lines) do
  local match = line:match("^%s*%*+%s+")
  if match then
    table.insert(headings, match)
  end
end

return function()
  local opts = {}
  pickers.new(opts, {
    prompt_title = "Search Headings",
    finder = finders.new_table {
      results = headings,
      entry_maker = opts.entry_maker or make_entry.gen_from_buffer_lines(opts),
    },
    sorter = conf.generic_sorter(opts),
    previewer = conf.grep_previewer(opts),
    attach_mappings = function()
      action_set.select:enhance {
        post = function()
          local selection = action_state.get_selected_entry()
          vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
        end,
      }

      return true
    end,
  }):find()
end

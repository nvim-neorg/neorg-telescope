# Neorg Integration with [Telescope](https://github.com/nvim-telescope/telescope.nvim)

This repo hosts a 3rd party module for [Neorg](https://github.com/nvim-neorg/neorg) to integrate with telescope's juicy features.

# Features
### Fuzzy Searching Any Linkable
Simply jump to any important element in the workspace. This includes headings, drawers, markers.

### Automatic Link Insertion
Simply press a key (`<C-l>` in insert mode by default) and select what you want to link to.

`insert_link` only works for elements in the current document.

### Automatic File Link Insertion
Simply press a key (`<C-f>` in insert mode by default) and select what Neorg file you want to link to.

`insert_file_link` only works for elements in the current document.

# Installation
First, make sure to pull this plugin down. This plugin does not run any code in of itself. It requires Neorg
to load it first:

### With [Packer.nvim](github.com/wbthomason/packer.nvim):
```lua
use {
    "nvim-neorg/neorg",
    config = function()
        require('neorg').setup {

            -- Select the modules we want to load
            load = {
                ["core.defaults"] = {}, -- Load all the defaults
                ...
                ["core.integrations.telescope"] = {}, -- Enable the telescope module
            },

        }
    end,
    requires = "nvim-neorg/neorg-telescope" -- Be sure to pull in the repo
}
```

If you're using the automatic keybind generation provided by Neorg you can start using `<C-s>` (search linkable elements)
in normal mode and `<C-l>` (insert link) in insert mode. If you're not using the automatic keybind generation, be sure to make
Neorg use those keys:

```lua
local neorg_callbacks = require("neorg.callbacks")

neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keybinds)
    -- Map all the below keybinds only when the "norg" mode is active
    keybinds.map_event_to_mode("norg", {
        n = { -- Bind keys in normal mode
            { "<C-s>", "core.integrations.telescope.find_linkable" },
        },

        i = { -- Bind in insert mode
            { "<C-l>", "core.integrations.telescope.insert_link" },
        },
    }, {
        silent = true,
        noremap = true,
    })
end)
```

# Support Welcome
If it's not clear by the code already, I'm a solid noob at telescope related things :)

If you have any awesome ideas or any code you want to contribute then go ahead!
Any sort of help is appreciated :heart:

#### Some Ideas Right Off The Top Of My Head
- Inserting a link to any linkable element in the whole workspace rather than just in the current document
- Fuzzy searching content in paragraphs only
- Fuzzy searching content in the current heading

# GIFs
![telescope-showcase](https://user-images.githubusercontent.com/76052559/127364253-7570a584-e80b-4365-9a9f-a3df8984472d.gif)

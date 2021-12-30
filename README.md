# Neorg Integration with [Telescope](https://github.com/nvim-telescope/telescope.nvim)

This repo hosts a 3rd party module for [Neorg](https://github.com/nvim-neorg/neorg) to integrate with telescope's juicy features.

# Features
### Fuzzy Searching Any Linkable
Simply jump to any important element in the workspace. This includes headings, drawers, markers.

![Screenshot 2021-12-30 at 18 13 49](https://user-images.githubusercontent.com/81827001/147773581-86ccf936-f7c4-4743-800e-e64b00321b4e.png)


### Automatic Link Insertion
Simply press a key (`<C-l>` in insert mode by default) and select what you want to link to.

![Screenshot 2021-12-30 at 18 12 17](https://user-images.githubusercontent.com/81827001/147773490-c966becb-69a4-4ceb-9dcc-eca2440a4521.png)

### Search Headings
Search through all the headings in your documents easily.

![Screenshot 2021-12-30 at 18 11 44](https://user-images.githubusercontent.com/81827001/147773447-26a80925-0dc3-481c-a615-d48a468d19a1.png)


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
- Fuzzy searching content in paragraphs only
- Fuzzy searching content in the current heading

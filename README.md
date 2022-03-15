# Neorg Integration with [Telescope](https://github.com/nvim-telescope/telescope.nvim)

This repo hosts a 3rd party module for [Neorg](https://github.com/nvim-neorg/neorg) to integrate with telescope's juicy features.

# Features
### Fuzzy Searching Any Linkable
Simply jump to any important element in the workspace. This includes headings, drawers, markers.
The command for this is `Telescope neorg find_linkable`

![find_linkable](https://user-images.githubusercontent.com/81827001/153651560-ed0849ec-87c1-4932-81e4-f0188ba8b676.png)

### Automatic Link Insertion
Simply press a key (`<C-l>` in insert mode by default) and select what you want to link to.

`insert_link` only works for elements in the current workspace.

![insert_link](https://user-images.githubusercontent.com/81827001/153646764-650e3c7a-caa8-43e1-aae6-47a3a3290969.png)

### Automatic File Link Insertion
You can use `Telescope neorg insert_file_link` to insert a link to a neorg file.
Notice that this only works for files in the current workspace.

![insert_file_link](https://user-images.githubusercontent.com/81827001/153646847-c43aa368-b5b5-44ac-ba00-b3d98454650d.png)

### Fuzzy Searching Headings
With `Telescope neorg search_headings` you can search through all the headings in the current file.
![search_headings](https://user-images.githubusercontent.com/81827001/153647155-80f5579f-acc9-489e-9e05-acf31a646bba.png)

## Gtd Pickers

### Find Project Tasks
Use `Telescope neorg find_project_tasks` to pick a project and then the tasks inside it.
You can then jump to those tasks.
If you select and empty project (colored gray) then you'll jump to the project.

### Find Context Tasks
With `Telescope neorg find_context_tasks` you pick a context and then tasks.

### Find AOF Tasks
You can use `Telescope neorg find_aof_tasks` to pick an aof and then search through the tasks of it.

### Find AOF Project Tasks
When you use `Telescope neorg find_aof_project_tasks` you can pick an area of focus, then a project inside it and last but not least you can search for tasks inside the project.


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

# GIFs
### Insert Link
![insert_link_gif](https://user-images.githubusercontent.com/81827001/153654205-250d4dcc-014a-46ac-a68d-df7d0432ce58.gif)

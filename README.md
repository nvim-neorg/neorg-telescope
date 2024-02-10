# Neorg Telescope

This repo hosts a 3rd party module for [Neorg](https://github.com/nvim-neorg/neorg) to integrate with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
# 🌟 Showcase
### Fuzzy Searching Any Linkable
Simply jump to any important element in the workspace. This includes headings, drawers, markers.
The command for this is `Telescope neorg find_linkable`

<details>
<summary>Demo</summary>
<img alt="find_linkable" src="https://user-images.githubusercontent.com/81827001/153651560-ed0849ec-87c1-4932-81e4-f0188ba8b676.png">
</details>

### Automatic Link Insertion
Simply press a key (`<C-l>` in insert mode by default) and select what you want to link to.

`insert_link` only works for elements in the current workspace.

<details>
<summary>Demo</summary>
<img alt="insert_link" src="https://user-images.githubusercontent.com/81827001/153646764-650e3c7a-caa8-43e1-aae6-47a3a3290969.png">
</details>

### Automatic File Link Insertion
You can use `Telescope neorg insert_file_link` to insert a link to a neorg file.
Notice that this only works for files in the current workspace.
Note: If no file is selected a link to a file with the name of the prompt value
will be inserted. This file will be created if you use the link with 
<img alt="neorg's hop" src="https://github.com/nvim-neorg/neorg/wiki/Esupports-Hop"/>

<details>
<summary>Demo</summary>
<img alt="insert_file_link" src="https://user-images.githubusercontent.com/81827001/153646847-c43aa368-b5b5-44ac-ba00-b3d98454650d.png">
</details>

### Fuzzy Searching Headings
With `Telescope neorg search_headings` you can search through all the headings in the current file.

<details>
<summary>Demo</summary>
<img alt="search_headings" src="https://user-images.githubusercontent.com/81827001/153647155-80f5579f-acc9-489e-9e05-acf31a646bba.png">
</details>

### Search File and Heading Backlinks
- `Telescope neorg find_backlinks` - find every line in your workspace that links^* to the current file
- `Telescope neorg find_header_backlinks` - same but with links to the current file _and_ heading

These are limited to workspace relative links (ie.
`{:$/worspace/relative/path:}`) for the sake of simplicity. Both exact
(`{:$/path:** lvl 2 heading}`) and fuzzy (`{:$/path:# heading}`) links are
found.

<details>
  <summary>Demo</summary>

![search backlink](https://github.com/nvim-neorg/neorg-telescope/assets/56943754/37a5b68f-29b3-43ae-a679-9656cfa646db)
</details>

## Gtd Pickers
### Those pickers are all broken since gtd was removed in core
<details>
<summary>The removed pickers</summary>

### Find Project Tasks
Use `Telescope neorg find_project_tasks` to pick a project and then the tasks inside it.
You can then jump to those tasks.
If you select and empty project (colored gray) then you'll jump to the project.

<video alt="find_project_tasks" src="https://user-images.githubusercontent.com/81827001/158395250-b4de0f8b-c693-4f55-ae6e-c66f6055f741.mov"></video>

### Find Context Tasks
With `Telescope neorg find_context_tasks` you pick a context and then tasks.
<video alt="find_context_tasks" src="https://user-images.githubusercontent.com/81827001/158401579-ef8e7d9a-2d84-4e05-8f7d-d1f3815a67ee.mov"></video>

### Find AOF Tasks
You can use `Telescope neorg find_aof_tasks` to pick an aof and then search through the tasks of it.
<video alt="find_aof_tasks" src="https://user-images.githubusercontent.com/81827001/158401242-5d61c18a-ab77-4942-ad31-0e6dede410df.mov"></video>

### Find AOF Project Tasks
When you use `Telescope neorg find_aof_project_tasks` you can pick an area of focus, then a project inside it and last but not least you can search for tasks inside the project.
<video alt="find_aof_project_tasks" src="https://user-images.githubusercontent.com/81827001/158401841-9ca3a311-bac1-4733-9a6e-6125003d8a38.mov"></video>
</details>

# 🔧 Installation
First, make sure to pull this plugin down. This plugin does not run any code in of itself. It requires Neorg
to load it first:

You can install it through your favorite plugin manager:

- 
  <details>
  <summary><a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a></summary>

  ```lua
  use {
      "nvim-neorg/neorg",
      config = function()
          require('neorg').setup {
              load = {
                  ["core.defaults"] = {},
                  ...
                  ["core.integrations.telescope"] = {}
              },
          }
      end,
      requires = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope" },
  }
  ```

- <details>
  <summary><a href="https://github.com/junegunn/vim-plug">vim-plug</a></summary>

  ```vim
  Plug 'nvim-neorg/neorg' | Plug 'nvim-lua/plenary.nvim' | Plug 'nvim-neorg/neorg-telescope'
  ```

  You can then put this initial configuration in your `init.vim` file:

  ```vim
  lua << EOF
  require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ...
        ["core.integrations.telescope"] = {}
    },
  }
  EOF
  ```

  </details>
- <details>
  <summary><a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

  ```lua
  require("lazy").setup({
      {
          "nvim-neorg/neorg",
          opts = {
              load = {
                  ["core.defaults"] = {},
                  ...
                  ["core.integrations.telescope"] = {},
              },
          },
          dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-neorg/neorg-telescope" } },
      }
  })
  ```

  </details>

# Usage
You can define keybindings like this:

```lua
local neorg_callbacks = require("neorg.core.callbacks")

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

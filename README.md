# 🎉 Popurri \[beta\]

Add some tree-sitter-based fun to Neovim.

## Installation

Lazy:

```lua
{
  "mgastonportillo/popurri.nvim",
  dependencies = { "rcarriga/nvim-notify" }, -- optional: custom notifications
  event = "VeryLazy",
  init = function()
    -- any mappings should go here
  end
  opts = {}, -- or config = true
}
```

## Configuration

Defaults:

```lua
opts = {
  default_query = nil -- "args" | "vars"
}
```

## Commands

`:Popurri` Toggle Popurri on/off (takes arguments)

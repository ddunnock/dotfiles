-- ~/.config/nvim/lua/plugins/themes.lua
---@diagnostic disable: undefined-global
return {
  ---------------------------------------------------------------------------
  -- 1.  Catppuccin ----------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,

    opts = {
      flavor       = "mocha",
      transparent_background = true,
      integrations = {
        treesitter = true,
        telescope  = true,
        neotree    = true,
        indent_blankline = {
          enabled               = true,
          colored_indent_levels = true,
        },
      },
    },

    config = function(_, opts)
      require("catppuccin").setup(opts)
      -- vim.cmd.colorscheme "catppuccin"  -- ← enable if you want Catppuccin
    end,
  },

  ---------------------------------------------------------------------------
  -- 2.  Tokyonight ----------------------------------------------------------
  ---------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    name     = "tokyonight",
    priority = 1000,

    opts = {
      style           = "moon",   -- night | storm | day | moon
      transparent     = true,
      terminal_colors = true,
      styles = {
        comments  = { italic = true },
        keywords  = { italic = true },
        functions = { italic = false },
        variables = { italic = false },
      },
      sidebars     = { "qf", "help", "neo-tree", "terminal" },
      lualine_bold = true,
    },

    config = function(_, opts)
      require("tokyonight").setup(opts)
      -- vim.cmd.colorscheme "tokyonight" -- ← enable if you want Tokyonight
    end,
  },

  ---------------------------------------------------------------------------
  -- 3.  Dracula -------------------------------------------------------------
  --    https://github.com/Mofiqul/dracula.nvim
  ---------------------------------------------------------------------------
  {
    "Mofiqul/dracula.nvim",
    name     = "dracula",
    priority = 1000,

    opts = {
      transparent_bg = true,
      italic_comment = true,
      overrides = function(colors)   -- optional fine-tuning
        return {
          -- Neo-tree folder icon
          NeoTreeFolderIcon = { fg = colors.purple },
        }
      end,
    },

    config = function(_, opts)
      require("dracula").setup(opts)
      -- vim.cmd.colorscheme "dracula"   -- ← enable if you want Dracula
    end,
  },

  ---------------------------------------------------------------------------
  -- 4.  Rose-Pine -----------------------------------------------------------
  --    https://github.com/rose-pine/neovim
  ---------------------------------------------------------------------------
  {
    "rose-pine/neovim",
    name     = "rose-pine",
    priority = 1000,

    opts = {
      variant         = "moon",  -- main | moon | dawn
      dark_variant    = "moon",
      disable_float_background = true,
      disable_background = true,
      disable_italics = false,

      highlight_groups = {
        -- Example: make Neo-tree normal text match theme’s subtle surface
        NeoTreeNormal = { bg = "none" },
      },
    },

    config = function(_, opts)
      require("rose-pine").setup(opts)
      -- vim.cmd.colorscheme "rose-pine" -- ← enable if you want Rose-Pine
    end,
  },
}

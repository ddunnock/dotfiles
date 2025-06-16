-- ~/.config/nvim/lua/plugins/indent-blankline.lua
--
-- Rainbow indentation guides via “indent-blankline.nvim v3 (IBL)”

---@diagnostic disable: undefined-global
return {
  "lukas-reineke/indent-blankline.nvim",
  main  = "ibl",            -- <- v3 has a top-level ‘ibl’ module
  event = { "BufReadPre", "BufNewFile" },

  opts  = function()
    -------------------------------------------------------------------------
    -- 1.  Pick seven highlight groups that your themes already define
    --     (these all exist in Catppuccin, Tokyonight, Dracula & Rose-Pine)
    -------------------------------------------------------------------------
    local rainbow = {
      "String",     -- 1
      "Constant",   -- 2
      "Identifier", -- 3
      "Statement",  -- 4
      "PreProc",    -- 5
      "Type",       -- 6
      "Special",    -- 7
    }

    -------------------------------------------------------------------------
    -- 2.  Tell *indent-blankline* to colour each scope-column in turn
    -------------------------------------------------------------------------
    return {
      indent = { char = "│" },          -- ▏ │  ┆  …
      scope  = {
        enabled   = true,
        highlight = rainbow,
      },
      whitespace = {
        remove_blankline_trail = true,  -- tidy trailing WS
      },
    }
  end,
}

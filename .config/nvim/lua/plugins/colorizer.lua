-- ~/.config/nvim/lua/plugins/colorizer.lua
---@diagnostic disable: undefined-global
return {
  "catgoose/nvim-colorizer.lua",

  -- Load just before the buffer is shown, then finish attaching on BufWinEnter
  event = { "BufReadPre", "BufNewFile" },

  -- Configuration table ─ wrapped in a function so it can be evaluated lazily
  opts = function()
    return {
      ------------------------------------------------------------------------
      -- 1.  Filetype / buftype routing
      ------------------------------------------------------------------------
      filetypes = {
        "*",                          -- enable everywhere …
        "!lazy", "!TelescopePrompt",  -- … except transient UIs
        css   = { rgb_fn = true, hsl_fn = true, css_fn = true },
        html  = { names  = false, rgb_fn = true, mode = "foreground" },
        lua   = { names  = false, RGB = false, RRGGBB = true },
        scss  = { sass   = { enable = true, parsers = { "css" } } },
        sh    = { names  = false },   -- keep shell scripts tidy
        yaml  = { names  = false, mode = "virtualtext" },
      },

      buftypes = {
        "*",
        "!prompt", "!popup", "!nofile", "!terminal",
      },

      ------------------------------------------------------------------------
      -- 2.  Global defaults (applied unless a filetype override is present)
      ------------------------------------------------------------------------
      user_default_options = {
        -- ✔ Core colour sources ------------------------------------------------
        names           = true,
        names_opts      = { lowercase = true, camelcase = true },
        names_custom    = false,          -- hook in your palette later
        RGB             = true,           -- #abc
        RGBA            = true,           -- #abcd
        RRGGBB          = true,           -- #aabbcc
        RRGGBBAA        = false,
        AARRGGBB        = false,
        rgb_fn          = false,          -- rgb()
        hsl_fn          = false,          -- hsl()
        css             = false,          -- alias enabling all CSS colour forms
        css_fn          = false,          -- alias enabling css functions only

        -- ✔ Tailwind integration ----------------------------------------------
        tailwind        = "lsp",          -- normal|lsp|both
        tailwind_opts   = { update_names = true },

        -- ✔ Display mode -------------------------------------------------------
        mode            = "background",   -- background|foreground|virtualtext
        virtualtext     = "■", -- glyph for vtext mode
        virtualtext_inline = "before",
        virtualtext_mode   = "foreground",

        -- ✔ Performance knobs --------------------------------------------------
        always_update   = false,          -- only the focussed buffer updates
        hooks = {
          -- Skip comment-only lines for a tiny perf gain
          disable_line_highlight = function(line)
            return line:match("^%s*[%#%-]+") ~= nil
          end,
        },
      },

      -- Enable a reduced set of user commands for a cleaner :command list
      user_commands = { "ColorizerToggle", "ColorizerReloadAllBuffers" },

      -- Lazy-load the internal highlighter so first render stays snappy
      lazy_load = true,
    }
  end,

  --------------------------------------------------------------------------
  -- 3.  Setup + smart attach
  --------------------------------------------------------------------------
  config = function(_, opts)
    -- One-shot global setup (creates FileType * autocommand):contentReference[oaicite:0]{index=0}
    require("colorizer").setup(opts)

    -- Optional: attach only when the buffer is actually shown in a window
    vim.api.nvim_create_autocmd("BufWinEnter", {
      callback = function(ev)
        require("colorizer").attach_to_buffer(ev.buf)
      end,
    })
  end,
}

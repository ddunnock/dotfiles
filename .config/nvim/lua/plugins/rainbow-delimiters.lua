-- ~/.config/nvim/lua/plugins/rainbow-delimiters.lua
return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufReadPost",           -- lazy-load on first file open
  config = function()
    -- Optional customisation.  Delete this block if you like the defaults.
    vim.g.rainbow_delimiters = {
      strategy = {
        [""]  = require("rainbow-delimiters").strategy["global"],
        lua   = require("rainbow-delimiters").strategy["local"],
      },
      highlight = {                -- colors follow your colorscheme groups
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  end,
}

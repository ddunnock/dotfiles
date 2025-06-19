--- ~/.config/nvim/lua/config/transparent.lua
---@diagnostic disable: undefined-global
-------------------------------------------------------------------------------------
local M = {}

--- extra_groups: table with additional highlight groups you want cleared
function M.apply(extra_groups)
  local clear = {
  -- main UI
  "Normal", "NormalNC", "NormalFloat", "FloatBorder",
  "SignColumn", "LineNr", "FoldColumn", "EndOfBuffer",
  -- sidebars / pop-ups
  "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
  "TelescopeNormal", "TelescopeBorder",
  -- statuslines (comment out if you prefer colored bars)
  -- "StatusLine", "StatusLineNC",
  }

  vim.list_extend(clear, extra_groups or {})

  for _, grp in ipairs(clear) do
    vim.api.nvim_set_hl(0, grp, { bg = "NONE", ctermbg = "NONE" })
  end
end

return M

-- ~/.config/nvim/lua/config/themes.lua
---@diagnostic disable: undefined-global

local themes = {
  { scheme = "catppuccin", label = "Catppuccin" },
  { scheme = "tokyonight", label = "Tokyo-night (moon)" },
  { scheme = "dracula",    label = "Dracula" },
  { scheme = "rose-pine",  label = "Rose-pine" },
}
local i = 1

-- --------------------------------------------------------------------
-- 1.  Palette helpers (optional)
-- --------------------------------------------------------------------
local function get_palette(name)
  if name == "catppuccin" then
    return require("catppuccin.palettes").get_palette("mocha")
  elseif name == "tokyonight" then
    local ok, c = pcall(require, "tokyonight.colors")
    return ok and c.default or {}
  elseif name == "dracula" then
    return require("dracula").colors()
  elseif name == "rose-pine" then
    return require("rose-pine.palette")
  end
  return nil -- fallback: will use hard-coded hex
end

-- --------------------------------------------------------------------
-- 2.  Apply colourscheme *and* Neo-tree overrides
-- --------------------------------------------------------------------
local function apply(t, show_msg)
  local ok, err = pcall(function()
    require("lazy.core.loader").load({ t.scheme }, {})
    vim.cmd.colorscheme(t.scheme)
  end)

  if ok then
    ------------------------------------------------------------------
    -- 2.a  Pick highlight colours
    ------------------------------------------------------------------
    local p = get_palette(t.scheme) or {}
    local red     = p.red      or "#F38BA8"
    local green   = p.green    or "#A6E3A1"
    local yellow  = p.yellow   or "#F9E2AF"
    local orange  = p.peach    or "#FAB387"
    local blue    = p.blue     or "#89B4FA"
    local teal    = p.teal     or "#94E2D5"
    local magenta = p.mauve    or "#CBA6F7"

    ------------------------------------------------------------------
    -- 2.b  Neo-tree git + diagnostic groups
    ------------------------------------------------------------------
    local set = vim.api.nvim_set_hl
    set(0, "NeoTreeGitAdded",        { fg = green  })
    set(0, "NeoTreeGitModified",     { fg = yellow })
    set(0, "NeoTreeGitDeleted",      { fg = red    })
    set(0, "NeoTreeGitUntracked",    { fg = teal   })
    set(0, "NeoTreeGitIgnored",      { fg = blue   })
    set(0, "NeoTreeGitConflict",     { fg = magenta, bold = true })

    set(0, "NeoTreeDiagnosticError",   { fg = red,    italic = true })
    set(0, "NeoTreeDiagnosticWarn",    { fg = orange, italic = true })
    set(0, "NeoTreeDiagnosticInfo",    { fg = blue,   italic = true })
    set(0, "NeoTreeDiagnosticHint",    { fg = teal,   italic = true })

    ------------------------------------------------------------------
    -- 2.c  Notify success
    ------------------------------------------------------------------
    if show_msg then
      vim.schedule(function()
        vim.notify("Theme → " .. t.label,
          vim.log.levels.INFO, { title = "Colourscheme" })
      end)
    end
  else
    vim.notify(("Could not load %s: %s"):format(t.scheme, err),
      vim.log.levels.ERROR, { title = "Colourscheme" })
  end
end

-- --------------------------------------------------------------------
-- 3.  Cycle function (unchanged)
-- --------------------------------------------------------------------
function _G.CycleTheme()
  i = (i % #themes) + 1
  apply(themes[i])
end

-- --------------------------------------------------------------------
-- 4.  Load first theme after Lazy is done
-- --------------------------------------------------------------------
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  once    = true,
  callback = function() apply(themes[2]) end,
})

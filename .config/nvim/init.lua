-- ~/.config/nvim/init.lua
---@diagnostic disable: undefined-global
---------------------------------------------------------------------
-- 0.  CORE OPTIONS & LEADERS
---------------------------------------------------------------------
---@diagnostic disable-next-line: inject-field
vim.g.mapleader = " "

require("config.options")

require("config.themes")

require("config.keymaps")
require("config.autocmds")

---------------------------------------------------------------------
-- 1.  BOOTSTRAP LAZY + PLUGINS
---------------------------------------------------------------------
require("config.lazy")      -- <- only sets things up, no plugin code yet
require("config.diagnostics")



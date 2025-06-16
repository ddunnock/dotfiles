-- ~/.config/nvim/lua/config/keymaps.lua
---@diagnostic disable: undefined-global
---@diagnostic disable: deprecated
local map = vim.keymap.set

-- yank to system clipboard
map({ 'n', 'v' }, 'Y', '"+y', { desc = 'Yank to clipboard' })

-------------------------------------------------------------------------------
-- UI -- colourschemes --------------------------------------------------------
-------------------------------------------------------------------------------
-- <leader>ut  → cycle through the list you defined in themes.lua
map("n", "<leader>ut", "<cmd>lua CycleTheme()<CR>",
  { desc = "UI: cycle theme",
    silent = true,
    nowait = true,
  })

-- <leader>uc  → Telescope’s colourscheme picker (optional)
map("n", "<leader>uc", "<cmd>Telescope colorscheme<CR>",
    { desc = "UI: choose theme", silent = true })

-- diagnostics ──────────────────────────────────────────────────────────────
map('n', ']d', function() vim.diagnostic.goto_next({ float = false }) end,
    { desc = 'Next diagnostic' })

map('n', '[d', function() vim.diagnostic.goto_prev({ float = false }) end,
    { desc = 'Prev diagnostic' })

map('n', '<leader>ld', vim.diagnostic.open_float,
    { desc = 'Line diagnostics' })

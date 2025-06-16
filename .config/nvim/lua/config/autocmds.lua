-- ~/.config/nvim/lua/config
---@diagnostic disable: undefined-global
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight on yank',
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ timeout = 120 })
  end,
})


-- ~/.config/nvim/lua/plugins/telescope.lua
return {
  {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd  = 'Telescope',
  keys = {
    { '<C-p>',     '<Cmd>Telescope find_files<CR>',  desc = 'Files',  mode = 'n' },
    { '<leader>fg','<Cmd>Telescope live_grep<CR>',   desc = 'Grep',   mode = 'n' },
  },
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    config = function()
      require('telescope').setup({
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {
            }
          }
        }
      })
      require('telescope').load_extension('ui-select')
    end
  },
}


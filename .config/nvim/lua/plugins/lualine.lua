-- ~/.config/nvim/lua/plugins/lualine.lua
return {
  'nvim-lualine/lualine.nvim',
  
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  
  opt = {
    options = {
      theme                 = 'catppuccin',
      section_separators    = '',
      component_separators  = '',
    },
  },

  config = function(_, opts)
    require('lualine').setup(opts)
  end,
}

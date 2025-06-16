-- ~/.config/nvim/lua/plugins/treesitter.lua
return { 
  "nvim-treesitter/nvim-treesitter",
  branch = 'master', 
  build = ":TSUpdate", 
  opts  = {
    auto_install = true,
    highlight = { enable = true },
    indent    = { enable = true },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}

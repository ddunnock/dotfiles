-- ~/.config/nvim/lua/plugins/treesitter.lua
return { 
  "nvim-treesitter/nvim-treesitter",
  branch = 'master', 
  build = ":TSUpdate", 
  opts  = {
    auto_install = true,
    highlight = { enable = true },
    indent    = { enable = true },
    -- Disable query-based error checking for LaTeX
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = {"BufWrite", "CursorHold"},
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    
    -- Disable treesitter diagnostics for LaTeX files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "latex", "plaintex" },
      callback = function()
        -- Disable treesitter-based diagnostics for LaTeX
        vim.diagnostic.config({
          virtual_text = {
            source = "if_many",
            filter = function(diagnostic)
              -- Filter out treesitter LaTeX errors
              return not (diagnostic.source and diagnostic.source:match("treesitter"))
            end,
          },
        }, vim.api.nvim_get_current_buf())
      end,
    })
  end,
}

-- ~/.config/nvim/lua/plugins/venv-selector.lua
return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --optional
    { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  },
  lazy = false,
  branch = "regexp", -- This is the regexp branch, use this for the new version
  keys = {
    { ",v", "<cmd>VenvSelect<cr>" },
  },
  ---@type venv-selector.Config
  opts = {
    -- Your settings go here
    options = {
      enabled_cached_venvs = true,
      cached_venv_automatic_activation = true,
      activate_venv_in_terminal = true,
      set_environment_variables = true,
      notify_user_on_activation = true,
    },
  },
}

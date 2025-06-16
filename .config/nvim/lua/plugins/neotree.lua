-- ~/.config/nvim/lua/plugins/neotree.lua
---@diagnostic disable: undefined-global
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  version = ">=3.2.0",

  cmd = "Neotree",
  keys = {
    {
      "<C-n>",
      "<Cmd>Neotree filesystem reveal left<CR>",
      desc = "Neo-tree: reveal",
      mode = "n",
      silent = true,
    },
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },

  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    git_status = { enabled = true }, -- keep the config so it can be toggled
    document_symbols = { follow_cursor = true },

    filesystem = { use_git_status_colors = true },

    default_component_configs = {
      diagnostics = {
        highlight = "text",
        symbols = {
          hint  = "󰌵",
          info  = "",
          warn  = "",
          error = "",
        },
        highlights = {
          hint = "DiagnosticSignHint",
          info = "DiagnosticSignInfo",
          warn = "DiagnosticSignWarn",
          error = "DiagnosticSignError",
        },
      },
    },
  },
	config = function(_, opts)
		-------------------------------------------------------------------------
		-- 1. Standard Neo-tree setup (without git_status in the source list)
		-------------------------------------------------------------------------
		require("neo-tree").setup(opts)

		-------------------------------------------------------------------------
		-- 2. Helper: is the given path inside a Git repository?
		-------------------------------------------------------------------------
		local function in_git_repo(path)
			-- fast check: “.git” dir exists somewhere above <path>
			return vim.fn.finddir(".git", path .. ";") ~= ""
		end

		-------------------------------------------------------------------------
		-- 3. Auto-toggle the git_status source whenever the Neo-tree buffer
		--    is entered or its root changes
		-------------------------------------------------------------------------
		local manager = require("neo-tree.sources.manager")

		vim.api.nvim_create_autocmd("User", {
			pattern = "NeotreeBufferEnter",
			callback = function(args)
				local path = vim.fn.fnamemodify(args.file, ":p:h")
				local want_git = in_git_repo(path)

				local has_git = manager.is_source_active("git_status")
				if want_git and not has_git then
					manager.toggle("git_status", true, false) -- open silently
				elseif (not want_git) and has_git then
					manager.toggle("git_status", false, false) -- close silently
				end
			end,
		})
	end,
}

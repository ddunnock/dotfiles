-- ~/.config/nvim/lua/plugins/formatter.lua
---@diagnostic disable: undefined-global
return {
  "mhartington/formatter.nvim",
  -- ── make sure the plugin is actually added to &runtimepath ──────────────
  lazy = false,               -- load at startup (no events / commands needed)
  -- (If you prefer lazy-loading, *keep* the events *and* the cmd-stub:
  --   event = { "BufReadPre", "BufNewFile" },
  --   cmd   = { "Format", "FormatWrite", "FormatLock", "FormatWriteLock" },
  -- )
  --------------------------------------------------------------------------
  config = function()
    local prettier = require("formatter.filetypes.css").prettierd   -- one liner

    require("formatter").setup({
      logging   = false,
      log_level = vim.log.levels.WARN,
      filetype  = {
        -- everything Prettier understands
        javascript        = { require("formatter.filetypes.javascript").prettierd },
        javascriptreact   = { require("formatter.filetypes.javascriptreact").prettierd },
        typescript        = { require("formatter.filetypes.typescript").prettierd },
        typescriptreact   = { require("formatter.filetypes.typescriptreact").prettierd },
        vue               = { require("formatter.filetypes.vue").prettierd },
        css               = { prettier },
        scss              = { prettier },   --  ← the ones you care about
        sass              = { prettier },
        html              = { require("formatter.filetypes.html").prettierd },
        json              = { require("formatter.filetypes.json").prettierd },
        yaml              = { require("formatter.filetypes.yaml").prettierd },
        markdown          = { require("formatter.filetypes.markdown").prettierd },

        ["*"]             = { function() return nil end },
      },
    })

    -- optional: format automatically on save
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = {
        "*.js","*.jsx","*.ts","*.tsx",
        "*.css","*.scss","*.sass","*.html",
        "*.json","*.yml","*.yaml","*.md",
      },
      command = "silent! FormatWrite",
    })

    -- optional: leader-f manual trigger
    vim.keymap.set("n","<leader>f","<cmd>Format<CR>",
      { desc = "Format current buffer" })
  end,
}

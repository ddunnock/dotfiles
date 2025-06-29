-- ~/.config/nvim/lua/plugins/none-ls.lua
---@diagnostic disable: undefined-global
return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local null_ls = require("null-ls")
    local helpers = require("null-ls.helpers")

    -- Manual definition of latexindent if not built-in
    local latexindent = {
      method = null_ls.methods.FORMATTING,
      filetypes = { "tex", "latex" },
      generator = helpers.formatter_factory({
        command = "latexindent",
        args = { "-" },
        to_stdin = true,
      }),
    }

    null_ls.setup({
      sources = {
        -- Formatters
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black.with({ extra_args = { "--fast" } }),
        null_ls.builtins.formatting.shfmt.with({ filetypes = { "make" } }),
        null_ls.builtins.formatting.prettier.with({
          filetypes = { "json", "yaml" },
        }),
        latexindent,

        -- Completion
        -- null_ls.builtins.completion.spell,
      },
    })

    -- Keymap for formatting
    vim.keymap.set("n", "<leader>gf", function()
      vim.lsp.buf.format({ async = true })
    end, { desc = "Format buffer" })
  end,
}


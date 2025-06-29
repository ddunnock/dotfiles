-- Local-clone spec for TeXpresso (lazy.nvim)
-- Plugin lives in: ~/.config/nvim/start/texpresso.vim/
return {
  {
    dir  = vim.fn.stdpath("config") .. "/start/texpresso.vim",
    dev  = true,              -- tell lazy.nvim it’s an on-disk plugin
    name = "texpresso",
    ft   = "tex",

    config = function()
      ------------------------------------------------------------------
      -- 1 ▸ load runtime module safely
      ------------------------------------------------------------------
      local ok, tx = pcall(require, "texpresso")
      if not ok then
        vim.notify(
          "TeXpresso: lua/texpresso.lua not found — check dir= path",
          vim.log.levels.ERROR
        )
        return
      end

      ------------------------------------------------------------------
      -- 2 ▸ handy key-map  (Space l v)
      ------------------------------------------------------------------
      vim.keymap.set(
        "n", "<leader>lt",
        ":TeXpresso %<CR>",
        { desc = "TeXpresso • live preview" }
      )

      -- Optional: auto-launch viewer on every TeX buffer
      -- vim.api.nvim_create_autocmd("FileType", {
      --   pattern = "tex",
      --   command = "TeXpresso %",
      -- })
    end,
  },
}

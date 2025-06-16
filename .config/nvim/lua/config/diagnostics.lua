-- ~/.config/nvim/lua/config/diagnostics.lua
-- Global diagnostic UI tweaks
-- (virtual-text “●” bullets, gutter signs, squiggles, …)
---@diagnostic disable: undefined-global


-- Nice Nerd-Font icons for LSP diagnostics ──────────────────────────────
local signs = {
  Error = "",
  Warn  = "",
  Info  = "",
  Hint  = "󰌵",
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local diagnostic = vim.diagnostic   -- convenience alias

diagnostic.config({
  ---------------------------------------------------------------------------
  -- 1.  Where & how diagnostics are shown ----------------------------------
  ---------------------------------------------------------------------------
  virtual_text      = { prefix = "●", spacing = 1 },
  signs             = {
    text = {                  -- <── NEW: one table, no more sign_define()
      [diagnostic.severity.ERROR] = "",
      [diagnostic.severity.WARN]  = "",
      [diagnostic.severity.INFO]  = "",
      [diagnostic.severity.HINT]  = "󰌵",
    },
  },
  underline         = true,   -- squiggly underlines
  update_in_insert  = true,   -- live while typing

  ---------------------------------------------------------------------------
  -- 2.  Sort & filter ------------------------------------------------------
  ---------------------------------------------------------------------------
  severity_sort = true,       -- errors at the top, hints at the bottom
  severity      = {           -- minimum level to show at all
    -- INFO and above → show;  HINTs → hide
    min = diagnostic.severity.INFO,
  },

  ---------------------------------------------------------------------------
  -- 3.  Floating-window look & feel ---------------------------------------
  ---------------------------------------------------------------------------
  float = {
    border  = "rounded",
    source  = true ,       -- always show the originating LSP
  },
})

-------------------------------------------------------------------------------
-- 4.  Little tooltip when you pause the cursor ------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    diagnostic.open_float(nil, { focus = false, scope = "cursor" })
  end,
})

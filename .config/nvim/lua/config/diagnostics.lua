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
  virtual_text      = { 
    prefix = "●", 
    spacing = 1,
    -- Global filter for fontspec errors
    filter = function(diagnostic)
      local message = diagnostic.message or ""
      local source = diagnostic.source or ""
      
      -- Debug: uncomment to see all diagnostics
      -- print("Global Diagnostic - Source:", source, "Message:", message:sub(1, 80))
      
      -- Filter out fontspec engine errors globally
      if message:match("fontspec") or
         message:match("requires either XeTeX or LuaTeX") or
         message:match("change your typesetting engine") or
         message:match("Emergency stop") or
         message:match("Fatal.*Package.*fontspec") then
        return false
      end
      return true
    end,
  },
  signs             = {
    text = {                  -- <── NEW: one table, no more sign_define()
      [diagnostic.severity.ERROR] = "",
      [diagnostic.severity.WARN]  = "",
      [diagnostic.severity.INFO]  = "",
      [diagnostic.severity.HINT]  = "󰌵",
    },
    -- Global filter for signs too
    filter = function(diagnostic)
      local message = diagnostic.message or ""
      if message:match("fontspec") or
         message:match("requires either XeTeX or LuaTeX") or
         message:match("change your typesetting engine") or
         message:match("Emergency stop") or
         message:match("Fatal.*Package.*fontspec") then
        return false
      end
      return true
    end,
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
-- 4.  Remove fontspec diagnostics completely -------------------------------
-------------------------------------------------------------------------------
local function clean_fontspec_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= 'tex' then return end
  
  -- Get all diagnostic namespaces
  local all_namespaces = vim.diagnostic.get_namespaces()
  
  for ns_id, _ in pairs(all_namespaces) do
    local diagnostics = diagnostic.get(bufnr, { namespace = ns_id })
    local filtered = {}
    local found_fontspec = false
    
    for _, diag in ipairs(diagnostics) do
      local message = diag.message or ""
      -- Skip fontspec-related diagnostics entirely
      if message:match("fontspec") or
         message:match("requires either XeTeX or LuaTeX") or
         message:match("change your typesetting engine") or
         message:match("Emergency stop") or
         message:match("Fatal.*Package.*fontspec") then
        found_fontspec = true
      else
        table.insert(filtered, diag)
      end
    end
    
    -- Only update if we found and filtered fontspec diagnostics
    if found_fontspec then
      diagnostic.set(ns_id, bufnr, filtered)
    end
  end
end

-- Clean fontspec diagnostics on various events
vim.api.nvim_create_autocmd({"DiagnosticChanged", "BufEnter", "CursorHold"}, {
  pattern = "*.tex",
  callback = clean_fontspec_diagnostics,
})

-------------------------------------------------------------------------------
-- 5.  Little tooltip when you pause the cursor ------------------------------
-------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    diagnostic.open_float(nil, { focus = false, scope = "cursor" })
  end,
})

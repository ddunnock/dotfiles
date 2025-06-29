-- ~/.config/nvim/lua/plugins/vimtex.lua
---@diagnostic disable: undefined-global
return {
  "lervag/vimtex",

  -- ── load only when editing TeX-related buffers ──────────────────────────
  ft = { "tex", "plaintex", "bib" },

  -- ── main configuration block ────────────────────────────────────────────
  config = function()
    ------------------------------------------------------------------------
    -- 1.  General
    ------------------------------------------------------------------------
    vim.g.tex_flavor          = "latex"   -- force LaTeX flavour detection
    vim.g.vimtex_log_verbose  = 0         -- keep :messages clean
    vim.g.vimtex_complete_enabled = 1     -- omni completion
    vim.g.vimtex_indent_enabled   = 1     -- smart indentation

    ------------------------------------------------------------------------
    -- 2.  Compiler (latexmk ➜ XeLaTeX)
    ------------------------------------------------------------------------
    vim.g.vimtex_compiler_latexmk = {
      executable = "latexmk",
      options    = {
        "-xelatex",                 -- *** engine of choice ***
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-shell-escape",            -- allow TikZ externalisation & pythontex
      },
      callback   = 1,               -- asynchronous, auto-refresh on save
      continuous = 1,               -- keep running in the background
    }

    ------------------------------------------------------------------------
    -- 3.  PDF viewer (Skim) – best match for macOS
    ------------------------------------------------------------------------
    vim.g.vimtex_view_method        = "skim"
    vim.g.vimtex_view_skim_activate = 1    -- raise Skim on view
    vim.g.vimtex_view_skim_sync     = 1    -- forward & inverse search

    ------------------------------------------------------------------------
    -- 4.  Quickfix behaviour
    ------------------------------------------------------------------------
    vim.g.vimtex_quickfix_mode           = 2   -- open on first error
    vim.g.vimtex_quickfix_open_on_warning = 0  -- but stay closed on warns

    ------------------------------------------------------------------------
    -- 5.  Folding (keep figures/tables open, fold everything else)
    ------------------------------------------------------------------------
    vim.g.vimtex_fold_enabled = 1
    vim.g.vimtex_fold_types   = {
      envs = {
        blacklist = { "tikzpicture", "figure", "table" },
      },
    }

    ------------------------------------------------------------------------
    -- 6.  Conceal & syntax niceties
    ------------------------------------------------------------------------
    vim.opt.conceallevel = 2
    vim.g.tex_conceal = "abdmg"  -- accents | bold/italics | greek | math

    ------------------------------------------------------------------------
    -- 7.  TikZ-preview helper – render to SVG (fast & lightweight)
    ------------------------------------------------------------------------
    vim.g.vimtex_tikz_preview_engine    = "pdf2svg"
    vim.g.vimtex_tikz_preview_show_help = 0

    ------------------------------------------------------------------------
    -- 8.  Configure spell checking and diagnostics sensibly
    ------------------------------------------------------------------------
    vim.g.vimtex_grammar_vlty = { lt_command = '' }  -- Disable LanguageTool
    vim.g.vimtex_grammar_textidote = { jar = '' }    -- Disable TeXtidote
    
    -- Filter out common LaTeX false positives but keep useful errors
    vim.g.vimtex_quickfix_ignore_filters = {
      'Overfull \\hbox',
      'Underfull \\hbox',
      'Font shape.*not available',
      'Package hyperref Warning',
    }
    vim.g.vimtex_quickfix_enabled = 1  -- Keep quickfix but filtered
    vim.g.vimtex_quickfix_latexlog = {
      overfull = 0,  -- Don't show overfull hbox warnings
      underfull = 0, -- Don't show underfull hbox warnings
      packages = { hyperref = 0 }, -- Ignore hyperref warnings
    }
    
    -- Enable spell checking and diagnostics for LaTeX files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "latex", "plaintex" },
      callback = function()
        -- Enable spell checking
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { 'en_us' }
        
        -- Configure spell checking to be less intrusive
        vim.opt_local.spellcapcheck = ''
        vim.opt_local.spellsuggest = 'best,9'
        
        -- Add common LaTeX commands to spell ignore
        vim.opt_local.spellfile = vim.fn.stdpath('config') .. '/spell/tex.utf-8.add'
        
        -- Create the spell directory if it doesn't exist
        local spell_dir = vim.fn.stdpath('config') .. '/spell'
        if vim.fn.isdirectory(spell_dir) == 0 then
          vim.fn.mkdir(spell_dir, 'p')
        end
        
        -- Re-enable diagnostics for this buffer
        vim.diagnostic.enable(true, { bufnr = 0 })
        
        -- Configure diagnostics to be less noisy for LaTeX
        vim.diagnostic.config({
          virtual_text = {
            severity = { min = vim.diagnostic.severity.WARN }, -- Only show warnings and errors
            prefix = "●",
            spacing = 1,
            -- Filter out fontspec engine errors
            filter = function(diagnostic)
              local message = diagnostic.message or ""
              local source = diagnostic.source or ""
              
              -- Debug: print diagnostic info (comment out after testing)
              print("Diagnostic - Source:", source, "Message:", message:sub(1, 100))
              
              -- Filter out fontspec and engine-related errors
              if message:match("fontspec") or
                 message:match("requires either XeTeX or LuaTeX") or
                 message:match("change your typesetting engine") or
                 message:match("xelatex.*lualatex.*instead") or
                 message:match("Emergency stop") or
                 message:match("Fatal.*Package.*fontspec.*Error") then
                return false
              end
              return true
            end,
          },
          signs = {
            filter = function(diagnostic)
              local message = diagnostic.message or ""
              -- Filter out fontspec errors from signs too
              if message:match("fontspec.*requires.*XeTeX.*LuaTeX") or
                 message:match("change.*typesetting.*engine.*xelatex") or
                 message:match("Emergency stop") then
                return false
              end
              return true
            end,
          },
          underline = {
            severity = { min = vim.diagnostic.severity.WARN }, -- Only underline warnings and errors
            filter = function(diagnostic)
              local message = diagnostic.message or ""
              -- Filter out fontspec errors from underlines too
              if message:match("fontspec.*requires.*XeTeX.*LuaTeX") or
                 message:match("change.*typesetting.*engine.*xelatex") or
                 message:match("Emergency stop") then
                return false
              end
              return true
            end,
          },
          update_in_insert = false, -- Don't show diagnostics while typing
        }, vim.api.nvim_get_current_buf())
        
        -- Spell checking keymaps
        local buf_map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = 0, desc = desc })
        end
        
        buf_map('n', 'z=', function()
          require('telescope.builtin').spell_suggest()
        end, 'Spell suggestions')
        buf_map('n', ']s', ']s', 'Next misspelled word')
        buf_map('n', '[s', '[s', 'Previous misspelled word')
        buf_map('n', 'zg', 'zg', 'Add word to spellfile')
        buf_map('n', 'zw', 'zw', 'Mark word as bad')
        buf_map('n', 'zug', 'zug', 'Remove word from spellfile')
      end,
    })

    ------------------------------------------------------------------------
    -- 9.  Custom key-bindings (leader-l c/v/s)
    ------------------------------------------------------------------------
    local map = vim.keymap.set
    map("n", "<leader>lc", "<cmd>VimtexCompile<CR>", { desc = "LaTeX: Compile" })
    map("n", "<leader>lv", "<cmd>VimtexView<CR>",    { desc = "LaTeX: View PDF" })
    map("n", "<leader>ls", "<cmd>VimtexStop<CR>",    { desc = "LaTeX: Stop compilation" })
  end,
}

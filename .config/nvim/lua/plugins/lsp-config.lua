-- ~/.config/nvim/lua/plugins/lsp-config.lua
-- Robust LSP stack powered by Mason ► mason-lspconfig ► nvim-lspconfig
-- Includes Lua, Python, Ruff, LaTeX, Prettier, JSON, YAML, HTML/CSS, Bash
---@diagnostic disable: undefined-global

return {
  ---------------------------------------------------------------------------
  -- 0. Mason core -----------------------------------------------------------
  ---------------------------------------------------------------------------
  { 'williamboman/mason.nvim', config = true },

  ---------------------------------------------------------------------------
  -- 1. Bridge Mason ↔ LSPConfig --------------------------------------------
  ---------------------------------------------------------------------------
  {
    'williamboman/mason-lspconfig.nvim',
    opts = {
      ensure_installed = {
        'lua_ls', 'pyright', 'ruff', 'texlab',
        'jsonls', 'yamlls', 'html', 'cssls', 'bashls',
      },
      automatic_installation = false, -- Explicitly disable auto-installation
      -- you could also put `handlers = {}` here instead of the ★ line below
    },
  },

  ---------------------------------------------------------------------------
  -- 2. LSPConfig + per-server setup & keymaps ------------------------------
  ---------------------------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },

    config = function()
      -----------------------------------------------------------------------
      -- ★  turn off Mason's *automatic* lspconfig.setup({}) ----------------
      -----------------------------------------------------------------------
      require('mason-lspconfig').setup({ 
        handlers = {
          -- Disable auto-setup for ltex (we'll use ltex_plus instead)
          ['ltex'] = function() end,
          -- Disable auto-setup for ltex_plus (we'll configure it manually)
          ['ltex_plus'] = function() end,
        }
      })

      -- Aggressively prevent default ltex_plus from starting
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "ltex_plus" then
            -- Check if this is the default instance (without our custom settings)
            local settings = client.config.settings or {}
            local ltex_settings = settings.ltex or {}
            
            -- If it doesn't have our custom dictionary, stop it
            if not ltex_settings.dictionary or not ltex_settings.dictionary["en-US"] then
              vim.lsp.stop_client(client.id)
              return
            end
          end
        end,
      })

      local lspconfig = require('lspconfig')
      local util      = require('lspconfig.util')

      -----------------------------------------------------------------------
      -- Capabilities (add nvim-cmp if installed) ---------------------------
      -----------------------------------------------------------------------
      local has_cmp, cmp = pcall(require, 'cmp_nvim_lsp')
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        has_cmp and cmp.default_capabilities() or {}
      )

      -----------------------------------------------------------------------
      -- On-attach helper ----------------------------------------------------
      -----------------------------------------------------------------------
      local on_attach = function(_, bufnr)
        local map = function(lhs, rhs)
          vim.keymap.set('n', lhs, rhs,
            { buffer = bufnr, silent = true, noremap = true })
        end
        map('K',  vim.lsp.buf.hover)
        map('gd', vim.lsp.buf.definition)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action,
          { buffer = bufnr, silent = true, noremap = true })
      end

      -----------------------------------------------------------------------
      -- 2.1  Lua ------------------------------------------------------------
      -----------------------------------------------------------------------
      lspconfig.lua_ls.setup({
        on_attach    = on_attach,
        capabilities = capabilities,

        root_dir = function(fname)
          local root = util.root_pattern('.git', '.luarc.json', '.luarc.jsonc')(fname)
          if not root
            and fname:sub(1, #vim.fn.stdpath('config')) == vim.fn.stdpath('config')
          then
            root = vim.fn.stdpath('config')
          end
          return root or vim.fs.dirname(fname)
        end,

        settings = {
          Lua = {
            runtime     = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim', 'require' } },
            workspace   = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
            telemetry   = { enable = false },
          },
        },
      })

      -----------------------------------------------------------------------
      -- 2.2  Python: Pyright + Ruff ----------------------------------------
      -----------------------------------------------------------------------
      local py_venv = require("config.py_venv")

      lspconfig.pyright.setup({
        on_attach    = on_attach,
        capabilities = capabilities,

        before_init = function(params, config)
          local buf_path = vim.uri_to_fname(params.rootUri)
          local root_dir = git_root(buf_path) or vim.fs.dirname(buf_path)

        local venv = py_venv.detect(root_dir)
        if venv then
          config.settings           = config.settings           or {}
          config.settings           = config.settings.python    or {}

          config.settings.python.venvPath = vim.fs.dirname(venv)
          config.settings.python.venv     = vim.fs.basename(venv)
          config.settings.python.analysis = { ignoreMissingImports = true }
          end 
        end,
      })

      lspconfig.ruff.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        init_options = { settings = { args = {} } },
      })

      -----------------------------------------------------------------------
      -- 2.3  LaTeX ----------------------------------------------------------
      -----------------------------------------------------------------------
      lspconfig.texlab.setup({
        on_attach    = on_attach,
        capabilities = capabilities,
        settings     = {
          texlab = {
            build = {
              onSave = true,               -- Enable for diagnostics
              executable = 'xelatex',      -- Use xelatex directly for diagnostics
              args = {
                '-file-line-error',
                '-synctex=1', 
                '-interaction=nonstopmode',
                '-shell-escape',
                '-output-directory=build',   -- Keep build files organized
                '%f'
              },
              forwardSearchAfter = false,
            },
            -- Enable diagnostics with proper engine
            diagnosticsDelay = 300,
            auxDirectory = 'build',
            bibtexFormatter = 'texlab',
            forwardSearch = {
              executable = 'zathura',
              args       = { '--synctex-forward', '%l:1:%f', '%p' },
            },
            chktex = {
              onEdit = false,              -- Disable ChkTeX to avoid noise
              onOpenAndSave = false,
            },
            latexFormatter = 'latexindent',
            latexindent = {
              ['local'] = nil,
              modifyLineBreaks = false,
            },
          },
        },
      })

      -----------------------------------------------------------------------
      -- 2.4  LTeX Plus (Grammar and Spell Checking) -------------------------
      -----------------------------------------------------------------------
      -- Configure ltex_plus with our custom settings
      lspconfig.ltex_plus.setup({
        on_attach = function(client, bufnr)
          -- Call the default on_attach
          on_attach(client, bufnr)
          
          -- Send workspace configuration to disable problematic rules
          vim.defer_fn(function()
            local dict_file = vim.fn.stdpath('config') .. '/spell/tex.utf-8.add'
            client.notify('workspace/didChangeConfiguration', {
              settings = {
                ltex = {
                  disabledRules = {
                    ["en-US"] = {
                      "MORFOLOGIK_RULE_EN_US",
                      "COMMA_PARENTHESIS_WHITESPACE",
                      "WHITESPACE_RULE",
                      "EN_QUOTES",
                      "SENTENCE_WHITESPACE",
                    },
                  },
                  dictionary = {
                    ["en-US"] = { ":" .. dict_file },
                  },
                },
              },
            })
          end, 2000)
          
          -- Create command to add words to LTeX Plus dictionary
          vim.api.nvim_create_user_command('LTexAddWord', function(opts)
            local word = opts.args
            if word == "" then
              word = vim.fn.expand("<cword>")
            end
            
            local clients = vim.lsp.get_clients({ name = "ltex_plus" })
            for _, ltex_client in ipairs(clients) do
              ltex_client.notify('workspace/didChangeConfiguration', {
                settings = {
                  ltex = {
                    dictionary = {
                      ["en-US"] = { word },
                    },
                  },
                },
              })
              print("Added '" .. word .. "' to LTeX Plus dictionary")
            end
          end, { nargs = '?' })
        end,
        capabilities = capabilities,
        cmd = { "ltex-ls-plus" },
        filetypes = { "tex", "latex", "plaintex", "markdown" },
        settings = {
          ltex = {
            enabled = { "latex", "tex", "plaintex", "markdown" },
            language = "en-US",
            -- Disable the overly strict morphology rule that flags proper names
            disabledRules = {
              ["en-US"] = {
                "MORFOLOGIK_RULE_EN_US",  -- This rule flags proper names
                "COMMA_PARENTHESIS_WHITESPACE",
                "WHITESPACE_RULE",
                "EN_QUOTES",
                "SENTENCE_WHITESPACE",
              },
            },
            dictionary = {
              ["en-US"] = { ":" .. vim.fn.stdpath('config') .. "/spell/tex.utf-8.add" },
            },
            -- Less aggressive checking
            additionalRules = {
              enablePickyRules = false,
              motherTongue = "en-US",
            },
            completionEnabled = true,
            diagnosticSeverity = "information", -- Make diagnostics less prominent
            checkFrequency = "save", -- Only check on save
          },
        },
      })

      
      -----------------------------------------------------------------------
      -- 2.6  Generic setups -------------------------------------------------
      -----------------------------------------------------------------------
      for _, server in ipairs({ 'jsonls', 'yamlls', 'html', 'cssls', 'bashls' }) do
        lspconfig[server].setup({
          on_attach    = on_attach,
          capabilities = capabilities,
        })
      end
    end,
  },
}

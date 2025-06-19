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
      -- ★  turn off Mason’s *automatic* lspconfig.setup({}) ----------------
      -----------------------------------------------------------------------
      require('mason-lspconfig').setup({ handlers = {} })

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
            build = { onSave = true },
            forwardSearch = {
              executable = 'zathura',
              args       = { '--synctex-forward', '%l:1:%f', '%p' },
            },
          },
        },
      })

      -----------------------------------------------------------------------
      -- 2.4  Generic setups -------------------------------------------------
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

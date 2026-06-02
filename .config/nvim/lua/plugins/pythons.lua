return {
  -- Use ty and pyrefly for python LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- pyrefly configuration
        pyrefly = {
          cmd = { "pyrefly", "lsp" },
          filetypes = { "python" },
          root_dir = function(fname)
            if not fname or fname == "" then return nil end
            local util = require("lspconfig.util")
            -- Do not start pyrefly if ty.toml is present
            if util.root_pattern("ty.toml")(fname) then
              return nil
            end
            return util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git")(fname)
              or util.path.dirname(fname)
          end,
        },

        -- ty configuration
        ty = {
          cmd = { "ty" },
          filetypes = { "python" },
          root_dir = function(fname)
            if not fname or fname == "" then return nil end
            local util = require("lspconfig.util")
            return util.root_pattern("ty.toml")(fname)
          end,
        },

        -- Other Python LSPs
        ruff = {},
        pyright = { enabled = false },
        basedpyright = { enabled = false },
      },
      setup = {
        pyrefly = function(_, sopts)
          local configs = require("lspconfig.configs")
          if not configs.pyrefly then
            configs.pyrefly = {
              default_config = sopts,
            }
          end
          require("lspconfig").pyrefly.setup({})
          return true
        end,
        ty = function(_, sopts)
          local configs = require("lspconfig.configs")
          if not configs.ty then
            configs.ty = {
              default_config = sopts,
            }
          end
          require("lspconfig").ty.setup({})
          return true
        end,
      },
    },
  },

  -- Set Ruff as the default formatter
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    },
  },
}

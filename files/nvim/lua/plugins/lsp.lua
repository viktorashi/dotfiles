return {
  -- Use ty for type checking
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Language extras provide most server settings. These additional
        -- servers are also resolved from the Mise-activated PATH.
        bashls = {},
        pyrefly = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- Do not start pyrefly if ty.toml is present
            if
              util.root_pattern("ty.toml")(fname)
            then
              return nil
            end
            return util.root_pattern(
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
              ".git"
            )(fname)
          end,
        },
        ty = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("ty.toml")(
              fname
            )
          end,
        },
        ruff_lsp = {},
        pyright = { enabled = false },
        basedpyright = { enabled = false },
        gopls = {
          settings = {
            gopls = {
              buildFlags = { "-tags=e2e" },
            },
          },
        },
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

  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft
        or {}
      opts.linters_by_ft.sh = { "shellcheck" }
    end,
  },
}

return {
  -- Use ty for type checking
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyrefly = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- Do not start pyrefly if ty.toml is present
            if util.root_pattern("ty.toml")(fname) then
              return nil
            end
            return util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git")(fname)
          end,
        },
        ty = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("ty.toml")(fname)
          end,
        },
        ruff_lsp = {},
        pyright = { enabled = false },
        basedpyright = { enabled = false },
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

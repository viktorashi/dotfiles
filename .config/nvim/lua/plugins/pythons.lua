return {
  -- Use ty for type checking
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ty = {},
        ruff_lsp = {},
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

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Marksman owns Markdown structure, symbols, links, and navigation.
        -- rumdl remains the linting, quick-fix, and formatting server.
        rumdl = {
          init_options = {
            enableLinkCompletions = false,
            enableLinkNavigation = false,
            enableSymbols = false,
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "rumdl" },
        ["markdown.mdx"] = { "rumdl" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft
        or {}
      -- rumdl already publishes diagnostics through LSP.
      opts.linters_by_ft.markdown = {}
    end,
  },
}

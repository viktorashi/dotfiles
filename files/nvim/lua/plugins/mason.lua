return {
  -- LazyVim's extras still define and configure every LSP. Without
  -- mason-lspconfig, LazyVim enables those servers directly from PATH.
  {
    "mason-org/mason-lspconfig.nvim",
    enabled = false,
  },

  -- Mason is retained only as the package store used by mason-nvim-dap.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- LazyVim extras add formatters and LSPs here; Mise owns all of them.
      opts.ensure_installed = {}

      -- System/Mise commands win. Mason's bin directory remains available
      -- afterward for the debugger adapter launch commands.
      opts.PATH = "append"
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "codelldb",
        "delve",
        "python",
        "js",
      },
    },
  },
}

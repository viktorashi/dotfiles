return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- VTSLS is the sole TypeScript language server.
      opts.servers.tsserver = nil
      opts.servers.ts_ls = nil
    end,
  },
}

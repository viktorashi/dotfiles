return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "latex",
        "bibtex", -- this pulls in tree-sitter-bibtex
      },
    },
  },
}

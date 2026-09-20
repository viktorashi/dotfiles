return {
  -- 1. Tell Tree-sitter to use the terraform/hcl parser for "opentofu" filetype
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.treesitter.language.register(
        "terraform",
        "opentofu"
      )
    end,
  },

  -- 2. Enable tofu_ls in lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tofu_ls = {
          enabled = true,
          filetypes = {
            "opentofu",
            "opentofu-vars",
            "terraform",
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tflint = {
          enabled = true,
          filetypes = { "terraform" },
        },
      },
    },
  },
}

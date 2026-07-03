return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      "folke/snacks.nvim", -- optional
    },
    keys = {
      {
        "<leader>gn",
        "<cmd>lua require('neogit').open({kind = 'floating'})<CR>",
        mode = { "n" },
        desc = "Neogit normal gen",
      },
    },
  },
}

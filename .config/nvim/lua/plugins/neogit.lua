return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      "ibhagwan/fzf-lua", -- optional
      "nvim-mini/mini.pick", -- optional
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

return {
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    config = true,
    window = {
      winblend = 30,
    },
    keys = { -- load the plugin only when using it's keybinding:
      {
        -- vezi ca tre sa apesi gen frt repede ca sa mearga ca altfel se deschide UI menu
        "<leader>u",
        "<cmd>lua require('undotree').toggle()<cr>",
      },
    },
  },
}

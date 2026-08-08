return {
  {
    "jiaoshijie/undotree",
    dependencies = "nvim-lua/plenary.nvim",
    opts = {
      window = {
        winblend = 30,
      },
    },
    keys = {
      {
        "<leader>u",
        function() require("undotree").toggle() end,
      },
    },
  },
}

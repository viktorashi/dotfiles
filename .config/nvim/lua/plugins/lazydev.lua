return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        {
          path = "${3rd}/luv/library",
          words = { "vim%.uv" },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = {
          "lazydev",
          "lsp",
          "path",
          "snippets",
          "buffer",
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
    enabled = function()
      -- disable blink for LaTeX
      local ft = vim.bo.filetype
      return not (
        ft == "tex"
        or ft == "plaintex"
        or ft == "latex"
      )
    end,
  },
}

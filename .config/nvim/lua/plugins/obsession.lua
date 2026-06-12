return {
  {
    dir = vim.fn.expand("~/.local/share/editor-packages/vim-obsession"),
    lazy = false,
    config = function()
      vim.cmd.source(vim.fn.expand("~/docs/startup-scripts/obsession-bootstrap.vim"))
    end,
  },
}

return {
  -- Disable buffer and snippets completion sources for blink.cmp (default in newer LazyVim versions)
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          buffer = { enabled = false },
          snippets = { enabled = false },
        },
      },
    },
  },

  -- Disable buffer and snippets completion sources for nvim-cmp (if active instead)
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      if opts.sources then
        opts.sources = vim.tbl_filter(function(source)
          return source.name ~= "buffer" and source.name ~= "snippets"
        end, opts.sources)
      end
      return opts
    end,
  },
}

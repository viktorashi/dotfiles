return {
  -- Disable buffer completion source for blink.cmp (default in newer LazyVim versions)
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      if opts.sources and opts.sources.default then
        opts.sources.default = vim.tbl_filter(function(source)
          return source ~= "buffer"
        end, opts.sources.default)
      end
    end,
  },

  -- Disable buffer completion source for nvim-cmp (if active instead)
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      if opts.sources then
        opts.sources = vim.tbl_filter(function(source)
          return source.name ~= "buffer"
        end, opts.sources)
      end
    end,
  },
}

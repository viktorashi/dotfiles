return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    opts.sources = vim.tbl_filter(function(source)
      -- remove these sources
      return (
        source.name ~= "spell"
        or source.name ~= "buffer"
        or source.name ~= "emoji"
      )
    end, opts.sources)
  end,
}

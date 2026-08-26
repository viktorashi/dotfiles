return {
  -- Configure blink.cmp (LazyVim's default completion engine)
  {
    "saghen/blink.cmp",
    opts = {
      fuzzy = {
        sorts = {
          -- Deprioritize python dunder methods (__)
          function(a, b)
            local a_is_dunder = a.label:sub(1, 2)
              == "__"
            local b_is_dunder = b.label:sub(1, 2)
              == "__"
            if a_is_dunder ~= b_is_dunder then
              return b_is_dunder
            end
            return nil
          end,
          -- Fallback to default sorts
          "score",
          "sort_text",
        },
      },
      sources = {
        providers = {
          buffer = { enabled = false },
          -- The custom LuaSnip collection is currently LaTeX-specific.
          snippets = {
            enabled = function()
              return vim.tbl_contains(
                { "tex", "plaintex", "latex" },
                vim.bo.filetype
              )
            end,
          },
        },
      },
    },
  },
}

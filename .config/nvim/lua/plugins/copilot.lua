return {
  -- Configure copilot.lua to disable ghost text suggestions and the panel completely
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        ["*"] = false,
      },
    },
  },

  -- Ensure copilot is not loaded as an autocomplete source in blink.cmp
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          copilot = { enabled = false },
        },
      },
    },
  },

  -- Ensure copilot is not loaded as an autocomplete source in nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      if opts.sources then
        opts.sources = vim.tbl_filter(
          function(source)
            return source.name ~= "copilot"
          end,
          opts.sources
        )
      end
      return opts
    end,
  },
}

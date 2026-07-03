return {
  "Saghen/blink.cmp",
  optional = true,
  dependencies = {
    "Kaiser-Yang/blink-cmp-avante",
  },
  opts = function(_, opts)
    opts.sources = opts.sources or {}
    opts.sources.default = opts.sources.default or {}
    opts.sources.providers = opts.sources.providers or {}

    if not vim.tbl_contains(opts.sources.default, "avante") then
      table.insert(opts.sources.default, 1, "avante")
    end

    opts.sources.providers.avante = {
      module = "blink-cmp-avante",
      name = "Avante",
    }
  end,
}

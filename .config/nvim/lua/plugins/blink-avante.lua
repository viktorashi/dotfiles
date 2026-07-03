return {
  "Saghen/blink.cmp",
  optional = true,
  dependencies = {
    "Kaiser-Yang/blink-cmp-avante",
  },
  opts = {
    sources = {
      default = {
        "avante",
      },
      providers = {
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
        },
      },
    },
  },
}

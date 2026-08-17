return {
  "viktorashi/avante.nvim",
  branch = "viktorashi",
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  event = "VeryLazy",
  version = false,
  dependencies = {
    "zbirenbaum/copilot.lua",
  },
  opts = {
    instructions_file = "avante.md",
    provider = "copilot",
    acp_providers = {
      opencode = {
        command = "opencode",
        args = { "acp" },
      },
    },
  },
}

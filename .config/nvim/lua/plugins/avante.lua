return {
  "yetone/avante.nvim",
  build = vim.fn.has("win32") ~= 0
      and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    or "make",
  event = "VeryLazy",
  version = false,
  opts = {
    instructions_file = "avante.md",
    provider = "opencode",
    providers = {
      copilot = {},
    },
    acp_providers = {
      opencode = {
        command = "opencode",
        args = { "acp" },
      },
    },
  },
  dependencies = {
    "zbirenbaum/copilot.lua",
  },
  keys = {
    {
      "<leader>aa",
      function()
        local api = require("avante.api")
        api.switch_provider("opencode")
        api.ask()
      end,
      mode = { "n", "v" },
      desc = "Avante Ask (OpenCode)",
    },
    {
      "<leader>an",
      function()
        local api = require("avante.api")
        api.switch_provider("opencode")
        api.ask({ new_chat = true })
      end,
      mode = { "n", "v" },
      desc = "Avante New Chat (OpenCode)",
    },
    {
      "<leader>az",
      function()
        local api = require("avante.api")
        api.switch_provider("opencode")
        api.zen_mode()
      end,
      mode = { "n", "v" },
      desc = "Avante Zen (OpenCode)",
    },
    {
      "<leader>ae",
      function()
        local api = require("avante.api")
        api.switch_provider("copilot")
        api.edit()
      end,
      mode = "v",
      desc = "Avante Edit (Copilot)",
    },
  },
}

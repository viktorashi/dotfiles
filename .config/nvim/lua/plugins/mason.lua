return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local custom_tools = {
        "mason-org/mason.nvim",
        "bash-language-server",
        "beautysh",
        "codelldb",
        "json-lsp",
        "lua-language-server",
        "markdown-toc",
        "marksman",
        "rumdl",
        "prettier",
        "shellcheck",
        "shfmt",
        "stylua",
        "taplo",
        "typescript-language-server",
        "biome",
        "yaml-language-server",
        "arduino-language-server",
        "cpplint",
        "docker-language-server",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "clang-format",
        "jinja-lsp",
        "curlylint",
        "ruff",
        "pyrefly",
        "just-lsp",
        "bicep-lsp",
        "tree-sitter-cli",
        "lemminx",
        "xmlformatter",
        "r-languageserver",
      }

      -- Merge lists while avoiding duplicates
      local seen = {}
      local merged = {}
      for _, tool in ipairs(opts.ensure_installed) do
        if not seen[tool] then
          seen[tool] = true
          table.insert(merged, tool)
        end
      end
      for _, tool in ipairs(custom_tools) do
        if not seen[tool] then
          seen[tool] = true
          table.insert(merged, tool)
        end
      end
      opts.ensure_installed = merged
    end,
  },
}

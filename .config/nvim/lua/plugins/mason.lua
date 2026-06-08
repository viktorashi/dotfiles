return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      local custom_tools = {
        "bash-language-server",
        "beautysh",
        "black",
        "codelldb",
        "eslint-lsp",
        "json-lsp",
        "lua-language-server",
        "markdown-toc",
        "markdownlint-cli2",
        "marksman",
        "prettier",
        "pyright",
        "shellcheck",
        "shfmt",
        "stylua",
        "taplo",
        "typescript-language-server",
        "yaml-language-server",
        "arduino-language-server",
        "cpplint",
        "docker-language-server",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "clang-format",
        "jinja-lsp",
        "curlylint",
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

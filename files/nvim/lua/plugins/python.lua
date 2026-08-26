local pyrefly_markers = {
  "pyrefly.toml",
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  ".git",
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Pyrefly is the default Python LSP, except in projects that opt in
        -- to ty with a ty.toml file. Ruff supplies linting and quick fixes.
        pyrefly = {
          root_dir = function(bufnr, on_dir)
            local fname =
              vim.api.nvim_buf_get_name(bufnr)
            if vim.fs.root(fname, "ty.toml") then
              return nil
            end
            on_dir(
              vim.fs.root(fname, pyrefly_markers)
                or vim.fs.dirname(fname)
            )
          end,
        },
        ty = {
          root_markers = { "ty.toml" },
          workspace_required = true,
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    },
  },
}

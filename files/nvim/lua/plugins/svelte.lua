return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "svelte" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.svelte = {}

      -- This bridge adds Svelte awareness to TypeScript buffers. VTSLS and
      -- svelteserver remain usable when the optional plugin is unavailable.
      local output = vim.fn.system({
        "mise",
        "where",
        "npm:typescript-svelte-plugin",
      })
      if vim.v.shell_error ~= 0 then
        return
      end

      LazyVim.extend(
        opts.servers.vtsls,
        "settings.vtsls.tsserver.globalPlugins",
        {
          {
            name = "typescript-svelte-plugin",
            location = vim.fs.joinpath(
              vim.trim(output),
              "node_modules",
              "typescript-svelte-plugin"
            ),
            enableForWorkspaceTypeScriptVersions = true,
          },
        }
      )
    end,
  },
}

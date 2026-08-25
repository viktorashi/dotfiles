-- Give editor integrations a stable view of every Mise-managed executable,
-- independent of the version-specific PATH inherited when Neovim started.
local mise_shims = vim.fs.joinpath(
  vim.env.HOME,
  ".local",
  "share",
  "mise",
  "shims"
)
if vim.uv.fs_stat(mise_shims) then
  local separator = jit.os == "Windows" and ";"
    or ":"
  local paths = vim.tbl_filter(
    function(entry)
      return entry ~= mise_shims
    end,
    vim.split(
      vim.env.PATH or "",
      separator,
      { plain = true }
    )
  )
  table.insert(paths, 1, mise_shims)
  vim.env.PATH = table.concat(paths, separator)
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

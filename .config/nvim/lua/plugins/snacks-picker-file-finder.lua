-- A global setting in snacks.nvim's picker configuration does not work because
-- individual picker sources often override or ignore top-level defaults,
-- requiring specific configuration per source to ensure consistent behavior.

local picker_sources = {
  "files",
  "grep",
  "smart",
  "explorer",
  "jumps",
  "lsp_references",
}
local sources = {}
for _, source in ipairs(picker_sources) do
  if source == "explorer" then
    sources[source] = {
      hidden = true,
      ignored = false,
    }
  else
    sources[source] = {
      hidden = true,
      layout = {
        fullscreen = true,
      },

      ignored = false,
    }
  end
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        db = {
          sqlite3_path = "/lib/x86_64-linux-gnu/libsqlite3.so.0",
        },
        sources = sources,
      },
    },
  },
}

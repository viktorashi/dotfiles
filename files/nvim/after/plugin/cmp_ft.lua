local has_cmp, cmp = pcall(require, "cmp")
if not has_cmp then
  return
end

local text_ft = {
  "tex",
  "plaintex",
  "latex",
  "text",
  "markdown",
  "md",
  "rst",
  "txt",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = text_ft,
  callback = function()
    -- set minimal sources for these buffers (LSP + snippets only)
    cmp.setup.buffer({
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
      },
      experimental = {
        ghost_text = false, -- optional: turn ghost text off in text files
      },
    })
  end,
})

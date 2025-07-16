-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- vim.keymap.set(
--   -- vezi ca tre sa apesi gen frt repede ca sa mearga ca altfel se deschide UI menu
--   "n",
--   "<leader>u",
--   require("undotree").toggle,
--   { noremap = true, silent = true }
-- )

-- sper ca merge pe windows panarama
vim.keymap.set("n", "<leader><delete>", function()
  Snacks.bufdelete()
end, { desc = "Close Buffer" })

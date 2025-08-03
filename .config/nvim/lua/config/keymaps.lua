-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- map(
--   -- vezi ca tre sa apesi gen frt repede ca sa mearga ca altfel se deschide UI menu
--   "n",
--   "<leader>u",
--   require("undotree").toggle,
--   { noremap = true, silent = true }
-- )

-- sper ca merge pe windows panarama
map("n", "<leader><delete>", function()
  Snacks.bufdelete()
end, { desc = "Close Buffer" })

-- map(
--   "n",
--   "<C-w>",
--   ":bdelete<CR>",
--   { desc = "Inchide bufferu asta ca omu" }
-- )

map("n", "<C-w>", function()
  -- vim.bo.buflisted = false
  -- vim.api.nvim_buf_delete(0, { unload = true })
  Snacks.bufdelete()
end, { desc = "Inchide bufferu asta ca omu" })

map("n", "<F5>", function()
  require("dap").toggle_breakpoint()
end, {
  desc = "DAP: Toggle Breakpoint",
})

map("n", "<F6>", function()
  require("dap").terminate()
end, { desc = "DAP: Terminate" })

map("n", "<F8>", function()
  require("dap").run_to_cursor()
end, { desc = "DAP: Run to cursor" })
--
-- map("n", "<F8>", function()
--   require("dap").continue()
-- end, { desc = "DAP: Continue/Start" })

vim.keymap.set("n", "<F9>", "<Leader>dr", {
  remap = true,
  desc = "Alias for <Leader>dr (open debugabbles)",
})

map("n", "<F10>", function()
  require("dap").step_over()
end, { desc = "DAP: Step Over" })

map("n", "<F11>", function()
  require("dap").step_into()
end, { desc = "DAP: Step Into" })

map("n", "<F12>", function()
  require("dap").step_out()
end, { desc = "DAP: Step Out" })

map("n", "<Leader>db", function()
  require("dap").set_breakpoint(
    vim.fn.input("Breakpoint condition: ")
  )
end, {
  desc = "DAP: Set Conditional Breakpoint",
})

require("neoscroll").setup({
  mappings = { -- Keys to be mapped to their corresponding default scrolling animation
    "<C-u>",
    "<C-d>",
    "<C-b>",
    "<C-f>",
    "<C-y>",
    "<C-e>",
    "zt",
    "zz",
    "zb",
  },
  hide_cursor = true, -- Hide cursor while scrolling
  stop_eof = true, -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  duration_multiplier = 0.7, -- Global duration multiplier
  easing = "linear", -- Default easing function
  pre_hook = nil, -- Function to run before the scrolling animation starts
  post_hook = nil, -- Function to run after the scrolling animation ends
  performance_mode = false, -- Disable "Performance Mode" on all buffers.
  ignored_events = { -- Events ignored while scrolling
    "WinScrolled",
    "CursorMoved",
  },
})

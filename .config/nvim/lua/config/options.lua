-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Neovide font configuration
if vim.g.neovide then
  -- UI scaling
  vim.g.neovide_scale_factor = 1.6

  -- Optional nice extras:
  vim.g.neovide_cursor_animation_length = 0.03
  -- vim.g.neovide_refresh_rate = 120
end

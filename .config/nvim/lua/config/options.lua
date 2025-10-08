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

  local function set_scale(new)
    -- round to 2 decimal places and clamp
    local v = math.floor(new * 100 + 0.5) / 100
    if v < 0.5 then
      v = 0.5
    end
    if v > 4.0 then
      v = 4.0
    end
    vim.g.neovide_scale_factor = v
    -- vim.notify(
    --   "Neovide scale: " .. v,
    --   vim.log.levels.INFO
    -- )
  end

  local function inc_scale()
    set_scale(vim.g.neovide_scale_factor * 1.1)
  end
  local function dec_scale()
    set_scale(vim.g.neovide_scale_factor / 1.1)
  end
  local function reset_scale()
    set_scale(1.6)
  end

  -- map in normal/insert/visual so it works anywhere
  -- note: Cmd+Plus is usually Cmd+Shift+= so we bind both variants
  vim.keymap.set(
    { "n", "i", "v" },
    "<D-=>",
    inc_scale,
    { noremap = true, silent = true }
  )
  vim.keymap.set(
    { "n", "i", "v" },
    "<D-+>",
    inc_scale,
    { noremap = true, silent = true }
  )
  vim.keymap.set(
    { "n", "i", "v" },
    "<D-->",
    dec_scale,
    { noremap = true, silent = true }
  )
  vim.keymap.set(
    { "n", "i", "v" },
    "<D-0>",
    reset_scale,
    { noremap = true, silent = true }
  )
end

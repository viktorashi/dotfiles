-- ~/.config/nvim/after/plugin/disable_cmp_spell.lua
local ok, cmp = pcall(require, "cmp")
if not ok then
  return
end

local cfg = cmp.get_config() or {}
cfg.sources = vim.tbl_filter(function(s)
  return s.name ~= "spell"
end, cfg.sources or {})

cmp.setup(cfg)

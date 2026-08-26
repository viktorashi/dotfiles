return {
  -- Use Neoscroll as the sole scrolling animator.
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },
  {
    "karb94/neoscroll.nvim",
    opts = {
      mappings = {
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
      hide_cursor = true,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      duration_multiplier = 0.7,
      easing = "linear",
      performance_mode = false,
      ignored_events = {
        "WinScrolled",
        "CursorMoved",
      },
    },
  },
}

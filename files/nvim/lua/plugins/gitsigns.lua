return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local lazyvim_on_attach = opts.on_attach

      opts.on_attach = function(buffer)
        if lazyvim_on_attach then
          lazyvim_on_attach(buffer)
        end

        local gitsigns = require("gitsigns")
        local function navigate(direction)
          return function()
            if vim.wo.diff then
              vim.cmd.normal({
                direction == "next" and "]c"
                  or "[c",
                bang = true,
              })
            else
              gitsigns.nav_hunk(direction, {
                target = "all",
                wrap = vim.o.wrapscan,
                foldopen = vim.o.foldopen:find(
                  "search",
                  1,
                  true
                ) ~= nil,
                navigation_message = vim.o.shortmess:find(
                  "S",
                  1,
                  true
                ) == nil,
                greedy = true,
                count = vim.v.count1,
              })
            end
          end
        end

        vim.keymap.set(
          "n",
          "]h",
          navigate("next"),
          {
            buffer = buffer,
            desc = "Next Hunk (Staged or Unstaged)",
            silent = true,
          }
        )
        vim.keymap.set(
          "n",
          "[h",
          navigate("prev"),
          {
            buffer = buffer,
            desc = "Prev Hunk (Staged or Unstaged)",
            silent = true,
          }
        )
      end
    end,
  },
}

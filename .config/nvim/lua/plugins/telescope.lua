return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    opts = {
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
    keys = {
      {
        "<leader>sf",
        function()
          local path = vim.fn.expand("%:p:h")
          local git_root = vim.fn.systemlist({
            "git",
            "-C",
            path,
            "rev-parse",
            "--show-toplevel",
          })[1]

          require("telescope.builtin").grep_string({
            cwd = git_root ~= "" and git_root
              or vim.uv.cwd(),
            search = "",
            only_sort_text = true,
            path_display = { "smart" },
            additional_args = function()
              return { "--hidden", "--glob=!.git" }
            end,
          })
        end,
        desc = "Fuzzy Find Text (Project Root)",
      },
    },
  },
}

return {
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer =
        "SumatraPDF.exe" -- or skim/zathura depending on OS
      vim.g.vimtex_view_general_options =
        "-reuse-instance -forward-search @tex @line @pdf"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_bibtex_sources = { "bib" }
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
    end,
  },

  {
    "kdheepak/cmp-latex-symbols",
    ft = { "tex", "plaintex", "latex" },
    dependencies = { "hrsh7th/nvim-cmp" },
    init = function()
      -- prevent the plugin’s after/plugin script from breaking when cmp is not loaded
      require("lazy.core.loader").disable_rtp_plugin(
        "cmp-latex-symbols"
      )
    end,
  },

  {
    "latex-lsp/tree-sitter-bibtex",
    ft = "bib",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        ensure_installed = { "bibtex" },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = {
                  "-pdf",
                  "-interaction=nonstopmode",
                  "-synctex=1",
                  "%f",
                },
                onSave = false,
                forwardSearchAfter = true,
              },
              forwardSearch = {
                executable = "SumatraPDF.exe", -- adjust: skim/zathura/sumatrapdf
                args = {
                  "-reuse-instance",
                  "-forward-search",
                  "%f",
                  "%l",
                  "%p",
                },
              },
              chktex = {
                onEdit = true,
                onOpenAndSave = true,
              },
              diagnosticsDelay = 300,
              formatterLineLength = 80,
              latexFormatter = "latexindent",
              bibtexFormatter = "texlab",
            },
          },
        },
      },
    },
  },
}

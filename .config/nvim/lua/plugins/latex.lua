return {
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "general" -- Linux (use skim on macOS, sumatrapdf on Windows)
      vim.g.vimtex_view_general_viewer =
        "SumatraPDF.exe"
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
    -- disable the plugin's after/plugin script
    lazy = true,
    config = function()
      -- run after nvim-cmp is fully loaded
      local cmp_status, cmp =
        pcall(require, "cmp")
      if not cmp_status then
        return
      end

      -- register latex_symbols source for current buffer
      cmp.setup.buffer({
        sources = cmp.config.sources({
          { name = "latex_symbols" },
        }),
      })
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
                executable = "zathura", -- skim/sumatrapdf depending on OS
                args = {
                  "--synctex-forward",
                  "%l:1:%f",
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
              bibtexFormatter = "texlab", -- enables BibTeX completion
            },
          },
        },
      },
    },
  },
}

return {
  {
    "lervag/vimtex",
    lazy = false,
    config = function()
      -- TeX flavor
      vim.g.tex_flavor = "latex"

      -- Viewer setup (SumatraPDF)
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer =
        "SumatraPDF.exe"
      vim.g.vimtex_view_general_options =
        "-reuse-instance -forward-search @tex @line @pdf"
      vim.g.vimtex_view_general_options_latexmk =
        vim.g.vimtex_view_general_options

      -- Compiler setup
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        executable = "latexmk",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
          "-silent",
          "-use-make",
        },
      }

      -- Quickfix / diagnostics
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_autoclose_after_success =
        1

      -- User commands
      vim.api.nvim_create_user_command(
        "BuildLatex",
        function()
          vim.cmd("VimtexCompile")
        end,
        {}
      )

      vim.api.nvim_create_user_command(
        "CleanLatex",
        function()
          vim.cmd("VimtexClean")
        end,
        {}
      )
    end,
  },

  -- Optional: LaTeX symbols completion
  {
    "kdheepak/cmp-latex-symbols",
    ft = { "tex", "plaintex", "latex" },
    dependencies = { "hrsh7th/nvim-cmp" },
    init = function()
      require("lazy.core.loader").disable_rtp_plugin(
        "cmp-latex-symbols"
      )
    end,
  },

  -- BibTeX support
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
                  "@pdf",
                  "@line",
                  "@tex",
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
  -- {
  --   "ltex-plus/ltex-ls-plus",
  --   ft = { "tex", "bib" },
  --   config = function()
  --     local lspconfig = require("lspconfig")
  --
  --     -- TEMPORARILY DISABLE LTEX/Languagetool
  --     local enable_ltex = false -- change to true to enable again
  --
  --     if enable_ltex then
  --       lspconfig.ltex.setup({
  --         cmd = { "ltex-ls-plus.cmd" },
  --         filetypes = { "tex", "bib" },
  --         settings = {
  --           ltex = {
  --             ignoreEnvironments = {
  --               "lstlisting",
  --               "verbatim",
  --               "minted",
  --             },
  --           },
  --         },
  --       })
  --     end
  --   end,
  -- },
}

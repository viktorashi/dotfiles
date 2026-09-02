local tex_filetypes =
  { "tex", "plaintex", "latex" }

return {
  -- LazyVim's TeX extra owns the base VimTeX, Texlab, and Tree-sitter setup.
  -- These are the local Windows/WSL viewer and compiler preferences.
  {
    "lervag/vimtex",
    init = function()
      vim.g.tex_flavor = "latex"

      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer =
        "SumatraPDF.exe"
      vim.g.vimtex_view_general_options =
        "-reuse-instance -forward-search @tex @line @pdf"

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

      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_quickfix_autoclose_after_success =
        1

      vim.api.nvim_create_user_command(
        "BuildLatex",
        "VimtexCompile",
        {}
      )
      vim.api.nvim_create_user_command(
        "CleanLatex",
        "VimtexClean",
        {}
      )
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        esbonio = {
          enabled = true,
        },
        ltex_plus = {
          enabled = false,
        },
        texlab = {
          enabled = false,
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
                executable = "SumatraPDF.exe",
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

  -- Use the existing LuaSnip collection through LazyVim's active completion
  -- engine (blink.cmp), instead of maintaining a second nvim-cmp stack.
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    init = function()
      LazyVim.on_load("LuaSnip", function()
        require("luasnip.loaders.from_lua").lazy_load({
          paths = vim.fn.stdpath("config")
            .. "/LuaSnip",
        })
      end)
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = {
      "kdheepak/cmp-latex-symbols",
      "saghen/blink.compat",
    },
    opts = {
      sources = {
        compat = { "latex_symbols" },
        providers = {
          latex_symbols = {
            kind = "LatexSymbols",
            async = true,
            enabled = function()
              return vim.tbl_contains(
                tex_filetypes,
                vim.bo.filetype
              )
            end,
            opts = { strategy = 0 },
          },
        },
      },
    },
  },
}

-- lua/plugins/dap-rust.lua

return {
  -- Make sure nvim-dap and nvim-dap-ui are loaded
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- Installs the codelldb debug adapter
      {
        "williamboman/mason.nvim",
        opts = function(_, opts)
          if not opts.ensure_installed then
            opts.ensure_installed = {}
          end
          table.insert(
            opts.ensure_installed,
            "codelldb"
          )
        end,
      },
      {
        "rcarriga/nvim-dap-ui",
        -- Configure nvim-dap-ui
        config = function()
          local dapui = require("dapui")
          dapui.setup({
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.25 },
                  {
                    id = "breakpoints",
                    size = 0.25,
                  },
                  { id = "stacks", size = 0.25 },
                  { id = "watches", size = 0.25 },
                },
                size = 40,
                position = "left",
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 }, -- The console is crucial for stdin/stdout
                },
                size = 15,
                position = "bottom",
              },
            },
            controls = {
              enabled = true,
              element = "repl",
            },
            floating = {
              max_height = 0.9,
              max_width = 0.9,
            },
          })

          local dap = require("dap")
          -- Toggle UI on debug events
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end
        end,
      },
    },
    config = function()
      local dap = require("dap")

      --
      -- ||| ADAPTER CONFIGURATION |||
      --
      -- Tells nvim-dap how to start the codelldb adapter
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          -- This command is automatically handled by mason.nvim
          command = "codelldb.cmd",
          args = { "--port", "${port}" },
        },
      }

      --
      -- ||| LAUNCH CONFIGURATION FOR RUST |||
      --
      -- This is the main configuration that launches your app
      dap.configurations.rust = {
        {
          name = "Launch Rust App (Integrated Terminal)",
          type = "codelldb", -- Must match the adapter name above
          request = "launch", -- This is key: it tells dap to START the process
          program = function()
            -- This function prompts you for the executable path.
            -- It intelligently defaults to the standard cargo debug path.
            return vim.fn.input(
              "Path to executable: ",
              vim.fn.getcwd() .. "/target/debug/",
              "file"
            )
          end,
          cwd = "${workspaceFolder}", -- Sets the current working directory
          stopOnEntry = false, -- Don't stop at the program's entry point
          --
          -- ||| THIS IS THE MAGIC PART FOR STDIN/STDOUT |||
          --
          -- "integratedTerminal" tells dap to spawn the process in a terminal
          -- that Neovim manages. nvim-dap-ui will display this terminal in its
          -- "console" window, allowing you to see stdout and type for stdin.
          console = "integratedTerminal",
        },
        -- You could add an "attach" configuration here as well if needed
        -- {
        --   name = "Attach to PID",
        --   type = "codelldb",
        --   request = "attach",
        --   pid = require('dap.utils').pick_process,
        --   cwd = "${workspaceFolder}",
        -- },
      }

      --
      -- ||| KEYMAPS |||
      --
      -- Set up your debugging keymaps
      local map = vim.keymap.set

      map("n", "<F5>", function()
        require("dap").continue()
      end, { desc = "DAP: Continue/Start" })

      map("n", "<F6>", function()
        require("dap").terminate()
      end, { desc = "DAP: Terminate" })

      map("n", "<F9>", function()
        require("dap").toggle_breakpoint()
      end, {
        desc = "DAP: Toggle Breakpoint",
      })

      map("n", "<F10>", function()
        require("dap").step_over()
      end, { desc = "DAP: Step Over" })

      map("n", "<F11>", function()
        require("dap").step_into()
      end, { desc = "DAP: Step Into" })

      map("n", "<F12>", function()
        require("dap").step_out()
      end, { desc = "DAP: Step Out" })

      map("n", "<Leader>db", function()
        require("dap").set_breakpoint(
          vim.fn.input("Breakpoint condition: ")
        )
      end, {
        desc = "DAP: Set Conditional Breakpoint",
      })
    end,
  },
}

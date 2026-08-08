return {
  {
    -- The main dependency for DAP
    "mfussenegger/nvim-dap",
  },
  {
    -- The UI component for DAP
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Automatically open DAP UI when debugging starts, and closes it on termination/exiting
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      if not dap.configurations.rust then
        dap.configurations.rust = {}
      end

      table.insert(dap.configurations.rust, 1, {
        name = "Launch (target/debug)",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input(
            "Path to executable: ",
            vim.fn.getcwd() .. "/target/debug/",
            "file"
          )
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        runInTerminal = false,
      })
    end,
  },
}

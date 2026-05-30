-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.api.nvim_create_user_command(
  "StartupList",
  function()
    local output = vim.fn.system(
      'powershell.exe -File "C:\\Users\\istan\\docs\\vindovs\\manage-startup-apps.ps1" -Action list'
    )
    print(output)
  end,
  {}
)

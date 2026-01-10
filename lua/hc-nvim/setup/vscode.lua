local N=require("hc-nvim.init_space")
---@class HC-Nvim.VSCode
local VSCode={}
function VSCode.setup()
 if vim.g.vscode==nil then
  return
 end
 N.Config.options.checker.enabled=false
 N.Config.options.change_detection.enabled=false
end
return VSCode

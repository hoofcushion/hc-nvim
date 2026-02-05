local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.VSCode
local VSCode={}
function VSCode.setup()
 if vim.g.vscode==nil then
  return
 end
 HCNvim.Config.options.checker.enabled=false
 HCNvim.Config.options.change_detection.enabled=false
end
return VSCode

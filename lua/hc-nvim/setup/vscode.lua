if vim.g.vscode ==nil then
 return
end
local Config=require("lazy.core.config")
Config.options.checker.enabled=false
Config.options.change_detection.enabled=false
local cond=Config.options.defaults.cond
Config.options.defaults.cond=function(plugin)
 if cond == false or (type(cond) == "function" and not cond(plugin)) then
  return false
 end
 return plugin.vscode==nil or plugin.vscode==true
end
return true

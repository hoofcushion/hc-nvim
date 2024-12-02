local Config=require("lazy.core.config")
Config.options.checker.enabled=false
Config.options.change_detection.enabled=false
Config.options.defaults.cond=function(plugin)
 return plugin.vscode==nil or plugin.vscode==true
end

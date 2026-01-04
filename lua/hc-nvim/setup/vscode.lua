if vim.g.vscode==nil then
 return
end
local Config=require("lazy.core.config")
Config.options.checker.enabled=false
Config.options.change_detection.enabled=false

local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
--- Load default languages pack
for _,locale in ipairs(Config.locale.fallbacks) do
 local ok,pack=pcall(function()
  return require("hc-nvim.languages."..locale.code)
 end)
 if ok and type(pack)=="table" then
  Util.I18n.load(pack)
 end
end

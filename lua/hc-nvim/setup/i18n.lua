local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
--- Load default languages pack
for _,locale in ipairs(Config.locale.fallbacks) do
 local pack=Util.prequire("hc-nvim.builtin.languages."..locale.code)
 if pack~=nil then
  Util.I18n.load(pack)
 end
end

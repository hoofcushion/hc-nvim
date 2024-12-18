local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
--- Load default language pack
for _,locale in ipairs(Config.locale.fallbacks) do
 local pack=Util.prequire("hc-nvim.builtin.language."..locale.code)
 if pack~=nil then
  Util.I18n.load(pack)
 end
end

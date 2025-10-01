local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
--- Load default language pack
for _,locale in ipairs(Config.locale.fallbacks) do
 Util.try(
  function()
   Util.I18n.load(require("hc-nvim.builtin.language."..locale.code))
  end,
  Util.ERROR
 )
end

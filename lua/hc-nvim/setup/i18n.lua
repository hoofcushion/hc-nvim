local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
--- Load default language pack
for _,locale in ipairs(Config.locale.fallbacks) do
 Util.try(
  function()
   local spec=Util.BufferCache.require("hc-nvim.builtin.language."..locale.code)
   Util.I18n.load(spec)
  end,
  Util.ERROR
 )
end

local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
--- Load default language pack
for modname,modpath in Util.iter_mod({
 "hc-nvim.builtin.language",
 "hc-nvim.user.language",
}) do
 local name=vim.fn.fnamemodify(modpath,":t:r")
 for _,locale in ipairs(Config.locale.fallbacks) do
  if name==locale.code then
   Util.try(
    function()
     local spec=Util.BufferCache.require(modname)
     Util.I18n.load(spec)
    end,
    Util.ERROR
   )
  end
 end
end

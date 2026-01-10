local N=require("hc-nvim.init_space")
---@class HC-Nvim.I18N
local I18N={}
function I18N.setup()
 --- Load default language pack
 for modname,modpath in N.Util.iter_mod({
  "hc-nvim.config.language",
  "hc-nvim.user.language",
 }) do
  local name=vim.fn.fnamemodify(modpath,":t:r")
  for _,locale in ipairs(N.Config.locale.fallbacks) do
   if name==locale.code then
    N.Util.try(
     function()
      local spec=N.Util.BufferCache.require(modname)
      assert(type(spec)=="table",("LanguagePack<%s> Expect table"):format(modname))
      N.Util.I18n.load(spec)
     end,
     N.Util.ERROR
    )
   end
  end
 end
end
return I18N

local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.I18N
local I18N={}
function I18N.setup()
 --- Load default language pack
 local i18n=HCNvim.Util.I18n.new()
 I18N.instance=i18n
 for modname,modpath in HCNvim.Util.iter_mod({
  "hc-nvim.config.language",
  "hc-nvim.user.language",
 }) do
  local name=vim.fn.fnamemodify(modpath,":t:r")
  for _,locale in ipairs(HCNvim.Config.locale.fallbacks) do
   if name==locale.code then
    HCNvim.Util.try(
     function()
      local spec=HCNvim.Util.BufferCache.require(modname)
      assert(type(spec)=="table",("LanguagePack<%s> Expect table"):format(modname))
      i18n:load(spec)
     end,
     HCNvim.Util.ERROR
    )
   end
  end
 end
end
if LUAFILE then
 package.loaded["hc-nvim.util.i18n"]=nil
 HCNvim.Util.I18n=require("hc-nvim.util.i18n")
 I18N.setup()
 print(I18N.instance:tbl_get({"buftype",vim.bo.buftype}))
end
return I18N

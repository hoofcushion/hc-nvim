local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.Basic
local Basic={}
function Basic.setup()
 for modname,modpath in HCNvim.Util.iter_mod({
  "hc-nvim.config.basic",
  "hc-nvim.user.basic",
 }) do
  HCNvim.Util.try(
   function()
    HCNvim.Util.path_require(modname,modpath)
   end,
   HCNvim.Util.ERROR
  )
 end
end
return Basic

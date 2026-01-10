local N=require("hc-nvim.init_space")
---@class HC-Nvim.Basic
local Basic={}
function Basic.setup()
 for modname,modpath in N.Util.iter_mod({
  "hc-nvim.config.basic",
  "hc-nvim.user.basic",
 }) do
  N.Util.try(
   function()
    N.Util.path_require(modname,modpath)
   end,
   N.Util.ERROR
  )
 end
end
return Basic

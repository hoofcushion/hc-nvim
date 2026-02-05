local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.Option
local Option={}
function Option.setup()
 for modname in HCNvim.Util.iter_mod({
  "hc-nvim.config.option",
  "hc-nvim.user.option",
 }) do
  HCNvim.Util.try(
   function()
    local options=HCNvim.Util.BufferCache.require(modname)
    assert(type(options)=="table",("Option<%s> must be a table."):format(modname))
    HCNvim.Util.Option.set(options)
   end,
   HCNvim.Util.ERROR
  )
 end
end
return Option

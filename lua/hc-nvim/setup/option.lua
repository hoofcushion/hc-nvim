local N=require("hc-nvim.init_space")
---@class HC-Nvim.Option
local Option={}
function Option.setup()
 for modname in N.Util.iter_mod({
  "hc-nvim.config.option",
  "hc-nvim.user.option",
 }) do
  N.Util.try(
   function()
    local options=N.Util.BufferCache.require(modname)
    assert(type(options)=="table",("Option<%s> must be a table."):format(modname))
    N.Util.Option.set(options)
   end,
   N.Util.ERROR
  )
 end
end
return Option

local N=require("hc-nvim.init_space")
-- return Specs
---@class HC-Nvim.Lazy
local Lazy={}
function Lazy.setup()
 ---HACK
 require("hc-nvim.setup.lazy.handler")
 require("hc-nvim.setup.lazy.orderload")
 table.insert(package.loaders,2,table.remove(package.loaders,3))
 local Specs={}
 for modname in N.Util.iter_mod({
  "hc-nvim.config.plugin",
  "hc-nvim.user.plugin",
 }) do
  N.Util.try(function()
   local spec=require(modname)
   table.insert(Specs,spec)
  end,N.Util.ERROR)
 end
 N.Util.try(function()
  local Presets=require("hc-nvim.setup.lazy.preset")
  Presets.apply(Specs)
 end,N.Util.ERROR)
 Lazy.Specs=Specs
end
return Lazy

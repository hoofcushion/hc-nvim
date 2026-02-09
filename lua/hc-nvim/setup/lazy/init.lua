local HCNvim=require("hc-nvim.init_space")
-- return Specs
---@class HC-Nvim.Lazy
local Lazy={}
Lazy.Specs={}
function Lazy.setup()
 require("hc-nvim.setup.lazy.handler")
 require("hc-nvim.setup.lazy.orderload")
 table.insert(package.loaders,2,table.remove(package.loaders,3))
 HCNvim.Util.track("specs")
 local Specs={}
 for modname in HCNvim.Util.iter_mod({
  "hc-nvim.config.plugin",
  "hc-nvim.user.plugin",
 }) do
  HCNvim.Util.try(function()
   local spec=require(modname)
   table.insert(Specs,spec)
  end,HCNvim.Util.ERROR)
 end
 HCNvim.Util.track()
 HCNvim.Util.try(function()
  HCNvim.Util.track("preset")
  local Presets=require("hc-nvim.setup.lazy.preset")
  Specs=Presets.apply(Specs)
  HCNvim.Util.track()
 end,HCNvim.Util.ERROR)
 Lazy.Specs=Specs
end
return Lazy

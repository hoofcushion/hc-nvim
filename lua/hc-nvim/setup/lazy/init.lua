local Util=require("hc-nvim.util")
---HACK
require("hc-nvim.setup.lazy.handler")
require("hc-nvim.setup.lazy.interload")
require("hc-nvim.setup.lazy.orderload")
table.insert(package.loaders,2,table.remove(package.loaders,3))
local Specs={}
for modname in Util.iter_mod({
 "hc-nvim.config.plugin",
 "hc-nvim.user.plugin",
}) do
 Util.try(function()
  local spec=require(modname)
  table.insert(Specs,spec)
 end,Util.ERROR)
end
local Presets=require("hc-nvim.setup.lazy.preset")
Presets.apply(Specs)
return Specs

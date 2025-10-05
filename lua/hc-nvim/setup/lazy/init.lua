local Util=require("hc-nvim.util")
require("hc-nvim.setup.lazy.handler")
require("hc-nvim.setup.lazy.interload")
require("hc-nvim.setup.lazy.orderload")
local Specs={}
for modname in Util.iter_mod({
 "hc-nvim.builtin.plugin",
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

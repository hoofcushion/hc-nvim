local Util=require("hc-nvim.util")
Util.track("rewrite")
require("hc-nvim.setup.lazy.handler")
require("hc-nvim.setup.lazy.interload")
require("hc-nvim.setup.lazy.orderload")
Util.track()
local Specs={}
for modname in Util.iter_mod({
 "hc-nvim.builtin.plugin",
 "hc-nvim.user.plugin",
}) do
 Util.track(modname)
 local spec=require(modname)
 if type(spec)=="table" then
  table.insert(Specs,spec)
 end
 Util.track()
end
Util.track("load presets")
local Presets=require("hc-nvim.setup.lazy.preset")
Presets.apply(Specs)
Util.track()
return Specs

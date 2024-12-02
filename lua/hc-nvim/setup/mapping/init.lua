local Util=require("hc-nvim.util")
local Interface=Util.Interface.new()
Util.track("mapping")
Util.track("interface")
Interface:extend(require("hc-nvim.setup.mapping.interface"))
Util.track()
for modname in Util.iter_mod({
 "hc-nvim.builtin.mapping",
 "hc-nvim.user.mapping",
}) do
 Util.track(modname)
 local mapping=require(modname)
 if mapping then
  Interface.forspecs(mapping,function(spec)
   Interface:add(spec):start()
  end)
 end
 Util.track()
end
Util.track()
return Interface

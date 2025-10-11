local Util=require("hc-nvim.util")
local Interface=Util.Interface.new()
Util.track("interface")
Util.try(
 function()
  local specs=Util.BufferCache.require("hc-nvim.builtin.interface")
  Interface:extend(specs)
 end,
 Util.ERROR
)
Util.track()
for modname,modpath in Util.iter_mod({
 "hc-nvim.builtin.mapping",
 "hc-nvim.user.mapping",
}) do
 Util.try(function()
           local mapping=Util.path_require(modname,modpath)
           if mapping then
            Interface.forspecs(mapping,function(spec)
             Interface:add(spec):create()
            end)
           end
          end,Util.ERROR)
end
return Interface

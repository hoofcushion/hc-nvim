local Util=require("hc-nvim.util")
local Interface=Util.Interface.new()
Util.track("interface")
Util.try(
 function()
  Interface:extend(require("hc-nvim.builtin.interface"))
 end,
 Util.ERROR
)
Util.track()
for modname in Util.iter_mod({
 "hc-nvim.builtin.mapping",
 "hc-nvim.user.mapping",
}) do
 Util.try(function()
           local mapping=require(modname)
           if mapping then
            Interface.forspecs(mapping,function(spec)
             Interface:add(spec):create()
            end)
           end
          end,Util.ERROR)
end
return Interface

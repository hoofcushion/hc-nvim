local N=require("hc-nvim.init_space")
local Mapping={}
function Mapping.setup()
 local Interface=N.Util.Interface.new()
 Mapping.Interface=Interface
 N.Util.track("interface")
 N.Util.try(
  function()
   local specs=N.Util.BufferCache.require("hc-nvim.config.interface")
   Interface:extend(specs)
  end,
  N.Util.ERROR
 )
 N.Util.track()
 for modname,modpath in N.Util.iter_mod({
  "hc-nvim.config.mapping",
  "hc-nvim.user.mapping",
 }) do
  N.Util.try(function()
   local mapping=N.Util.path_require(modname,modpath)
   if mapping then
    Interface.forspecs(mapping,function(spec)
     Interface:add(spec):create()
    end)
   end
  end,N.Util.ERROR)
 end
end
return Mapping

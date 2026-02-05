local HCNvim=require("hc-nvim.init_space")
local Mapping={}
function Mapping.setup()
 local Interface=HCNvim.Util.Interface.new()
 Mapping.Interface=Interface
 HCNvim.Util.track("interface")
 HCNvim.Util.try(
  function()
   local specs=HCNvim.Util.BufferCache.require("hc-nvim.config.interface")
   Interface:extend(specs)
  end,
  HCNvim.Util.ERROR
 )
 HCNvim.Util.track()
 for modname,modpath in HCNvim.Util.iter_mod({
  "hc-nvim.config.mapping",
  "hc-nvim.user.mapping",
 }) do
  HCNvim.Util.try(function()
   local mapping=HCNvim.Util.path_require(modname,modpath)
   if mapping then
    Interface.forspecs(mapping,function(spec)
     Interface:add(spec):create()
    end)
   end
  end,HCNvim.Util.ERROR)
 end
end
return Mapping

local Util=require("hc-nvim.util")
Util.track("interface")
local Interface=Util.Interface.new()
Interface:extend(require("hc-nvim.builtin.interface"))
Util.track()
vim.schedule(function()
 for modname in Util.iter_mod({
  "hc-nvim.builtin.mapping",
  "hc-nvim.user.mapping",
 }) do
  local mapping=require(modname)
  if mapping then
   Interface.forspecs(mapping,function(spec)
    Interface:add(spec):start()
   end)
  end
 end
end)
return Interface

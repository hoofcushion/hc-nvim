local Util=require("hc-nvim.util")
for modname in Util.iter_mod({
 "hc-nvim.builtin.option",
 "hc-nvim.user.option",
}) do
 Util.try(
  function()
   local options=Util.BufferCache.require(modname)
   Util.Option.set(options)
  end,
  Util.ERROR
 )
end

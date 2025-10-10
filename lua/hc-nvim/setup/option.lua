local Util=require("hc-nvim.util")
for modname in Util.iter_mod({
 "hc-nvim.builtin.option",
 "hc-nvim.user.option",
}) do
 Util.try(
  function()
   Util.Option.set(Util.BufferCache.require(modname))
  end,
  Util.ERROR
 )
end

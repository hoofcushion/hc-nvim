local Util=require("hc-nvim.util")
for modname in Util.iter_mod({
 "hc-nvim.builtin.basic",
 "hc-nvim.user.basic",
}) do
 Util.try(
  function()
   require(modname)
  end,
  Util.ERROR
 )
end

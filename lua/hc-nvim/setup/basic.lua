local Util=require("hc-nvim.util")
for modname,modpath in Util.iter_mod({
 "hc-nvim.config.basic",
 "hc-nvim.user.basic",
}) do
 Util.try(
  function()
   Util.path_require(modname,modpath)
  end,
  Util.ERROR
 )
end

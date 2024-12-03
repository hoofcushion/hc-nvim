local Util=require("hc-nvim.util")
for modname in Util.iter_mod({
 "hc-nvim.builtin.option",
 "hc-nvim.user.option",
}) do
 Util.Option.set(require(modname))
end

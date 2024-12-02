local Util=require("hc-nvim.util")
Util.track("option")
for modname in Util.iter_mod({
 "hc-nvim.builtin.option",
 "hc-nvim.user.option",
}) do
 Util.Option.set(require(modname))
end
Util.track()

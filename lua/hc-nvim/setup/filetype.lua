local Util=require("hc-nvim.util")
Util.track("filetype")
for modname in Util.iter_mod({
 "hc-nvim.builtin.filetype",
 "hc-nvim.user.filetype"
}) do
 require(modname)
end
Util.track()

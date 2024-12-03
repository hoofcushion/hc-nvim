local Util=require("hc-nvim.util")
for modname in Util.iter_mod({
 "hc-nvim.builtin.filetype",
 "hc-nvim.user.filetype"
}) do
 require(modname)
end

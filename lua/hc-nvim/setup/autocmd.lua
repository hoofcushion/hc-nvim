local Util=require("hc-nvim.util")
for modname in Util.iter_mod({
 "hc-nvim.builtin.autocmd",
 "hc-nvim.user.autocmd",
}) do
 require(modname)
end

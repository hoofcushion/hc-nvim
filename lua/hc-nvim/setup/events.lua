local Util=require("hc-nvim.util")
---@class Events
local M={}
for modname,modpath in Util.iter_mod({
 "hc-nvim.builtin.events",
 "hc-nvim.user.events",
}) do
 Util.try(
  function()
   local events=Util.path_require(modname,modpath)
   Util.tbl_extend(M,events)
  end,
  Util.ERROR
 )
end
return M

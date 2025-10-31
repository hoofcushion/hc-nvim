local Util=require("hc-nvim.util")
---@class Events
local M={}
for modname,modpath in Util.iter_mod({
 "hc-nvim.builtin.event",
 "hc-nvim.user.event",
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

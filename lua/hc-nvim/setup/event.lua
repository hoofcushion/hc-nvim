local N=require("hc-nvim.init_space")
---@class HC-Nvim.Event
local Event={}
function Event.setup()
 for modname,modpath in N.Util.iter_mod({
  "hc-nvim.config.event",
  "hc-nvim.user.event",
 }) do
  N.Util.try(
   function()
    local events=N.Util.path_require(modname,modpath)
    N.Util.tbl_extend(Event,events)
   end,
   N.Util.ERROR
  )
 end
end
return Event

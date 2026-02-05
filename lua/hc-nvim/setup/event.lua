local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.Event
local Event={}
function Event.setup()
 ---@class HC-Nvim.Events
 Event.Events={}
 for modname,modpath in HCNvim.Util.iter_mod({
  "hc-nvim.config.event",
  "hc-nvim.user.event",
 }) do
  HCNvim.Util.try(
   function()
    local events=HCNvim.Util.path_require(modname,modpath)
    HCNvim.Util.tbl_extend(Event.Events,events)
   end,
   HCNvim.Util.ERROR
  )
 end
end
return Event

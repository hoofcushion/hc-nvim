local Util=require("hc-func.util")
---@diagnostic disable: duplicate-set-field
---@class Timers
---@field timers table<integer,uv.uv_timer_t>
local Timer={
 timers ={},
 params ={},
}
function Timer:new_timer(timeout,repeat_,callback)
 local timer=Util.new_timer()
 table.insert(self.timers,timer)
 self.params[timer]={timeout=timeout,repeat_=repeat_,callback=callback}
 return timer
end
function Timer:start()
 for _,timer in ipairs(self.timers) do
  local p=self.params[timer]
  timer:start(p.timeout,p.repeat_,p.callback)
 end
end
function Timer:stop()
 for _,timer in ipairs(self.timers) do
  timer:stop()
 end
end
function Timer:fini()
 for _,timer in ipairs(self.timers) do
  timer:close()
 end
 self.timers={}
end
function Timer.new()
 local new=setmetatable({},{__index=Timer})
 new.timers={}
 return new
end
return Timer

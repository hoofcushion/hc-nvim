---@alias ConductedTimer.start_param {[1]:integer,[2]:integer,[3]:function}
---@class ConductedTimer
---@field timers table<integer,uv.uv_timer_t>
---@field params ConductedTimer.start_param[]
local ConductedTimer={
 timers={},
 params={},
}
-- get a conducted timer
function ConductedTimer:get()
 local timer=vim.uv.new_timer() or error()
 table.insert(self.timers,timer)
 return timer
end
function ConductedTimer:add(...)
 local timer=self:get()
 if (...) then
  self.params[timer]={...}
 end
end
function ConductedTimer:enable()
 for _,timer in ipairs(self.timers) do
  local param=self.params[timer]
  if param then
   timer:start(unpack(param,1,3))
  end
 end
end
function ConductedTimer:disable()
 for _,timer in ipairs(self.timers) do
  timer:stop()
 end
end
function ConductedTimer:fini()
 for _,timer in ipairs(self.timers) do
  timer:close()
 end
 self.timers={}
 self.params={}
end
function ConductedTimer.new()
 local obj=setmetatable({},{__index=ConductedTimer})
 obj:fini()
 return obj
end
return ConductedTimer

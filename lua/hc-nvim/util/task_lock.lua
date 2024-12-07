local Util=require("hc-nvim.util")
---@class TaskLock
local TaskLock={
 delay=0,
 done=true,
}
if false then
 TaskLock.timer=vim.uv.new_timer() or error()
end
---
--- bind multiple function (task), once one's called, it will block other task form running for a moment (delay).
---@param fn function
---@return function
function TaskLock:bind(fn)
 local timer=self.timer
 return function()
  if self.done and not timer:is_active() then
   self.done=false
   timer:start(self.delay,0,Util.empty_f)
   vim.schedule(function()
    fn()
    self.done=true
   end)
  end
 end
end
function TaskLock.new(delay)
 local obj=Util.Class.new(TaskLock)
 obj.delay=delay
 obj.timer=vim.uv.new_timer() or error("")
 return obj
end
return TaskLock

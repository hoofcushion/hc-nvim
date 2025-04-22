local Util=require("hc-nvim.util")
local TaskSequence={}
if false then
 TaskSequence.timer=vim.uv.new_timer() or error()
end
function TaskSequence.new()
 local obj=Util.Class.new(TaskSequence)
 obj.fns={}
 obj.timer=vim.uv.new_timer() or error("Failed to create timer")
 return obj
end
function TaskSequence:add(fn)
 table.insert(self.fns,fn)
 return self
end
function TaskSequence:extend(fns)
 Util.list_extend(self.fns,fns)
 return self
end
function TaskSequence:start(interval)
 if self.timer:is_active() then
  return
 end
 local fn=table.remove(self.fns,1)
 if fn==nil then
  self.timer:stop()
  return
 end
 self.timer:start(interval,0,vim.schedule_wrap(function()
  fn()
  self:start(interval)
 end))
 return self
end
function TaskSequence:stop()
 self.timer:stop()
 return self
end
return TaskSequence

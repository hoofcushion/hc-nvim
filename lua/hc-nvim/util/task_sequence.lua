local Util=require("hc-nvim.util")
local TaskSequence={}
function TaskSequence.new()
 local obj=Util.Class.new(TaskSequence)
 obj.fns={}
 obj.done=true
 obj.timer=vim.uv.new_timer() or error("Failed to create timer")
 return obj
end
function TaskSequence:add(fn)
 table.insert(self.fns,fn)
 return self
end
function TaskSequence:extend(fns)
 table.move(fns,1,#fns,#self.fns+1,self.fns)
 return self
end
function TaskSequence:start(interval)
 if self.done==false or #self.fns==0 then
  return
 end
 self.done=false
 self.timer:start(interval,0,vim.schedule_wrap(function()
  table.remove(self.fns,1)()
  self.done=true
  self:start(interval)
 end))
 return self
end
function TaskSequence:stop()
 self.timer:stop()
 self.done=true
 return self
end
return TaskSequence

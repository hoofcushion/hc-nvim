local Util=require("hc-nvim.util")
local Clock={}
function Clock.new(max_ms)
 local obj=Util.Class.new(Clock)
 obj:reset()
 obj.max_ms=max_ms
 return obj
end
function Clock:click()
 local cur=Util.clock()*1000
 self.cur_ms=math.min(self.init_ms+self.max_ms,cur)
end
function Clock:elapsed()
 return self.cur_ms-self.init_ms
end
function Clock:reset()
 local cur=Util.clock()*1000
 self.init_ms=cur
 self.cur_ms=cur
end
return Clock

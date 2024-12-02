local Util=require("hc-func.util")
local function empty() end
---@class FuncBind
local FuncBind={
 delay=0,
 done=true,
}
---
--- bind multiple function, when one's called, it will block others until it's done.
---@param fn function
---@return function
function FuncBind:bind(fn)
 local scheduled_fn=vim.schedule_wrap(function(...)
  fn(...)
  self.done=true
 end)
 if self.delay==0 then
  return function()
   if self.done then
    self.done=false
    scheduled_fn()
   end
  end
 end
 local timer=Util.new_timer()
 return function()
  if self.done and timer:is_active()==false then
   self.done=false
   timer:start(self.delay,0,empty)
   scheduled_fn()
  end
 end
end
function FuncBind.new(delay)
 local new=setmetatable({},{__index=FuncBind})
 new.delay=delay
 return new
end
return FuncBind

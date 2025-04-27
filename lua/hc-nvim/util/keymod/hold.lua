local Base=require("hc-nvim.util.keymod.base")
local function empty_f() end
local function cache(fn)
 local c={}
 return function(x,e,...)
  local fx=math.ceil(x/e/(1/50)) -- limit acceleration phrase
  local ret=c[fx]
  if ret==nil then
   ret=fn(x,e,...)
   c[fx]=ret
  end
  return ret
 end
end
---@class hold_opts
local default_opts={
 init_speed=50.0,
 max_speed=1000.0,
 trigger=2, -- key repeat threshold
 acceleration_ms=200, -- acceleration time to max_speed
 threshold_ms=100, -- key repeat timeout when active
 timeout_ms=200, -- key repeat timeout when inactive
 smooth=function(cur_time,end_time,init_speed,max_speed)
  local final=init_speed+(cur_time/end_time*(max_speed-init_speed))
  return final
 end,
}
local function new_timer()
 local timer,msg=vim.uv.new_timer()
 if timer==nil then error(msg) end
 return timer
end
local Clock=require("hc-nvim.util.clock")
local M={}
---@param lhs keymod.key
---@param rhs keymod.key
---@param opts? {}|hold_opts
function M.create(lhs,rhs,opts)
 opts=vim.tbl_deep_extend("force",default_opts,opts or {})
 local acceleration_ms=opts.acceleration_ms
 local max_interval_ms=1000/opts.max_speed
 local init_interval_ms=math.max(max_interval_ms,1000/opts.init_speed)
 local clock=Clock.new(acceleration_ms)
 --- ---
 --- Throttle for rhs
 --- ---
 if opts.init_speed>0 then
  local smooth=cache(opts.smooth)
  local timer=new_timer()
  rhs=Base.create(nil,rhs,function()
   if timer:is_active() then
    return false
   end
   local delay=smooth(clock:elapsed(),acceleration_ms,init_interval_ms,max_interval_ms)
   if delay>1 then
    timer:start(math.floor(delay),0,empty_f)
   end
   return true
  end)
 end
 --- ---
 --- Hold timer
 --- ---
 local timer=new_timer()
 local count=0
 local function cond()
  clock:click()
  count=count+1
  local fill=count>=opts.trigger
  local timeout=fill and opts.timeout_ms or opts.threshold_ms
  timer:start(timeout,0,function()
   clock:reset()
   count=0
  end)
  return fill
 end
 return Base.create(lhs,rhs,cond)
end
return M

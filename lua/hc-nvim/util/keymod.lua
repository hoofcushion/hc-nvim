local M={}
---
--- Module that deal with keymod wrapping.
--- Generic for string and function.
---@alias keymod.key nil|string|keymod.keyfn
---@alias keymod.keyfn (fun(...:any):string|nil)

---@return function
local function tokey_fn(any)
 return type(any)=="function"
  and any
  or (type(any)=="string" or any==nil)
  and function()
   return any or ""
  end
  or error("string or function expected, got: "..tostring(any))
end
local Base={}
M.Base=Base
---@param lhs keymod.key|nil
---@param rhs keymod.key|nil
function Base.concat(lhs,rhs)
 lhs=tokey_fn(lhs)
 rhs=tokey_fn(rhs)
 return function()
  return lhs()..rhs()
 end
end
---
--- Generic function combine for string and function
---@param lhs keymod.key|nil # A string, or function that could return string
---@param rhs keymod.key|nil # A string, or function that could return string
---@param cond fun():boolean # A function determine whether or not to return rhs instead of lhs
---@return keymod.keyfn ExprKey Could use in vim.keymap.set as rhs
function Base.create(lhs,rhs,cond)
 lhs=tokey_fn(lhs)
 rhs=tokey_fn(rhs)
 return function(...)
  if cond() then
   return rhs(...)
  else
   return lhs(...)
  end
 end
end
local InBlank={}
M.InBlank=InBlank
---@param lhs keymod.key
---@param rhs keymod.key
function InBlank.create(lhs,rhs)
 local continuous=false
 local function cond()
  local line=vim.api.nvim_get_current_line()
  local non_blank_start=string.find(line,"%S")
  if non_blank_start==nil then
   continuous=false
   return false
  end
  local pos_col=vim.api.nvim_win_get_cursor(0)[2]+1
  if pos_col>non_blank_start then
   continuous=false
   return false
  end
  if continuous then
   return true
  end
  continuous=true
  return false
 end
 return Base.create(lhs,rhs,cond)
end
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
 init_speed=25,
 max_speed=200,
 trigger=3,           -- key repeat threshold
 acceleration_ms=200, -- acceleration time to max_speed
 threshold_ms=100,    -- key repeat timeout when active
 timeout_ms=200,      -- key repeat timeout when inactive
 smooth=function(cur_time,end_time,init_speed,max_speed)
  return init_speed+(cur_time/end_time*(max_speed-init_speed))
 end,
}
local Clock=require("hc-nvim.util.clock")
local Hold={}
M.Hold=Hold
---@param lhs keymod.key
---@param rhs keymod.key
---@param opts? {}|hold_opts
function Hold.create(lhs,rhs,opts)
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
  local timer=assert(vim.uv.new_timer())
  rhs=Base.create(nil,rhs,function()
   if timer:is_active() then
    return false
   end
   local delay=smooth(clock:elapsed(),acceleration_ms,init_interval_ms,max_interval_ms)
   delay=math.floor(delay)
   if delay>=1 then
    timer:start(delay,0,empty_f)
   end
   return true
  end)
 end
 --- ---
 --- Hold timer
 --- ---
 local timer=assert(vim.uv.new_timer())
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

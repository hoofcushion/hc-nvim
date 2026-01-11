---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@param name string?
function Util.track(name)
 require("lazy.util").track(name)
end
---@return number seconds
function Util.clock()
 return vim.uv.hrtime()/1e9
end
---@generic F: function
---@param delay integer?
---@param fn F
---@return F
function Util.throttle(delay,fn)
 delay=math.max(delay or 0,0)
 local last=0
 return function(...)
  local now=vim.uv.hrtime()/1e6
  if now-last>=delay then
   last=now
   return fn(...)
  end
 end
end
---@generic F:function
---@param ms integer?          # delay in ms
---@param fn F                 # function to debounce
---@param timer uv.uv_timer_t? # pass a timer to bind multiple function in one debounce, and manage timer manually
---@return F
function Util.debounce(ms,fn,timer)
 ms=math.max(ms or 0,0)
 assert(type(fn)=="function","function expected")
 timer=timer or Util.new_gc_timer()
 return function(...)
  local args={n=select("#",...),...}
  timer:start(ms,0,function()
   fn(unpack(args,1,args.n))
  end)
 end
end
---@generic F:function
---@param ms_delay integer?          # delay in ms
---@param ms_landing integer?          # delay in ms
---@param fn F                 # function to debounce
---@param timer uv.uv_timer_t? # pass a timer to bind multiple function in one debounce, and manage timer manually
---@return F
function Util.landing(ms_delay,ms_landing,fn,timer)
 ms_delay=math.max(ms_delay or 0,0)
 ms_landing=math.max(ms_landing or 0,0)
 assert(type(fn)=="function","function expected")
 timer=timer or Util.new_gc_timer()
 return function(...)
  local n=select("#",...)
  local args={...}
  local function f()
   fn(unpack(args,1,n))
  end
  if timer:is_active() then
   timer:start(ms_landing,0,f)
   return
  end
  timer:start(ms_delay,0,f)
 end
end
function Util.callrate(interval_ms)
 local stats={}
 -- 生成ID的辅助函数
 local function gen_id()
  local info=debug.getinfo(3)
  return info.source..":"..info.currentline
 end

 -- 清理过期数据
 local function cleanup(window_ms)
  window_ms=window_ms or interval_ms
  local now=vim.uv.hrtime()/1e6
  for id,data in pairs(stats) do
   if now-data.t>window_ms then
    stats[id]=nil
   end
  end
 end

 -- 计数函数
 local function count(id)
  if not id then id=gen_id() end
  local now=vim.uv.hrtime()/1e6
  stats[id]=stats[id] or {c=0,t=now}
  stats[id].c=stats[id].c+1
  stats[id].t=now
  return stats[id].c
 end

 -- 获取统计数据
 local function get(window_ms)
  cleanup(window_ms or interval_ms)
  local result={}
  for id,data in pairs(stats) do
   result[id]=data.c
  end
  return result
 end

 return {
  count=count,
  get=get,
 }
end
local function replace_self(real,fn)
 return function(_,...)
  return fn(real,...)
 end
end
--- create a uv timer that binds to lua gc system
--- it's expensive than bare one do not create too much of them
---@return uv.uv_timer_t
function Util.new_gc_timer()
 local timer=assert(vim.uv.new_timer())
 local ud=newproxy(true) --[[@as uv.uv_timer_t]]
 local to_close=false
 getmetatable(ud).__gc=function()
  to_close=true
  if not timer:is_active() and not timer:is_closing() then
   -- print("closed")
   timer:close()
  end
 end
 local hook={
  start=function(_,timeout,_repeat,callback)
   return timer:start(timeout,_repeat,function()
    if to_close and not timer:is_closing() then
     -- print("closed")
     timer:close()
    end
    callback()
   end)
  end,
  stop=function()
   -- force clear last callback when stop
   timer:start(0,0,function() end)
   timer:stop()
  end,
 }
 local cached={}
 getmetatable(ud).__index=function(_,k)
  local ret=cached[k]
  if not ret then
   ret=hook[k] or timer[k]
   ret=replace_self(timer,ret)
   cached[k]=ret
  end
  return ret
 end
 return ud
end
---@generic T
---@param init fun():T
---@param set? fun(t:T)
---@return T
function Util.lazy(init,set)
 set=set or Util.empty_f
 local lazyt=setmetatable({},{
  __index=function(_,k)
   local t=init()
   set(t)
   return t[k]
  end,
 })
 set(lazyt)
 return lazyt
end
local function _f() end
local function step(t,i,e,d,f,c)
 if i>e then
  t:close()
  pcall((c or _f))
  return
 end
 local ok,err=xpcall((f or _f),debug.traceback,i)
 if not ok then
  t:close()
  print(err)
 end
 t:start(d,0,function()
  step(t,i+1,e,d,f,c)
 end)
end
function Util.step(i,e,d,f,c)
 step(assert(vim.uv.new_timer()),i,e,d,f,c)
end
function Util.speed_test(time,fn,offset)
 local function empty() end
 -- calc offset of loop and empty function call
 local offset=vim.uv.hrtime()
 for _=1,time do
  empty()
 end
 offset=vim.uv.hrtime()-offset
 local usage=vim.uv.hrtime()
 for _=1,time do
  fn()
 end
 usage=vim.uv.hrtime()-usage-offset
 return {
  ns=usage,
  ms=usage/1e6,
  sec=usage/1e9,
  avg=usage/1e9/time,
 }
end

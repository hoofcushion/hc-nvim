---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
local async_infos=setmetatable({},{__mode="k"})
---@alias job async fun(resume:function):...?

---@param level integer
---@param ok boolean
---@param err? any
---@return boolean
local function assert2(level,ok,err)
 if not ok then
  error(err,level+1)
 end
 return true
end

---@param block function
---@return nil
function Util.async(block)
 local co=coroutine.create(block)
 async_infos[co]=true
 assert2(2,coroutine.resume(co))
end
---@generic T
---@param job async fun(resume: fun(T): any): any
---@return T
function Util.await(job)
 local co=coroutine.running()
 assert2(2,async_infos[co],"Not in a async block")
 local function resume(...)
  local fast=vim.in_fast_event()
  if fast then
   local n=select("#",...)
   local args={...}
   Util.schedule(function()
    assert2(2,coroutine.resume(co,unpack(args,1,n)))
   end)
  else
   assert2(2,coroutine.resume(co,...))
  end
 end
 if vim.in_fast_event() then
  Util.schedule(function()
   assert2(2,pcall(job,resume))
  end)
 else
  assert2(2,pcall(job,resume))
 end
 return coroutine.yield()
end
local function empty() end
--- `delay` 毫秒后，调用 `fn`
---@param fn function
---@param delay? integer
---@return nil
function Util.schedule(fn,delay)
 fn=fn or empty
 if delay==nil or delay==0 then
  vim.schedule(fn)
 else
  local timer
  timer=assert(vim.uv.new_timer())
  timer:start(delay,0,function()
   timer:close()
   timer=nil
   vim.schedule(fn)
  end)
 end
end
--- 返回一个新的函数，当调用他时：
--- `delay` 毫秒后，调用 `fn`
---@generic T
---@param fn function
---@param delay? integer
---@return T
---@nodiscard
function Util.schedule_wrap(fn,delay)
 if delay==nil then
  return fn
 else
  return function(...)
   local n=select("#",...)
   local args={...}
   Util.schedule(function() fn(unpack(args,1,n)) end,delay)
  end
 end
end
---@async
---@generic T
---@param env any                在工作线程中作为参数传递给 `func`
---@param func fun(env: any): T? 在工作线程中执行函数 `func(env)`
---@return T
function Util.await_work(env,func)
 return Util.await(function(resume)
  vim.uv.new_work(func,resume):queue(env)
 end)
end
---@async
---@param filename string 在工作线程中读取文件
---@return string?
---@nodiscard
function Util.work_readfile(filename)
 return Util.await_work(filename,function(_filename)
  local uv=vim.uv
  local function close() end
  local fd=uv.fs_open(_filename,"r",438)
  if not fd then return end
  local stat=uv.fs_fstat(fd)
  if not stat then return end
  close=function() uv.fs_close(fd) end
  local data=uv.fs_read(fd,stat.size,0)
  if not data then return end
  close()
  return data
 end)
end
---@async
---@param fn function?   如果指定，线程恢复时将从 `fn` 中拉取资源
---@param delay integer? 如果指定，将让出线程 `delay` 毫秒，再在下一个主线程循环中恢复
function Util.await_schedule(fn,delay)
 if fn==nil then
  return Util.await(function(resume)
   Util.schedule(resume,delay)
  end)
 end
 return Util.await(function(resume)
  Util.schedule(function() resume(fn) end,delay)
 end)
end

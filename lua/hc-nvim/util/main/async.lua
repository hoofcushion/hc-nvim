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

--- 执行一个异步块
---@param block function
---@return nil
function Util.async(block)
 local co=coroutine.create(block)
 async_infos[co]=true
 assert2(2,coroutine.resume(co))
end
--- 等待一个异步任务完成
---@generic T
---@param job async fun(resume: fun(T): any): any
---@return T
function Util.await(job)
 local co=coroutine.running()
 assert2(2,async_infos[co],"Not in a async block")
 local function resume(...)
  Util.try_in_main(function(...)
   if coroutine.status(co)=="suspended" then
    assert2(2,coroutine.resume(co,...))
   end
  end,...)
 end
 Util.try_in_main(function()
  assert2(2,pcall(job,resume))
 end)
 return coroutine.yield()
end
--- 调用 `fn`，并确保在非事件循环中间状态下执行
function Util.try_in_main(fn,...)
 if vim.in_fast_event() then
  local n=select("#",...)
  local args={...}
  Util.schedule(function()
   fn(unpack(args,1,n))
  end)
 else
  fn(...)
 end
end
local function empty() end

--- 延迟执行函数
--- `delay` 毫秒后，调用 `fn`
--- *当带 `delay` 参数调用时，会创建一个定时器，造成额外的性能开销
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
--- 返回一个延迟执行的函数包装器
--- 当调用返回的函数时，会在 `delay` 毫秒后调用原函数 `fn`
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
local schedule_register={}
--- 注册一次性延迟执行函数
--- 以 `id` 注册一个 `fn`
--- * 一个事件循环内多次注册，将覆盖原先的 `fn`
--- `delay` 毫秒后，调用 `id` 最终对应的 `fn`
--- * 多次注册，delay 的延迟不会改变
---@param id any
---@param fn function
---@param delay? integer
function Util.schedule_once(id,fn,delay)
 -- 如果 id 暂未被被注册，则发起一次 schedule
 if not schedule_register[id] then
  Util.schedule(function()
   -- _fn 最终会指向最后一次被注册的 fn
   local _fn=schedule_register[id]
   schedule_register[id]=nil
   local ok,err=pcall(_fn)
   if not ok then
    error(err)
   end
  end,delay)
 end
 -- 注册 fn
 schedule_register[id]=fn
end
--- 在一个异步块中发起一次工作线程调用，并等待执行完成
--- `env`: 在工作线程调用时传递给 `func` 的参数
--- `func`: 在工作线程调用时执行的函数
---@async
---@generic T
---@param env any
---@param func fun(env: any): T?
---@return T
function Util.await_work(env,func)
 return Util.await(function(resume)
  vim.uv.new_work(func,resume):queue(env)
 end)
end
--- 在一个异步块中发起一次工作线程调用，并读取文件
--- 如果读取失败，将返回 nil
--- `filename`: 将要读取的文件所在路径
---@async
---@param filename string
---@return string?
---@nodiscard
function Util.work_readfile(filename)
 return Util.await_work(filename,function(_filename)
  local uv=vim.uv
  local function close() end
  local fd=uv.fs_open(_filename,"r",438)
  if not fd then
   return
  end
  local stat=uv.fs_fstat(fd)
  if not stat then
   return
  end
  close=function() uv.fs_close(fd) end
  local data=uv.fs_read(fd,stat.size,0)
  if not data then
   return
  end
  close()
  return data
 end)
end
--- 在一个异步块中调用，让出线程 `delay` 秒，恢复时从 `fn` 拉取返回值
--- `fn`: 如果指定，线程恢复时将从 `fn` 中拉取资源
--- `delay`: 如果指定，将让出线程 `delay` 毫秒，再在下一个主线程循环中恢复
---@async
---@param fn? function
---@param delay? integer
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

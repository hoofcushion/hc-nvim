---@class hc_nvim.util
Util=require("hc-nvim.util.init_space")
local async_infos=setmetatable({},{__mode="k"})
---@param block function
function Util.async(block)
 local co=coroutine.create(block)
 async_infos[co]=true
 local ok,err=coroutine.resume(co)
 if not ok then
  error(err,0)
 end
 return ok
end
---@alias job async fun(resume:function):...?

---@param job job
function Util.await(job)
 local co=coroutine.running()
 if not async_infos[co] then
  error("await must be called in async block",2)
 end
 local result
 local function resume(...)
  if not result then
   result=Util.packlen(...)
   coroutine.resume(co,...)
  end
 end
 local ok,err=pcall(function()
  job(resume)
 end)
 if not ok then
  error(err,2)
 end
 if not result then
  coroutine.yield()
 end
 return Util.unpacklen(result)
end
function Util.await_work(env,job)
 return Util.await(function(resume)
  vim.uv.new_work(job,resume):queue(env)
 end)
end

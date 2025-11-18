---@class hc_nvim.util
Util=require("hc-nvim.util.init_space")
function Util.async(func)
 local co=coroutine.create(func)
 coroutine.resume(co)
end
function Util.await(func)
 local co=coroutine.running()
 if not co then
  error()
 end
 local function resume(...)
  coroutine.resume(co,...)
 end
 func(resume)
 return coroutine.yield()
end
function Util.await_work(env,job)
 return Util.await(function(resume)
  vim.uv.new_work(job,resume):queue(env)
 end)
end

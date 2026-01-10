---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
local async_infos=setmetatable({},{__mode="k"})
---@alias job async fun(resume:function):...?
local function assert2(level,ok,err)
 if not ok then
  error(err,level+1)
 end
end
---@param block function
function Util.async(block)
 local co=coroutine.create(block)
 async_infos[co]=true
 assert2(2,coroutine.resume(co))
end
function Util.await(job)
 local co=coroutine.running()
 assert2(2,async_infos[co],"Not in a async block")
 local function resume(...)
  assert2(2,coroutine.resume(co,...))
 end
 assert2(2,pcall(job,resume))
 return coroutine.yield()
end
function Util.await_work(env,job)
 return Util.await(function(resume)
  vim.uv.new_work(job,resume):queue(env)
 end)
end
---@nodiscard
---@param filename string
---@return string
function Util.await_readfile(filename)
 local fs_close
 local function uv_assert(err,...)
  if err then error(err,3) end
  return ...
 end
 local ok,data=pcall(function()
  local fd=uv_assert(Util.await(function(resume) vim.uv.fs_open(filename,"r",438,resume) end))
  fs_close=function() vim.uv.fs_close(fd) end
  local stat=uv_assert(Util.await(function(resume) vim.uv.fs_stat(filename,resume) end))
  local data=uv_assert(Util.await(function(resume) vim.uv.fs_read(fd,stat.size,0,resume) end))
  return data
 end)
 if fs_close then fs_close() end
 if not ok then
  error(data,2)
 end
 return data
end

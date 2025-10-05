---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@param name string?
function Util.track(name)
 require("lazy.util").track(name)
end
--- PERF:
--- Update value of function when specific event happens
--- Greatly improve lualine speed.
---@generic F
---@param opts {
--- event:vim.api.keyset.events|vim.api.keyset.events[],
--- filter:(fun(data):boolean),
--- func:F,
--- pattern:string?,
---}
---@return F
function Util.when(opts)
 local needupdate=true
 local cache={}
 vim.api.nvim_create_autocmd(opts.event,{
  pattern=opts.pattern,
  callback=function(data)
   if opts.filter==nil or opts.filter(data) then
    needupdate=true
   end
  end,
 })
 return function()
  if needupdate then
   needupdate=false
   cache={}
   return Util.redirect(cache,opts.func())
  end
  return Util.unpacklen(cache)
 end
end
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
---@param delay integer?
---@param fn F
---@return F
function Util.debounce(delay,fn)
 local timer=assert(vim.uv.new_timer())
 delay=math.max(delay or 0,0)
 return function()
  timer:stop()
  timer:start(delay,0,function()
   fn()
  end)
 end
end
local queue={}
---@param id any
---@param time integer
---@param fn function
function Util.debounce_with_id(id,time,fn)
 if not queue[id] then
  queue[id]=Util.debounce(time,function()
   Util.try(fn,Util.ERROR)
   queue[id]=nil
  end)
 end
 queue[id]()
end
---@generic T
---@param init fun():T
---@return T
function Util.lazy(init)
 return setmetatable({},{
  __index=function(_,k)
   return init()[k]
  end,
 })
end

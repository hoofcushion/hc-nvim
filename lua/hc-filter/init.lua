---@class HC-Filter
local M=require("hc-filter.init_space")
---@generic T
---@param init fun():T
---@param set? fun(t:T)
---@return T
function M.lazy(init,set)
 set=set or function() end
 local l=setmetatable({},{
  __index=function(_,k)
   local t=init()
   set(t)
   return t[k]
  end,
 })
 set(l)
 return l
end
M.lazy(function() return require("hc-filter.color_filter") end, function(t) M.ColorFilter=t end)
M.lazy(function() return require("hc-filter.color_format") end, function(t) M.ColorFormat=t end)
M.lazy(function() return require("hc-filter.neovim_filter") end,function(t) M.NeovimFilter=t end)
M.lazy(function() return require("hc-filter.rgb_format") end,   function(t) M.RGBFormat=t end)
function M.random_filter(factor)
 M.NeovimFilter.apply_to_all(function(r,g,b)
  local rgb={r,g,b}
  local rng={unpack(rgb)}
  rng[1]=rng[1]*(1+(math.random(2)==1 and 1 or -1)*((1-math.random())*factor*3*0.2126))
  rng[2]=rng[2]*(1+(math.random(2)==1 and 1 or -1)*((1-math.random())*factor*3*0.7152))
  rng[3]=rng[3]*(1+(math.random(2)==1 and 1 or -1)*((1-math.random())*factor*3*0.0722))
  return unpack(M.RGBFormat.rgb_to_normalize(rng))
 end,{fg=true,bg=true})
end
function M.setup(opts)
 opts=opts or {}
 local factor=opts.random_factor or (1/10)
 if vim.v.vim_did_enter then
  M.random_filter(factor)
 else
  vim.api.nvim_create_autocmd("VimEnter",{
   callback=function()
    M.random_filter(factor)
   end,
  })
  vim.api.nvim_create_autocmd("ColorScheme",{
   callback=function()
    M.random_filter(factor)
   end,
  })
 end
end
-- local function _step(i,e,delay,func,fini)
--  if i>e then
--   if fini then fini() end
--   return
--  end
--  vim.defer_fn(function()
--   func()
--   _step(i+1,e,delay,func,fini)
--  end,delay)
-- end
-- local function step(i,e,delay,func,fini)
--  assert(type(i)=="number")
--  assert(type(e)=="number")
--  assert(type(delay)=="number")
--  assert(type(func)=="function")
--  assert(fini==nil or type(fini)=="function")
--  _step(i+1,e,delay,func,fini)
-- end
-- _step(1,10,1000,function()
--  random_filter(1/8)
-- end,function()
--  print("done")
-- end)
return M

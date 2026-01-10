---@class HC-Func
local M=require("hc-func.init_space")
---@generic T
---@param init fun():T
---@param set? fun(t:T)
---@return T
function M.lazy(init,set)
 set=set or function() end
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
M.lazy(function() return require("hc-func.config") end,  function(t) M.Config=t end)
M.lazy(function() return require("hc-func.function") end,function(t) M.Function=t end)
function M.fini()
 M.Config.fini()
 M.Function.fini()
end
function M.setup(opts)
 M.Module=require("hc-func.module")
 M.Config.setup(opts)
 M.Function.setup()
end
return M

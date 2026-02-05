---@class HC-Func
local HCFunc=require("hc-func.init_space")
---@generic T
---@param init fun():T
---@param set? fun(t:T)
---@return T
function HCFunc.lazy(init,set)
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
HCFunc.lazy(function() return require("hc-func.config") end,  function(t) HCFunc.Config=t end)
HCFunc.lazy(function() return require("hc-func.function") end,function(t) HCFunc.Function=t end)
HCFunc.Module=require("hc-func.module")
function HCFunc.fini()
 HCFunc.Config.fini()
 HCFunc.Function.fini()
end
function HCFunc.setup(opts)
 HCFunc.Config.setup(opts)
 HCFunc.Function.setup()
end
return HCFunc

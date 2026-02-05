---@class HC-Nvim
local HCNvim=require("hc-nvim.init_space")
---@generic T
---@param init fun():T
---@param set? fun(t:T)
---@return T
function HCNvim.lazy(init,set)
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
HCNvim.lazy(function() return require("hc-nvim.config") end,function(t) HCNvim.Config=t end)
HCNvim.lazy(function() return require("hc-nvim.util") end,  function(t) HCNvim.Util=t end)
HCNvim.lazy(function() return require("hc-nvim.setup") end, function(t) HCNvim.Setup=t end)
function HCNvim.setup()
 HCNvim.Setup.setup()
end
return HCNvim

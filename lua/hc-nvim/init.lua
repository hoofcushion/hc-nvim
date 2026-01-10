---@class HC-Nvim
local M=require("hc-nvim.init_space")
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
M.lazy(function() return require("hc-nvim.config") end,function(t) M.Config=t end)
M.lazy(function() return require("hc-nvim.util") end,  function(t) M.Util=t end)
M.lazy(function() return require("hc-nvim.setup") end, function(t) M.Setup=t end)
function M.setup()
 HCNvim=M
 M.Setup.setup()
end
function M.export()
 return M.Setup.Lazy.Specs
end
return M

--- ---
--- A Table that always return the index when indexing.
--- ---
---@type {[string]:string}}
local M=setmetatable({},{
 __index=function(t,k)
  t[k]=k
  return k
 end,
})
NS=M
return M

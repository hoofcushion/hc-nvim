--- ---
--- A Table that always return the index when indexing.
--- Useful for lua language server to find string reference.
--- ---
local M=setmetatable({},{
 __index=function(t,k)
  t[k]=k
  return k
 end,
})
return M

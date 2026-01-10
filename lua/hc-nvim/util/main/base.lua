---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@generic T
---@param _ T
---@return T
function Util.lua_ls_alias(_,obj)
 return obj
end
local function as_T(...) return ... end
---@generic T
---@param t T
---@return fun(v:T):T
function Util.from(t)
 return as_T
end
function Util.packlen(...)
 return {n=select("#",...),...}
end
---@param t table
---@param s integer?
function Util.unpacklen(t,s)
 return Util.unpack(t,s or 1,t.n)
end
Util.unpack=unpack or table.unpack
---@generic T
---@param t table|fun():table
---@param ... T
---@return T
function Util.redirect(t,...)
 t=Util.eval(t)
 local n=select("#",...)
 for i=1,n do
  t[i]=select(i,...)
 end
 t.n=n
 return ...
end
function Util.empty_f() end
Util.empty_t=setmetatable({},{__index=Util.empty_f,__newindex=Util.empty_f})
function Util.batch(fn,...)
 for i=1,select("#",...) do
  local ret=fn(select(i,...))
  if ret then return ret end
 end
end
--- A Table that always return the index when indexing.
--- Useful for lua language server to find string reference.
Util.namespace=setmetatable({},{
 __index=function(t,k)
  t[k]=k
  return k
 end,
})

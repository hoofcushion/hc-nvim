---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@generic T
---@param _ T
---@return T
function Util.lua_ls_alias(_,obj)
 return obj
end
function Util.packlen(...)
 return {n=select("#",...),...}
end
function Util.unpacklen(t)
 return Util.unpack(t,1,t.n)
end
function Util.pack_result(ok,...) return ok,Util.packlen(...) end
function Util.pack_pcall(...)
 return Util.pack_result(pcall(...))
end
function Util.ok_or_nil(ok,...)
 if ok then
  return ...
 end
end
function Util.nilpcall(...)
 return Util.ok_or_nil(pcall(...))
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
Util.prequire=Util.lua_ls_alias(require,function(modname)
 return Util.nilpcall(require,modname)
end)
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

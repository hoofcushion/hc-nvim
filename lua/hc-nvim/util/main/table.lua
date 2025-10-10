---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@generic T:table
---@param tbl T
---@param fn function
function Util.pt(tbl,fn)
 local _={}
 _.record={}
 _.mt={
  __index=function(t,k)
   local v=rawget(t,k)
   if v~=nil then
    return v
   end
   local n={}
   rawset(t,k,n)
   return _.set(n)
  end,
 }
 function _.set(t)
  _.record[t]=getmetatable(t) or false
  setmetatable(t,_.mt)
  return t
 end
 function _.rec()
  for t,mt in pairs(_.record) do
   setmetatable(t,mt or nil)
  end
 end
 _.set(tbl)
 local ok,msg=pcall(fn)
 _.rec()
 if not ok then
  error(msg)
 end
end
---@param tbl table
---@param keys any[]|string
function Util.tbl_get(tbl,keys)
 if type(keys)=="string" then
  keys=vim.split(keys,".",{plain=true,trimempty=true})
 end
 local e=#keys
 for i=1,e-1 do
  tbl=Util.tbl_check(tbl,keys[i])
 end
 local k=keys[e]
 if k then
  return tbl[keys[e]]
 end
 return tbl
end
---@param tbl table
---@param keys any[]|string
---@param val any
function Util.tbl_set(tbl,keys,val)
 if type(keys)=="string" then
  keys=vim.split(keys,".",{plain=true,trimempty=true})
 end
 local e=#keys
 for i=1,e-1 do
  tbl=Util.tbl_check(tbl,keys[i])
 end
 tbl[keys[e]]=val
 return tbl
end
--- Check field exists
--- Put expr to initialize if it not exist.
--- If expr not provided, a empty table is used as fallback.
---@overload fun(t,k):table
---@generic T:table
---@generic K
---@generic V
---@param t T
---@param k K
---@param e fun(T,K):V
---@return V
function Util.tbl_check(t,k,e)
 local ret=t[k]
 if ret==nil then
  ret=e==nil and {} or e(t,k)
  t[k]=ret
 end
 return ret
end
--- Clear a table.
if jit then
 local _tbl_clear=require("table.clear")
 function Util.tbl_clear(tbl)
  _tbl_clear(tbl)
  setmetatable(tbl,nil)
  return tbl
 end
else
 function Util.tbl_clear(tbl)
  for k in pairs(tbl) do
   tbl[k]=nil
  end
  setmetatable(tbl,nil)
  return tbl
 end
end
---@generic T
---@param dst T
---@param ... T
---@return T
function Util.tbl_extend(dst,...)
 for i=1,select("#",...) do
  local t=select(i,...)
  if type(t)=="table" then
   for k,v in pairs(t) do
    dst[k]=v
   end
  end
 end
 return dst
end
---@generic T
---@param dst T
---@param ... T
---@return T
function Util.tbl_deep_extend(dst,...)
 for i=1,select("#",...) do
  local t=select(i,...)
  if type(t)=="table" then
   for k,v in pairs(t) do
    local orig=dst[k]
    if type(orig)=="table" and type(v)=="table" then
     if Util.is_list(orig) and Util.is_list(v) then
      dst[k]=Util.list_extend({},orig,v)
     else
      dst[k]=Util.tbl_deep_extend({},orig,v)
     end
    else
     dst[k]=v
    end
   end
  end
 end
 return dst
end
---@generic T
---@param dst T[]
---@param ... T[]
---@return T[]
function Util.list_extend(dst,...)
 for i=1,select("#",...) do
  local t=select(i,...)
  if type(t)=="table" and next(t)~=nil then
   for _,v in ipairs(t) do
    table.insert(dst,v)
   end
  end
 end
 return dst
end
---@generic T
---@param lst T[]
---@return T[]
function Util.list_unique(lst)
 local seen={}
 local ret={}
 for _,v in ipairs(lst) do
  if not seen[v] then
   table.insert(ret,v)
   seen[v]=true
  end
 end
 return lst
end
---@generic T
---@param dst T[]
---@param ... T[]
---@return T[]
function Util.list_flatten(dst,...)
 for i=1,select("#",...) do
  local t=select(i,...)
  for _,v in ipairs(t) do
   if type(v)=="table" then
    Util.list_flatten(dst,v)
   else
    table.insert(dst,v)
   end
  end
 end
 return dst
end
do
 local function _deepcopy(orig)
  if type(orig)~="table" then
   return orig
  end
  local ret={}
  for k,v in pairs(orig) do
   ret[_deepcopy(k)]=_deepcopy(v)
  end
  local mt=getmetatable(orig)
  if mt~=nil then
   setmetatable(ret,_deepcopy(mt))
  end
  return ret
 end
 ---@generic T
 ---@param orig T
 ---@return T
 function Util.deepcopy(orig)
  return _deepcopy(orig)
 end
end
---@generic T
---@param orig T
---@return T
function Util.copy(orig)
 if type(orig)~="table" then
  return orig
 end
 local ret={}
 for k,v in pairs(orig) do
  ret[k]=v
 end
 local mt=getmetatable(orig)
 if mt~=nil then
  setmetatable(ret,mt)
 end
 return ret
end
function Util.get_super(tbl)
 local mt=getmetatable(tbl)
 return mt and type(mt.__index)=="table" and mt.__index or nil
end
local function deepset(s)
 if type(s.t)=="function" then
  error("table __index expected")
 end
 if rawget(s.t,s.k)==s.orig then
  rawset(s.t,s.k,s.v)
  return
 end
 s.t=Util.get_super(s.t)
 deepset(s)
end
--- deepset key value at exact matched super table
---@param tbl table
---@param key any
---@param val any
function Util.deepset(tbl,key,val)
 deepset({orig=tbl[key],t=tbl,k=key,v=val})
end
function Util.override(p,t)
 for _,v in ipairs(t) do
  if type(v)=="table" then
   if v[1]~=nil then
    Util.override(p,v)
   else
    Util.tbl_deep_extend(v,p)
   end
  end
 end
 return t
end
---@param raws table|table[]
---@param ret table
local function parse_override(ret,raws)
 if raws[1]~=nil then
  for _,raw in ipairs(raws) do
   if raws.override then
    raw.override=raw.override and Util.tbl_deep_extend(raw.override,raws.override) or raws.override
   end
   parse_override(ret,raw)
  end
 else
  if raws.override then
   Util.tbl_deep_extend(raws,raws.override)
  end
  table.insert(ret,raws)
 end
 return ret
end
---@param raws table|table[]
function Util.parse_override(raws)
 return parse_override({},raws)
end

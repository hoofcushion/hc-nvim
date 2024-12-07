--- Lazy load each util prevent loop require
local Util=require("hc-nvim.util.lazy_tab").create({
 Autocmd     ="hc-nvim.util.autocmd",
 BufferCache ="hc-nvim.util.buffercache",
 Cache       ="hc-nvim.util.cache",
 Class       ="hc-nvim.util.class",
 Clock       ="hc-nvim.util.clock",
 Event       ="hc-nvim.util.event",
 Fallback    ="hc-nvim.util.fallback",
 HLGroup     ="hc-nvim.util.hl_group",
 Highlight     ="hc-nvim.util.highlight",
 I18n        ="hc-nvim.util.i18n",
 Interface   ="hc-nvim.util.interface",
 KeyRecorder ="hc-nvim.util.key_recorder",
 Keymod      ="hc-nvim.util.keymod",
 Lazy        ="hc-nvim.util.lazy",
 LazyTab     ="hc-nvim.util.lazy_tab",
 LocalEnv    ="hc-nvim.util.local_env",
 ModTree     ="hc-nvim.util.mod_tree",
 Option      ="hc-nvim.util.option",
 RangeMark   ="hc-nvim.util.range_mark",
 Reference   ="hc-nvim.util.reference",
 Register    ="hc-nvim.util.register",
 TaskLock    ="hc-nvim.util.task_lock",
 TaskSequence="hc-nvim.util.task_sequence",
 TimeUsed    ="hc-nvim.util.time_used",
 Timer       ="hc-nvim.util.timer",
 UniqueList  ="hc-nvim.util.unique_list",
 Wrapper     ="hc-nvim.util.wrapper",
})
if false then
 Util={
  Autocmd     =require("hc-nvim.util.autocmd"),
  BufferCache =require("hc-nvim.util.buffercache"),
  Cache       =require("hc-nvim.util.cache"),
  Class       =require("hc-nvim.util.class"),
  Clock       =require("hc-nvim.util.clock"),
  Event       =require("hc-nvim.util.event"),
  Fallback    =require("hc-nvim.util.fallback"),
  HLGroup     =require("hc-nvim.util.hl_group"),
 Highlight     =require("hc-nvim.util.highlight"),
  I18n        =require("hc-nvim.util.i18n"),
  Interface   =require("hc-nvim.util.interface"),
  KeyRecorder =require("hc-nvim.util.key_recorder"),
  Keymod      =require("hc-nvim.util.keymod"),
  Lazy        =require("hc-nvim.util.lazy"),
  LazyTab     =require("hc-nvim.util.lazy_tab"),
  LocalEnv    =require("hc-nvim.util.local_env"),
  ModTree     =require("hc-nvim.util.mod_tree"),
  Option      =require("hc-nvim.util.option"),
  RangeMark   =require("hc-nvim.util.range_mark"),
  Reference   =require("hc-nvim.util.reference"),
  Register    =require("hc-nvim.util.register"),
  TaskLock    =require("hc-nvim.util.task_lock"),
  TaskSequence=require("hc-nvim.util.task_sequence"),
  TimeUsed    =require("hc-nvim.util.time_used"),
  Timer       =require("hc-nvim.util.timer"),
  UniqueList  =require("hc-nvim.util.unique_list"),
  Wrapper     =require("hc-nvim.util.wrapper"),
 }
end
---@alias nonil
---| boolean
---| number
---| integer
---| thread
---| table
---| string
---| userdata
---| lightuserdata
---| function

--- ---
--- Meta
--- ---
---@generic T
---@param _ T
---@return T
function Util.lua_ls_rename(obj,_)
 return obj
end
--- ---
--- Pack
--- ---
function Util.packlen(...)
 return {n=select("#",...),...}
end
function Util.unpacklen(t)
 return unpack(t,1,t.n)
end
local function prequire(modname)
 return vim.F.ok_or_nil(pcall(require,modname))
end
Util.prequire=Util.lua_ls_rename(prequire,require)
--- Function that does nothing.
function Util.empty_f() end
--- Table that always empty.
Util.empty_t=setmetatable({},{
 __newindex=Util.empty_f,
 __tostring=function()
  return "table<empty>"
 end,
})
--- ---
--- Number
--- ---
function Util.number_get_place(number)
 if number==0 then
  return 1
 end
 return math.floor(math.log(number,10)/3)
end
function Util.number_sub(number,positive,negative)
 local whole,frac=Util.number_split(number)
 whole=whole%(10^positive)
 local percentile=10^(math.abs(negative))
 frac=math.floor(frac*(percentile))/percentile
 return whole+frac
end
function Util.number_get_whole(number)
 return math.floor(number)
end
function Util.number_get_frac(number)
 return number-Util.number_get_whole(number)
end
function Util.number_split(number)
 local whole=math.floor(number)
 local frac=number-whole
 return whole,frac
end
function Util.number_fill(number,char,size_whole,size_frac)
 local whole,frac=Util.number_split(number)
 frac=Util.number_sub(frac,0,3)*(10^size_frac)
 return Util.fillprefix(tostring(whole),size_whole,char)
  .."."..Util.fillsuffix(tostring(frac),size_frac,char)
end
function Util.number_get_sign(n)
 return n==0 and 0 or n>0 and 1 or -1
end
function Util.number_range(number,max,min)
 return math.min(math.max(number,max),min)
end
--- ---
--- Track
--- ---
local units={
 [-3]="ns",
 [-2]="μs",
 [-1]="ms",
 [0]="s",
 "ks",
 "Ms",
 "bs",
}
---@param second number
---@param max integer max unit, 0 for s, and 1 for ks etc.
---@param min integer min unit, 0 for s, and -1 for ms etc.
function Util.format_time(second,max,min)
 local places=Util.number_get_place(second)
 if max and min then
  places=Util.number_range(places,max,min)
 end
 local unit=units[places]
 local number=second/(10^(places*3))
 return Util.number_fill(Util.number_sub(number,3,3),"0",3,3)..unit
end
--- ---
--- Modes
--- ---
---@enum (key) visualmode
local is_visualmode={
 v=true,
 V=true,
 [""]=true,
}
function Util.get_vmode()
 local vmode=vim.api.nvim_get_mode().mode
 if is_visualmode[vmode:sub(1,1)]==nil then
  vmode=vim.fn.visualmode() --[[@as visualmode]]
 end
 return vmode
end
local function pipe(obj)
 return function(fn,...)
  if fn==nil then
   return obj
  end
  return pipe(fn(obj,...))
 end
end
Util.pipe=pipe
--- ---
--- Project
--- ---
---@param name string?
function Util.track(name)
 require("lazy.util").track(name)
end
---@param stack integer?
function Util.get_source(stack)
 local info=debug.getinfo(stack~=nil and stack or 2,"S")
 return info and info.source:sub(2) or "?"
end
function Util.getinfo(stack,...)
 local info=debug.getinfo(2+(stack~=nil and stack-1 or 0))
 local ret={}
 for i=1,select("#",...) do
  local key=select(i,...)
  table.insert(ret,tostring(info[key]))
 end
 return table.concat(ret,"|")
end
Util.root_path=vim.fn.fnamemodify(Util.get_source(),":h:h:h:h")
Util.paths={
 Util.root_path,
 vim.fn.stdpath("config"),
}
function Util.batch(fn,...)
 for i=1,select("#",...) do
  local ret=fn(select(i,...))
  if ret then return ret end
 end
end
function Util.find_mod(...)
 return Util.batch(function(modname)
                    return vim.loader.find(modname)[1]
                   end,...)
end
--- Get all mod starts in giving prefix
---@param modnames string|string[]
function Util.iter_mod(modnames)
 return coroutine.wrap(function()
  for _,modname in Util.pipairs(modnames) do
   local match=Util.find_mod(modname)
   if match then
    coroutine.yield(match.modname,match.modpath)
   end
   local dir=vim.loader.find(modname,{patterns={""}})[1]
   if dir then
    for name in vim.fs.dir(dir.modpath) do
     local mod=Util.find_mod(modname.."."..Util.trimsuffix(name,".lua"))
     if mod then
      coroutine.yield(mod.modname,mod.modpath)
     end
    end
   end
  end
 end)
end
--- ---
--- Type check
--- ---
function Util.is_integer(x)
 return type(x)=="number" and math.floor(x)==x
end
function Util.is_decimal(x)
 return type(x)=="number" and math.floor(x)~=x
end
local empty_check={
 number=function(x)
  return x==0
 end,
 table=function(x)
  return next(x)==nil
 end,
 string=function(x)
  return x==""
 end,
 ["nil"]=function()
  return true
 end,
}
Util.empty_check=empty_check
function Util.is_empty(x)
 return empty_check[type(x)](x)
end
function Util.is_truthy(x)
 return x==true
  or (x~=nil and x~=false)
  or x~=x -- NaN is truthy
end
function Util.is_falsy(x)
 return x==false or x==nil
end
---@param tbl table
---@return boolean
function Util.is_list(tbl)
 local i=0
 for _ in pairs(tbl) do
  i=i+1
  if tbl[i]==nil then
   return false
  end
 end
 return true
end
---@param tbl table
function Util.is_fat_table(tbl)
 return next(tbl)~=nil
end
--- ---
--- Table
--- ---
function Util.tbl_check(t,k)
 local create=false
 local ret=t[k]
 if ret==nil then
  create=true
  ret={}
  t[k]=ret
 end
 return ret,create
end
---@generic T
---@param expr fun():T
---@return T
function Util.tbl_echeck(t,k,expr)
 local ret=t[k]
 if ret==nil then
  ret=expr==nil and {} or expr()
  t[k]=ret
 end
 return ret
end
function Util.tbl_pcheck(t,k)
 local ret=t[k]
 if ret==nil then
  ret={}
  t[k]=ret
 elseif type(ret)~="table" then
  error("Expected table at key '"..tostring(k).."' but got '"..type(ret).."'")
 end
 return ret
end
function Util.tbl_clear(tbl)
 for k in pairs(tbl) do
  tbl[k]=nil
 end
 setmetatable(tbl,nil)
 return tbl
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
---@param dst T[]
---@param ... T[]
---@return T[]
function Util.list_flatten(dst,...)
 for i=1,select("#",...) do
  local t=select(i,...)
  for _,v in ipairs(t) do
   if type(v)=="table" then
    Util.flatten(dst,v)
   else
    table.insert(dst,v)
   end
  end
 end
 return dst
end
local function override(dst,src,cache)
 if src==nil
 or dst==src
 or cache[dst]==true
 then
  return dst
 end
 if dst==nil
 or type(src)~="table"
 or type(dst)~="table"
 or cache[src]==true
 then
  return src
 end
 cache[dst]=true
 cache[src]=true
 for k,v in pairs(src) do
  dst[k]=override(dst[k],v,cache)
 end
 return dst
end
---@generic T
---@param dst T
---@param src T
---@return T
function Util.override(dst,src)
 return override(dst,src,{})
end
local function deepcopy(orig)
 if type(orig)~="table" then
  return orig
 end
 local ret={}
 for k,v in pairs(orig) do
  ret[deepcopy(k)]=deepcopy(v)
 end
 return ret
end
function Util.deepcopy(orig)
 return deepcopy(orig)
end
local function deepset(tbl,key,val)
 rawset(tbl,key,val)
 if tbl[key]==val then
  return
 end
 local mt=getmetatable(tbl)
 if mt==nil then
  return
 end
 local super=mt.__index
 if type(super)~="table" then
  error("cannot set value for a non-table __index")
 end
 deepset(super,key,val)
end
---@param tbl table
---@param key any
---@param val any
function Util.deepset(tbl,key,val)
 deepset(tbl,key,val)
end
--- Return true if input is truthy value, otherwise return false
---@param val any
---@return boolean
function Util.toboolean(val)
 return val~=nil and val~=false
end
--- Return a table with one element if input is not a table, otherwise return the input table.
---@generic T
---@param any T
---@return T[]
function Util.totable(any)
 if type(any)~="table" then
  return {any}
 end
 return any
end
function Util.concat(...)
 local ret=""
 for i=1,select("#",...) do
  local v=select(i,...)
  if v~=nil then
   ret=ret..v
  end
 end
 return ret
end
--- Like totable but return nil if input is a `empty table` or `nil`
---@generic T
---@param any T
---@return T[]|nil
function Util.to_fat_table(any)
 if type(any)~="table" then
  if any==nil then
   return
  end
  return {any}
 end
 if next(any)==nil then
  return
 end
 return any
end
function Util.eval(expr,...)
 return type(expr)=="function" and expr(...) or expr
end
function Util.deep_eval(expr,...)
 local ret=expr
 while type(ret)=="function" do
  ret=Util.eval(ret,...)
 end
 return ret
end
---@generic T
---@param ... T
---@return {[T]:true}
function Util.to_set(...)
 local ret={}
 for i=1,select("#",...) do
  ret[select(i,...)]=true
 end
 return ret
end
---@generic T
---@param tbl {[any]:T}
---@return {[T]:true}
function Util.tbl_to_set(tbl)
 local ret={}
 for _,v in pairs(tbl) do
  ret[v]=true
 end
 return ret
end
--- ---
--- String
--- ---
local function rf(str,s,e,...)
 if s~=nil then
  local l=#str+1
  return l-s,l-e,...
 end
 return s,e,...
end
---@param s       string|number
---@param pattern string|number
---@param init?   integer
---@param plain?  boolean
---@return integer|nil start
---@return integer|nil end
---@return any|nil ... captured
---@nodiscard
function Util.rfind(s,pattern,init,plain)
 return rf(s,string.find(string.reverse(s),pattern,init,plain))
end
---@param str    string
---@param prefix string
function Util.startswith(str,prefix)
 return str:sub(1,#prefix)==prefix
end
local pattern={
 vim.fn.stdpath("config") --[[@as string]],
 vim.fn.stdpath("data") --[[@as string]],
}
function Util.depth(file)
 return file:gsub()
end
function Util.is_profile(file)
 file=string.lower(file)
 for _,v in ipairs(pattern) do
  if Util.startswith(file,string.lower(v)) then
   return true
  end
 end
end
---@param str    string
---@param suffix string
function Util.endswith(str,suffix)
 return #suffix==0 or str:sub(- #suffix)==suffix
end
---@param str    string
---@param chars  string
---@param direction
---| 0 "left"
---| 1 "right"
function Util.trimchars(str,chars,direction)
 if direction==0 then
  local _,e=str:find("["..chars.."]+")
  return str:sub(e+1)
 elseif direction==1 then
  local s=Util.rfind(str,"["..chars.."]+")
  return str:sub(s-1)
 end
 error("Invalid direction: "..direction)
end
---@param str    string
---@param prefix string
function Util.trimprefix(str,prefix)
 return Util.startswith(str,prefix) and str:sub(#prefix+1) or str
end
---@param str    string
---@param suffix string
function Util.trimsuffix(str,suffix)
 return Util.endswith(str,suffix) and str:sub(1,-(#suffix+1)) or str
end
---@param str    string
---@param prefix string
function Util.fillprefix(str,len,prefix)
 return #str<len and prefix:rep(len-#str)..str or str
end
---@param str    string
---@param suffix string
function Util.fillsuffix(str,len,suffix)
 return #str<len and str..suffix:rep(len-#str) or str
end
---@param tbl table
---@param keys nonil[]|string
function Util.tbl_get(tbl,keys)
 if type(keys)=="string" then
  keys=vim.split(keys,".",{plain=true,trimempty=true})
 end
 local e=#keys
 for i=1,e do
  tbl=Util.tbl_pcheck(tbl,keys[i])
 end
 return tbl
end
---@param tbl table
---@param keys nonil[]|string
---@param val any
function Util.tbl_set(tbl,keys,val)
 if type(keys)=="string" then
  keys=vim.split(keys,".",{plain=true,trimempty=true})
 end
 local e=#keys
 for i=1,e-1 do
  tbl=Util.tbl_pcheck(tbl,keys[i])
 end
 tbl[keys[e]]=val
 return tbl
end
function Util.tbl_newindex(tbl,...)
 local e=select("#",...)
 for i=1,e-2 do
  local v=select(i,...)
  if v==nil then
   error(string.format("invalid index at %d",i))
  end
  tbl=Util.tbl_pcheck(tbl,v)
 end
 tbl[select(e-1,...)]=select(e,...)
end
function Util.tbl_index(tbl,...)
 local e=select("#",...)
 for i=1,e-1 do
  local v=select(i,...)
  if v==nil then
   error(string.format("invalid index at %d",i))
  end
  tbl=Util.tbl_pcheck(tbl,v)
 end
 return tbl[select(e,...)]
end
--- ---
--- Iterators.
--- ---
--- Iterate the value itself, and stop.
local function self_iter(any,done)
 if done==nil then
  return true,any
 end
end
---@generic T: any, K, V
---@param any T
---@return fun(table: table<K, V>, index?: K):K, V
---@return T?
function Util.ppairs(any)
 if any==nil then
  return Util.empty_f
 end
 if type(any)=="table" then
  return pairs(any)
 end
 return self_iter,any
end
---@generic T: any, V
---@param any T
---@return fun(any:V[],i?:integer):integer,V
---@return T?
---@return integer?
function Util.pipairs(any)
 if any==nil then
  return Util.empty_f
 end
 if type(any)=="table" then
  return ipairs(any)
 end
 return self_iter,any
end
---@generic K,V
---@param s {[1]:table<K,V>,[2]:K[]}
---@return K?,V?
local function range_iter(s)
 local t=s[1]
 local r=s[2]
 for i=s[3],s[4] do
  local k=r[i]
  local v=t[k]
  if v~=nil then
   s[3]=i+1
   return k,v
  end
 end
end
---@generic K, V
---@param tbl table<K,V>
---@param range K[]
---@return fun(t:{[1]:table<K,V>,[2]:any[],[3]:integer}):K,V
---@return {[1]:table<K,V>,[2]:any[]}
function Util.rpairs(tbl,range)
 return range_iter,{tbl,range,1,#range}
end
return Util

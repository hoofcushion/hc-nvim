--- Lazy load each util prevent loop require
local Util=require("hc-nvim.util.lazy_tab").create({
 Autocmd     ="hc-nvim.util.autocmd",
 BufferCache ="hc-nvim.util.buffercache",
 Cache       ="hc-nvim.util.cache",
 Class       ="hc-nvim.util.class",
 Clock       ="hc-nvim.util.clock",
 Color       ="hc-nvim.util.color",
 Event       ="hc-nvim.util.event",
 Fallback    ="hc-nvim.util.fallback",
 HLGroup     ="hc-nvim.util.hl_group",
 Highlight   ="hc-nvim.util.highlight",
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
  Color       =require("hc-nvim.util.color"),
  Event       =require("hc-nvim.util.event"),
  Fallback    =require("hc-nvim.util.fallback"),
  HLGroup     =require("hc-nvim.util.hl_group"),
  Highlight   =require("hc-nvim.util.highlight"),
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
function Util.lua_ls_alias(_,obj)
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
function Util.ok_or_nil(ok,...)
 if ok then
  return ...
 end
end
function Util.nilpcall(...)
 return Util.ok_or_nil(pcall(...))
end
--- Like require but return nil instead error when failed
Util.prequire=Util.lua_ls_alias(require,function(modname)
 return Util.nilpcall(require,modname)
end)
--- Function that does nothing.
function Util.empty_f() end
--- Table that always empty.
Util.empty_t=setmetatable({},{
 __index=Util.empty_f,
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
function Util.number_sub(number,int,dec)
 local whole,frac=Util.number_split(number)
 whole=whole%(10^int)
 local percentile=10^(dec)
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
 local vmode=vim.api.nvim_get_mode().mode:sub(1,1)
 if is_visualmode[vmode]==nil then
  return vim.fn.visualmode() --[[@as visualmode]]
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
 Util.try(function()
  require("lazy.util").track(name)
 end)
end
---@param stack integer?
function Util.get_source(stack)
 local info=debug.getinfo(stack~=nil and stack or 2,"S")
 return info and info.source:sub(2) or "?"
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
do
 local opts={paths=Util.paths,rtp=false}
 local function find(modname)
  return vim.loader.find(modname,opts)[1]
 end
 function Util.find_local_mod(...)
  return Util.batch(find,...)
 end
end
--- Similar to `require`, but slightly faster
--- It only search module in `Util.paths`
function Util.local_require(modname)
 local info=Util.find_local_mod(modname)
 if info then
  local ret=assert(loadfile(info.modpath))() or true
  package.loaded[modname]=ret
  return ret
 end
 return nil
end
local function find_mod(modname)
 return vim.loader.find(modname)[1]
end
function Util.find_mod(...)
 return Util.batch(find_mod,...)
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
 local check=empty_check[type(x)]
 return check and check(x) or false
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
function Util.validate(x,t)
 if type(x)==t then
  return true
 end
 error(("Expect %s, got %s"):format(t,type(x)))
end
--- ---
--- Table
--- ---
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
 elseif type(ret)~="table" then
  error("Expected table at key '"..tostring(k).."' but got '"..type(ret).."'")
 end
 return ret
end
--- Clear a table.
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
--- Use `repl` to replace `orig` if their type matched and orig isn't nil
local function prefer(repl,orig)
 if repl==nil or repl==orig or type(repl)~=type(orig) then
  return orig
 end
 if orig==nil then
  return repl
 end
end
--- Override a value recursively
--- Use cache to check loop
local function override(dst,src,cache)
 if cache[dst] or cache[src] then
  return dst
 end
 local has_prefer=prefer(dst,src)
 if has_prefer~=nil then
  return has_prefer
 end
 cache[dst]=true
 cache[src]=true
 for k,v in pairs(src) do
  dst[k]=override(dst[k],v,cache)
 end
 return dst
end
--- Use src's elements to override dst
--- Return dst
---@generic T
---@param dst T
---@param src T
---@return T
function Util.override(dst,src)
 return override(dst,src,{})
end
function Util.trace(msg)
 vim.notify(msg,vim.log.levels.TRACE)
end
function Util.debug(msg)
 vim.notify(msg,vim.log.levels.DEBUG)
end
function Util.info(msg)
 vim.notify(msg,vim.log.levels.INFO)
end
function Util.warn(msg)
 vim.notify(msg,vim.log.levels.WARN)
end
function Util.error(msg)
 vim.notify(msg,vim.log.levels.ERROR)
end
function Util.off(msg)
 vim.notify(msg,vim.log.levels.OFF)
end
function Util.try(fn,catch)
 if catch==nil then
  catch=Util.error
 end
 xpcall(fn,function(ok,err)
  if not ok then
   catch(err)
  end
 end)
end
function Util.fileexist(file)
 return vim.uv.fs_stat(file)~=nil
end
--- Run callback immediately if no arg passing to neovim when launch
--- Else it runs when entering first buf
function Util.auto(callback)
 if vim.fn.argc()~=0 then
  Util.try(callback)
 else
  vim.api.nvim_create_autocmd({"VimEnter","BufAdd"},{
   callback=function(ev)
    if Util.fileexist(ev.file)~=nil then
     Util.try(callback)
     return true
    end
   end,
  })
 end
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
---@generic T
---@param orig T
---@return T
function Util.deepcopy(orig)
 return deepcopy(orig)
end
--- Rawset key-value for the root __index of tbl
local function deepset(tbl,key,val)
 rawset(tbl,key,val)
 if tbl[key]==nil then
  return
 end
 local mt=getmetatable(tbl)
 if mt==nil or mt.__index==nil then
  return
 end
 local super=mt.__index
 if type(super)~="table" then
  error("cannot deep set value for non-table __index")
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
--- Like totable but return nil if input is a `empty table` or `nil`
---@return table?
function Util.to_fat_table(any)
 if type(any)~="table" then
  if any~=nil then
   return {any}
  end
  return
 end
 if next(any)~=nil then
  return any
 end
end
---@param ... string
---@return string
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
---@generic T
---@param ... any
---@param expr T|fun(...:any):T
---@return T
function Util.eval(expr,...)
 return type(expr)=="function" and expr(...) or expr
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
---@param fix string
function Util.startswith(str,fix)
 if #fix>#str then return false end
 return str:sub(1,#fix)==fix
end
local pattern={
 vim.fn.stdpath("config") --[[@as string]],
 vim.fn.stdpath("data") --[[@as string]],
}
function Util.is_profile(file)
 file=string.lower(file)
 for _,v in ipairs(pattern) do
  if Util.startswith(file,string.lower(v)) then
   return true
  end
 end
end
function Util.get_size(id)
 if type(id)=="number" then
  return vim.api.nvim_buf_get_offset(id,vim.api.nvim_buf_line_count(id))
 else
  local info=vim.uv.fs_stat(id)
  return info~=nil and info.size or nil
 end
end
---@param str string
---@param fix string
function Util.endswith(str,fix)
 if #fix>#str then return false end
 return #fix==0 or str:sub(- #fix)==fix
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
  tbl=Util.tbl_check(tbl,keys[i])
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
  tbl=Util.tbl_check(tbl,keys[i])
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
  tbl=Util.tbl_check(tbl,v)
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
  tbl=Util.tbl_check(tbl,v)
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
local function _gsplit(s)
 if s.done then
  return
 end
 -- special case for sep == ""
 -- simply iterate all chars
 if s.sep=="" then
  if s.i==s.len then
   s.done=true
  end
  local i=s.i
  s.i=s.i+1
  return s.str:sub(i,i)
 end
 -- normal split using string.find
 local j,k=string.find(s.str,s.sep,s.i,s.plain)
 if j==nil then
  if s.trimempty and s.i>s.len then
   return
  end
  s.done=true
  return s.str:sub(s.i)
 end
 --- simply skip this iteration
 if s.trimempty and k==1 then
  s.i=s.i+1
  return _gsplit(s)
 end
 -- string.find("a|c","|") returns (2,2)
 -- so use previous i and e-1 gives "a"
 local i=s.i
 s.i=k+1
 return s.str:sub(i,k-1)
end
local function gsplit(str,sep,opts)
 local plain,trimempty
 if type(opts)=="boolean" then
  plain=opts
 else
  vim.validate({s={str,"s"},sep={sep,"s"},opts={opts,"t",true}})
  opts=opts or {}
  plain,trimempty=opts.plain,opts.trimempty
 end
 return _gsplit,
  {
   str=str,
   sep=sep,
   i=1,
   len=#str,
   plain=plain,
   trimempty=trimempty,
   done=false,
  }
end
local function split(str,sep,opts)
 local list={}
 for s in gsplit(str,sep,opts) do
  table.insert(list,s)
 end
 return list
end
--- A faster version of vim.gsplit
function Util.gsplit(str,sep,opts)
 return gsplit(str,sep,opts)
end
--- A faster version of vim.split
function Util.split(str,sep,opts)
 return split(str,sep,opts)
end
vim.split=Util.lua_ls_alias(vim.split,split)
vim.gsplit=Util.lua_ls_alias(vim.gsplit,gsplit)
function Util.split_at(str,pos)
 return str:sub(1,pos-1),str:sub(pos+1)
end
function Util.split_by(str,sep,plain)
 local pos=str:find(sep,plain)
 if pos then
  return str:sub(1,pos-1),str:sub(pos+1)
 end
 return str
end
return Util

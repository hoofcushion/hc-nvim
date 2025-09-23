---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
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
---@param tbl T[]
---@return table<T,true>
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
--- 对 str，从左往右查找 pattern，并返回 sep 左侧的文字
--- 如果 rev 为 true，则从右往左查找，返回右侧的字符
---@param str string
---@param pattern string
---@return string
function Util.str_cut(str,pattern,plain)
 local pos=str:find(pattern,1,plain)
 if pos then
  return str:sub(1,pos-1)
 end
 return str
end
--- 对 str，从左往右查找 pattern，并返回 sep 左侧的文字
--- 如果 rev 为 true，则从右往左查找，返回右侧的字符
---@param str string
---@param pattern string
---@return string
function Util.str_cut_r(str,pattern,plain)
 return Util.str_cut(str:reverse(),pattern,plain):reverse()
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
 if s.trimempty and s.i>s.len then
  return
 end
 -- normal split using string.find
 local _i,_e=string.find(s.str,s.sep,s.i,s.plain)
 if _i==nil then
  s.done=true
  return s.str:sub(s.i)
 end
 --- simply skip this iteration
 if s.trimempty and _e==1 then
  s.i=s.i+1
  return _gsplit(s)
 end
 -- string.find("a|c","|") returns (2,2)
 -- so use previous i and e-1 gives "a"
 local i=s.i
 s.i=_e+1
 return s.str:sub(i,_e-1)
end
local function gsplit(str,sep,opts)
 local plain,trimempty
 if type(opts)=="boolean" then
  plain=opts
 else
  Util.validate(str, "string")
  Util.validate(sep, "string")
  Util.validate(opts,"table", true)
  opts=opts or {}
  plain,trimempty=opts.plain,opts.trimempty
 end
 local s={str=str,sep=sep,i=1,len=#str,plain=plain,trimempty=trimempty,done=false}
 --- match vim.gsplit's function signature
 return function()
  return _gsplit(s)
 end
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

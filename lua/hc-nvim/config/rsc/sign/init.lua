---@class Sign
local Sign={}
---@generic sign
---@param signs sign
---@return sign|Sign
function Sign.new(signs)
 local signs_str={}
 for k,v in pairs(signs) do
  if type(k)=="string" then
   signs_str[k]=v
  end
 end
 for name,value in pairs(signs_str) do
  signs_str[name:sub(1,1)]=value
 end
 for name,value in pairs(signs_str) do
  signs_str[name:lower()]=value
 end
 for name,value in pairs(signs_str) do
  local int=vim.diagnostic.severity[name]
  if int~=nil then
   signs_str[int]=value
  end
 end
 return setmetatable(signs_str,{__index=Sign})
end
function Sign:suffix(suffix)
 local ret={}
 for name,icon in pairs(self) do
  ret[name]=icon..suffix
 end
 return Sign.new(ret)
end
function Sign:prefix(prefix)
 local ret={}
 for name,icon in pairs(self) do
  ret[name]=prefix..icon
 end
 return Sign.new(ret)
end
local function utf8_sub(str,start,finish)
 return table.concat(vim.list_slice(vim.tbl_map(vim.fn.nr2char,vim.fn.str2list(str)),start,finish))
end
function Sign:sub(s,e)
 local ret={}
 for name,icon in pairs(self) do
  ret[name]=utf8_sub(icon,s,e)
 end
 return Sign.new(ret)
end
return Sign.new

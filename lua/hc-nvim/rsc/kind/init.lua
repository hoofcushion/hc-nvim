---@class KIND
local Kind={}
---@generic kind
---@param kind kind
---@return kind|KIND
function Kind.new(kind)
 return setmetatable(kind,{__index=Kind})
end
function Kind:suffix(suffix)
 local ret={}
 for name,icon in pairs(self) do
  ret[name]=icon..suffix
 end
 return Kind.new(ret)
end
function Kind:prifix(prefix)
 local ret={}
 for name,icon in pairs(self) do
  ret[name]=prefix..icon
 end
 return Kind.new(ret)
end
local function utf8_sub(str,start,finish)
 return table.concat(vim.list_slice(vim.tbl_map(vim.fn.nr2char,vim.fn.str2list(str)),start,finish))
end
function Kind:sub(s,e)
 local ret={}
 for name,icon in pairs(self) do
  ret[name]=utf8_sub(icon,s,e)
 end
 return Kind.new(ret)
end
return Kind.new

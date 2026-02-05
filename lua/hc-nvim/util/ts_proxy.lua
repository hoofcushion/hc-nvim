local HCNvim=require("hc-nvim.init_space")
---@class TSProxy
---@operator call(): TSNode?
---@operator concat(string): TSProxy
---@field [integer] TSProxy
---@field [string] TSProxy
---@field [PRIVATE] TSProxyPrivate
local TSProxy={}
---@class TSProxyPrivate
---@field node TSNode? 内部的 treesitter 节点
---@field children table<any, TSNode> 缓存的子节点映射表
local TSProxyPrivate={}
---@alias PRIVATE TSProxyPrivate 私有命名空间的标识符

---私有命名空间的标识符
---用于存储 TSProxy 的内部状态
local PRIVATE={}
---调用 TSProxy 对象时返回内部的 TSNode
---@return TSNode?
function TSProxy:__call()
 local private=self[PRIVATE]
 return private.node
end
---将 TSProxy 转换为字符串表示形式
---显示节点类型及其所有子节点的结构化信息
---@return string
function TSProxy:__tostring()
 local private=self[PRIVATE]
 local node=private.node
 if not node then
  return "nil"
 end
 local result={}
 local index=0
 for child,field in node:iter_children() do
  index=index+1
  local field_str=field or "anonymous"
  local type_str=child:type()
  table.insert(result,string.format("[%2d] %-12s %s",index,field_str,type_str))
 end
 local buffer={
  node:type(),": {\n",
  table.concat(result,"\n  ")
  "\n}",
 }
 return table.concat(buffer,"\n")
end
---初始化节点的子节点映射表
---创建多种访问键：
---1. 数字索引（位置顺序）
---2. 字段名（首次出现）
---3. 字段名_序号（重复字段）
---4. 节点类型（首次出现）
---5. 节点类型_序号（重复类型）
---@param node TSNode?
---@return table<any, TSNode>?
local function init_children(node)
 if not node then
  return
 end
 local ret={}
 local field_count,type_count={},{}
 local index=0
 for child,field in node:iter_children() do
  index=index+1
  -- 数字索引
  ret[index]=child
  -- 字段键
  field=field or "anonymous"
  local fcount=(field_count[field] or 0)+1
  field_count[field]=fcount
  if fcount==1 then
   ret[field]=child
  end
  ret[field.."_"..tostring(fcount)]=child
  -- 类型键
  local child_type=child:type()
  local tcount=(type_count[child_type] or 0)+1
  type_count[child_type]=tcount
  if tcount==1 then
   ret[child_type]=child
  end
  ret[child_type.."_"..tostring(tcount)]=child
 end
 return ret
end

---索引访问子节点
---支持多种访问方式：
---1. 数字索引：node[1], node[2], ...
---2. 字段名：node.identifier, node.type, ...
---3. 重复字段：node.identifier_1, node.identifier_2, ...
---4. 节点类型：node["function"], node["identifier"], ...
---5. 重复类型：node["function_1"], node["identifier_2"], ...
---@param k any
---@return TSProxy
function TSProxy:__index(k)
 local private=self[PRIVATE]
 local children=private.children
 if children[k] then
  return TSProxy.new(children[k])
 end
 -- 返回空的代理对象
 return TSProxy.new()
end
---创建新的 TSProxy 对象
---@param node TSNode? 要代理的 treesitter 节点
---@return TSProxy
function TSProxy.new(node)
 ---@class TSProxyPrivate
 local private={}
 private.node=node
 ---@type table<any, TSNode>
 private.children=HCNvim.Util.lazy(
  function()
   return init_children(node) or {}
  end,
  function(t)
   private.children=t
  end
 )
 return setmetatable(
  {[PRIVATE]=private},
  TSProxy
 )
end
return TSProxy

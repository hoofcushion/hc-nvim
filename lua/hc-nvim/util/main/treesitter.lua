---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@param node TSNode
---@param find string|fun(node:TSNode):boolean?
---@return TSNode?
function Util.ts_lookup(node,find)
 local n; n=node
 if type(find)~="function" then
  local target=find
  find=function(_node)
   return _node:type()==target
  end
 end
 while n and not find(n) do
  n=n:parent()
 end
 return n
end
function Util.ts_get_cursor_node(winnr)
 winnr=winnr or vim.api.nvim_get_current_win()
 local pos=vim.api.nvim_win_get_cursor(winnr)
 local c_node=vim.treesitter.get_node({pos={pos[1]-1,pos[2]}})
 local node; node=c_node
 while node and node:child_count()>0 do
  node=node:child(0)
 end
 return node
end
---@param node TSNode
---@param source string|integer
function Util.ts_extract(node,source,name)
 local result={
  name=name,
  type=node:type(),
  text=node:child_count()==0 and vim.treesitter.get_node_text(node,source) or nil,
 }
 for child,filed in node:iter_children() do
  table.insert(result,Util.ts_extract(child,source,filed))
 end
 return result
end
---@alias pos {[1]:integer;[2]:integer;}
---@alias range {[1]:integer;[2]:integer;[3]:integer;[4]:integer}
---@param pos pos (0,0)-indexed cursor position
---@param range range (0,0,0,0)-indexed start position and finish position
function Util.ts_get_distance(pos,range)
 local d_start=math.abs(pos[1]-range[1])+math.abs(pos[2]-range[2])
 local d_end=math.abs(pos[1]-range[3])+math.abs(pos[2]-range[4])
 return math.min(d_start,d_end)
end
function Util.ts_get_text_between(buf,node_start,node_finish)
 local start_range={node_start:range()}
 local finish_range={node_finish:range()}
 local whole_range={start_range[3],start_range[4],finish_range[1],finish_range[2]}
 local middle_text=Util.buf_get_text(buf,whole_range)
 return middle_text
end

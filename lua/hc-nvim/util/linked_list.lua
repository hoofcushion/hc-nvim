local LinkedList={
 value=nil,
 next=nil,
}
local _LinkedList={__index=LinkedList}
function LinkedList.new(data)
 local obj=setmetatable({},_LinkedList)
 obj.value=data
 return obj
end
function LinkedList:append(data)
 local node=self
 while node.next~=nil do
  node=node.next
 end
 node.next=LinkedList.new(data)
end
function LinkedList:truncate(target)
 local prev=nil
 local node=self
 while node~=nil and node.value~=target do
  prev=node
  node=node.next
 end
 if node and prev then
  prev.next=nil
 end
end
function LinkedList:remove(target)
 local prev=nil
 local node=self
 while node~=nil and node.value~=target do
  prev=node
  node=node.next
 end
 if node and prev then
  prev.next=node.next
 end
end
local done={}
function LinkedList._iter(_,node)
 if node==done then
  return
 end
 return node.next or done,node.data
end
function LinkedList:iter()
 return LinkedList._iter,nil,self
end
function LinkedList:tolist()
 local list={}
 for _,v in self:iter() do
  table.insert(list,v)
 end
 return list
end
local l=LinkedList.new(0)
for i=1,9 do
 l:append(i)
end
l:truncate(8)
l:remove(4)
assert(table.concat(l:tolist(),"->")=="0->1->2->3->5->6->7")
-- local _mappings={}
-- local mapping={}
-- function mapping.add(mode,lhs,rhs,opts)
--  _mappings[mode][lhs]=_mappings[mode][lhs] or {}
--  local t=_mappings[mode][lhs]
--  local pos=#t+1
--  t[pos]={rhs=rhs,opts=opts}
-- end
-- function mapping.del(id)
-- end
-- function mapping.trigger(mode,lhs)
--  local effects=_mappings[mode][lhs]
--  local success=false
--  for _,effect in ipairs(effects) do
--   local opts=effect.opts
--   local cb=opts.callback
--   if type(cb)=="function" then
--    local new_cb=function()
--     local ret=cb()
--     if ret then
--      success=true
--     end
--     return ret
--    end
--    opts.callback=new_cb
--   end
--   vim.api.nvim_set_keymap(mode,lhs,effect.rhs.."<ignore>",effect.opts)
--   vim.api.nvim_feedkeys(lhs,"m",true)
--   if success then
--    break
--   end
--  end
--  if not success then
--   vim.api.nvim_feedkeys(lhs,"n",true)
--  end
-- end
-- function mapping.set(mode,lhs,rhs,opts)
--  mapping.add(mode,lhs,rhs,opts)
-- end

-- deque
local deque={
 s=1,
 e=0,
 l={},
}
function deque:append(v)
 self.e=self.e+1
 self.l[self.e]=v
end
function deque:pophead()
 local v=self.l[self.s]
 self.s=self.s+1
 return v
end
function deque:tail()
 return self.l[self.e]
end
function deque:len()
 return self.e-self.s+1
end
function deque.new()
 return setmetatable(
  {
   s=1,
   e=0,
   l={},
  },
  {
   __index=deque,
  }
 )
end
local speed={(function()
 local moves=deque.new()
 local last_pos
 vim.api.nvim_create_autocmd("WinEnter",{
  callback=function(ev)
   if ev.file=="" or vim.bo[ev.buf].buftype=="nofile" then
    return
   end
   last_pos=vim.fn.getpos(".")
  end,
 })
 vim.api.nvim_create_autocmd({"CursorMoved","CursorMovedI"},{
  callback=function(ev)
   if ev.file=="" or vim.bo[ev.buf].buftype=="nofile" then
    return
   end
   local current_pos={vim.fn.line("."),vim.fn.virtcol(".")}
   if last_pos==nil then
    last_pos=current_pos
    return
   end
   local cur=Util.clock()
   local row_dist=math.abs(current_pos[1]-last_pos[1])
   local col_dist=math.abs(current_pos[2]-last_pos[2])
   local distance=row_dist+col_dist
   moves:append({distance,cur})
   last_pos=current_pos
  end,
 })
 local function get_speed()
  local cur=Util.clock()
  local total_chars=0
  for i=moves.s,moves.e do
   local v=moves.l[i]
   if cur-v[2]>60 then
    moves:pophead()
   else
    total_chars=total_chars+v[1]
   end
  end
  return math.floor(total_chars)
 end
 return function()
  if moves:len()==0 then
   return ""
  end
  if Util.clock()-moves:tail()[2]>5 then
   return ""
  end
  return get_speed().."b/m"
 end
end)()}
local typing={(function()
 local chars=deque.new()
 vim.api.nvim_create_autocmd("InsertCharPre",{
  callback=function()
   local char=vim.v.char
   if char==nil then
    return
   end
   chars:append({char,Util.clock()})
  end,
 })
 local function get_cpm()
  local cur=Util.clock()
  for i=chars.s,chars.e do
   local v=chars.l[i]
   if cur-v[2]>60 then
    chars:pophead()
   else
    break
   end
  end
  return chars:len()
 end
 return function()
  if chars:len()==0 then
   return ""
  end
  --- auto hide in 5 s
  if Util.clock()-chars:tail()[2]>5 then
   return ""
  end
  return get_cpm().."c/m"
 end
end)()}
return {
 typing=typing,
 speed=speed,
}

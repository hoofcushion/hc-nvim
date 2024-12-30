local Util=require("hc-nvim.util")
--- ---
--- RangeMark imp.
--- ---
---@class RangeMark
local RangeMark={
 ---@type integer
 bufnr=0,
 ---@type integer
 winid=0,
 ---@type position # (0,0)-indexed in storage, the start position of the visual selection
 cursor_s={0,0},
 ---@type position # (0,0)-indexed in storage, the end position of the visual selection
 cursor_e={0,0},
 ---@type position # (0,0)-indexed in storage, the start position of the RangeMark
 start={0,0},
 ---@type position # (0,0)-indexed in storage, the end position of the RangeMark
 finish={0,0},
 ---@type visualmode
 vmode="v",
 ---@alias RangeMark.position
 ---| "start" # The start position of the RangeMark
 ---| "finish" # The end position of the RangeMark
 ---| "cursor_s" # The start position of the visual selection
 ---| "cursor_e" # The end position of the visual selection
}
local CursorPos={}
function CursorPos.is_above(lhs,rhs)
 return lhs[1]<rhs[1]
end
function CursorPos.is_below(lhs,rhs)
 return lhs[1]>rhs[1]
end
function CursorPos.is_before(lhs,rhs)
 return CursorPos.is_above(lhs,rhs) or (lhs[1]==rhs[1] and lhs[2]<rhs[2])
end
function CursorPos.is_after(lhs,rhs)
 return CursorPos.is_below(lhs,rhs) or (lhs[1]==rhs[1] and lhs[2]>rhs[2])
end
---
--- Create a new RangeMark.
---@param start position
---@param finish position
---@param indexed? position
---@param vmode? visualmode
---@param winid? integer
---@param bufnr? integer
---@return RangeMark
function RangeMark:new(start,finish,indexed,vmode,winid,bufnr)
 local new=setmetatable({},{__index=self})
 start=vim.deepcopy(start)
 finish=vim.deepcopy(finish)
 if indexed~=nil then
  local line,col=indexed[1],indexed[2]
  start[1]=start[1]-line
  finish[1]=finish[1]-line
  start[2]=start[2]-col
  finish[2]=finish[2]-col
 end
 new.cursor_s=start
 new.cursor_e=finish
 start=vim.deepcopy(start)
 finish=vim.deepcopy(finish)
 if CursorPos.is_after(start,finish) then
  start,finish=finish,start
 end
 new.start=start
 new.finish=finish
 if winid~=nil then
  new.winid=winid
 end
 if bufnr~=nil then
  new.bufnr=bufnr
 end
 if vmode==nil then
  vmode=Util.get_vmode()
 end
 new.vmode=vmode
 return new
end
function RangeMark:is_overlap(rhs)
 if
    self.finish[1]<rhs.start[1] -- At upward
 or self.finish[2]<rhs.start[2] -- At leftward
 or self.start[1]>rhs.finish[1] -- At downward
 or self.start[2]>rhs.finish[2] -- At rightward
 then
  return false
 end
 return true
end
--- Check if the RangeMark is after `rhs`.
---@param rhs RangeMark
function RangeMark:is_after(rhs)
 if is_after(self.start,rhs.start) then
  return true
 end
 return false
end
---
--- Get the '`label1`,'`label2` RangeMark.
---@param mark1 string
---@param mark2 string
---@param vmode? visualmode
---@param buf integer?
function RangeMark:get_mark(mark1,mark2,vmode,buf)
 if buf==nil then buf=0 end
 return RangeMark:new(
  vim.api.nvim_buf_get_mark(buf,mark1),
  vim.api.nvim_buf_get_mark(buf,mark2),
  {1,0},
  vmode
 )
end
---
--- Get the RangeMark of current visual selection.
---@param vmode? visualmode
function RangeMark:get_selection(vmode)
 local s,e=vim.fn.getpos("v"),vim.fn.getpos(".")
 s,e={s[2],s[3]},{e[2],e[3]}
 return RangeMark:new(s,e,{1,1},vmode)
end
--- Get the RangeMark of specific line.
function RangeMark:get_line(line,height)
 if line==nil then
  line=vim.api.nvim_win_get_cursor(0)[1]-1
 end
 if height==nil then
  height=0
 end
 return RangeMark:new(
  {line,0},
  {line+height,vim.v.maxcol},
  {0,0},
  "V"
 )
end
---@param line integer
---@param column integer
---@return position
local function pos_offset(pos,line,column)
 return {pos[1]+line,pos[2]+column}
end
---@param pos RangeMark.position"
---@param line integer
---@param column integer
---@return position
function RangeMark:get_pos(pos,line,column)
 return pos_offset(self[pos],line,column)
end
---
--- Get the width of the RangeMark.
function RangeMark:get_width()
 return 1+self.finish[2]-self.start[2]
end
---
--- Get the height of the RangeMark.
function RangeMark:get_height()
 return 1+self.finish[1]-self.start[1]
end
---
--- Reset the width of the RangeMark.
---@param width integer
function RangeMark:set_width(width)
 local left,right=self.cursor_s,self.cursor_e
 if left[2]>right[2] then
  left,right=right,left
 end
 -- Column form 0 to 0 is width 1.
 local newcol=math.max(left[2]+width-1,0)
 newcol=math.min(newcol,vim.v.maxcol)
 right[2]=newcol
 local finish=self.finish
 finish[2]=newcol
end
function RangeMark:set_height(height)
 local up,down=self.cursor_s,self.cursor_e
 if up[1]>down[1] then
  up,down=down,up
 end
 local newline=math.max(up[1]+height-1,0)
 down[1]=newline
 local finish=self.finish
 finish[1]=newline
end
function RangeMark:set_size(height,width)
 self:set_height(height)
 self:set_width(width)
end
---
--- Move the RangeMark by `line` and `column`.
function RangeMark:move(line,column)
 local start=self.start
 local finish=self.finish
 if line~=0 then
  start[1]=start[1]+line
  finish[1]=finish[1]+line
 end
 if column~=0 then
  start[2]=start[2]+column
  finish[2]=finish[2]+column
 end
end
--- Select the RangeMark.
function RangeMark:select()
 self:set_cursor("cursor_s")
 vim.fn.feedkeys(self.vmode,"nx")
 self:set_cursor("cursor_e")
end
--- Get the text in the RangeMark.
---@return reginfo
function RangeMark:yank()
 local regcontents
 local vmode=self.vmode
 local s,e=self:get_pos("start",0,0),self:get_pos("finish",0,1)
 if vmode=="v" then
  regcontents=vim.api.nvim_buf_get_text(self.bufnr,s[1],s[2],e[1],e[2],Util.empty_t)
 elseif vmode=="V" then
  regcontents=vim.api.nvim_buf_get_lines(self.bufnr,s[1],e[1]+1,false)
 elseif vmode=="" then
  regcontents={}
  for lnum=s[1],e[1] do
   local line=vim.fn.getline(lnum+1)
   local min=line:len()
   local sc=math.min(min,s[2])
   local ec=math.min(min,e[2])
   local text=vim.api.nvim_buf_get_text(self.bufnr,lnum,sc,lnum,ec,Util.empty_t)[1]
   local spaces_amount=e[2]-min
   if spaces_amount>0 then
    text=text..string.rep(" ",spaces_amount)
   end
   table.insert(regcontents,text)
  end
 end
 local reg={
  regcontents=regcontents,
  type=self.vmode,
 }
 return reg
end
--- Set the text from `reg` in the RangeMark.
---@param reg reginfo
function RangeMark:put(reg)
 local regcontents=reg.regcontents
 local vmode=self.vmode
 local s,e=self:get_pos("start",0,0),self:get_pos("finish",0,1)
 if vmode=="v" then
  vim.api.nvim_buf_set_text(self.bufnr,s[1],s[2],e[1],e[2],regcontents)
 elseif vmode=="V" then
  vim.api.nvim_buf_set_lines(self.bufnr,s[1],e[1]+1,false,regcontents)
 elseif vmode=="" then
  local reg_i=1
  for lnum=s[1],e[1] do
   local line=vim.fn.getline(lnum+1)
   local min=line:len()
   local sc=math.min(min,s[2])
   local ec=math.min(min,e[2])
   vim.api.nvim_buf_set_text(self.bufnr,lnum,sc,lnum,ec,{regcontents[reg_i]})
   reg_i=reg_i+1
  end
 end
 --- Reset the size to match the reg
 self:set_size(
  #(reg.regcontents),
  #(reg.regcontents[#reg.regcontents])
 )
end
--- Set the text from `reg` in the RangeMark.
function RangeMark:swap(rhs)
 local lhs=self
 local vreg1=lhs:yank()
 local vreg2=rhs:yank()
 local vhit1=lhs:get_height()
 local vhit2=rhs:get_height()
 local vlen1=lhs:get_width()
 local vlen2=rhs:get_width()
 lhs:put(vreg2)
 local vmode=rhs.vmode
 if
 --- Chars horizontal movement
 --- Charwise in same line and different width
 vmode=="v"
 and rhs.start[1]==lhs.start[1]
 and vlen2~=vlen1
 --- Line vertical movement
 --- Linewise in different height
 or vmode=="V"
 and vhit2~=vhit1
 --- Block horizontal movement
 --- Blockwise in same line, same height, and different width
 or vmode==""
 and rhs.start[1]==lhs.start[1]
 and vhit2==vhit1
 and vlen2~=vlen1
 then
  rhs:move(vhit2-vhit1,vlen2-vlen1)
 end
 rhs:put(vreg1)
end
--- Highlight the RangeMark.
function RangeMark:highlight(hl_group,hl_opts,ns)
 vim.api.nvim_set_hl(ns,hl_group,hl_opts)
 vim.api.nvim_set_hl_ns(ns)
 local s=self:get_pos("start",0,0)
 local e=self:get_pos("finish",0,0)
 if self.vmode=="" then
  local sc,ec=s[2],e[2]
  for l=s[1],e[1] do
   vim.highlight.range(0,ns,hl_group,{l,sc},{l,ec},{inclusive=true,regtype="v"})
  end
 else
  vim.highlight.range(0,ns,hl_group,s,e,{inclusive=true,regtype=self.vmode})
 end
end
---@param rhs RangeMark
---@return boolean is_success
function RangeMark:exchange(rhs)
 local lhs=self
 if lhs:is_overlap(rhs) then
  vim.notify(
   "The two selection is overlap, try another region.",
   vim.log.levels.WARN,
   {title="RangeMark"}
  )
  return false
 end
 lhs:swap(rhs)
 return true
end
--- Move the cursor to the start or finish position of the RangeMark.
---@param pos RangeMark.position
function RangeMark:set_cursor(pos)
 vim.api.nvim_win_set_cursor(self.winid,self:get_pos(pos,1,0))
end
return RangeMark

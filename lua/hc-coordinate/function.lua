local Config=require("hc-coordinate.config")
local M={}
function M.fini() end
local function utf8_offset(str,nth)
 local max=vim.fn.strcharlen(str)+1
 nth=math.min(math.max(1,nth),max)
 return vim.fn.byteidx(str,nth-1)+1
end
local function utf8_charpos(str,nth)
 local s=utf8_offset(str,nth)
 local e=utf8_offset(str,nth+1)
 return s,e
end
local function utf8sub(str,nth)
 local s,e=utf8_charpos(str,nth)
 return str:sub(s,e-1)
end
local function get_absolute_col(lnum,vcol)
 local line=vim.fn.getline(lnum)
 local charidx=1
 local cur_vcol=1
 local byte=0
 local offset=0
 while cur_vcol<vcol do
  local char=utf8sub(line,charidx)
  if char=="" then
   break
  end
  local width=vim.fn.strdisplaywidth(char)
  if cur_vcol+width>vcol then
   offset=vcol-cur_vcol
   break
  end
  cur_vcol=cur_vcol+width
  charidx=charidx+1
  byte=byte+#char
 end
 local extra_byte=0
 while cur_vcol<vcol do
  cur_vcol=cur_vcol+1
  extra_byte=extra_byte+1
 end
 return {
  vcol=vcol,
  pos=byte,
  extra_pos=extra_byte,
  char_offset=offset,
 }
end
local labels=vim.split("abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()","")
local function init_grid()
 local cursor_pos=vim.api.nvim_win_get_cursor(0)
 local row,col=cursor_pos[1]-1,cursor_pos[2]
 local ns_id=vim.api.nvim_create_namespace("coordinate_system")
 vim.api.nvim_buf_clear_namespace(0,ns_id,0,-1)
 local range=#labels
 local vcol=vim.fn.virtcol(".")
 local line_count=vim.api.nvim_buf_line_count(0)
 -- for i=-range,range do
 for i=-range,range do
  if i~=0 then
   local row_y=row+i
   local lnum_y=row+i+1
   if lnum_y>=1 and lnum_y<=line_count then
    local pos=get_absolute_col(lnum_y,vcol)
    vim.api.nvim_buf_set_extmark(0,ns_id,row_y,pos.pos,{
     priority=1000,
     strict=false,
     virt_text_pos="overlay",
     virt_text={
      {(" "):rep(pos.extra_pos)},
      {(" "):rep(-pos.char_offset)},
      {labels[(math.abs(i)-1)%#labels+1],"Substitute"},
     },
    })
   end
   local len_x=#(vim.fn.getline(row+1))
   local posx=get_absolute_col(row+1,vcol+i)
   if col+i>=0 and col+i<=len_x then
    vim.api.nvim_buf_set_extmark(0,ns_id,row,posx.pos,{
     virt_text={
      {labels[(math.abs(i)-1)%#labels+1],"Substitute"},
     },
     virt_text_pos="overlay",
     hl_mode="combine",
    })
   end
  end
 end
 local _pos=get_absolute_col(row+1,vcol)
 vim.api.nvim_buf_set_extmark(0,ns_id,row,_pos.pos,{
  virt_text={
   {(" "):rep(_pos.extra_pos)},
   {(" "):rep(-_pos.char_offset)},
   {"0",                        "Substitute"},
  },
  virt_text_pos="overlay",
  hl_mode="combine",
 })
end
function close()
 local ns_id=vim.api.nvim_create_namespace("coordinate_system")
 vim.api.nvim_buf_clear_namespace(0,ns_id,0,-1)
end
function M.setup() -- 获取当前光标位置
 vim.keymap.set("n","<leader>cs",init_grid,{desc="Create coordinate system around cursor"})
 vim.keymap.set("n","<leader>cd",close,    {desc="Create coordinate system around cursor"})
end
M.setup()
-- init_grid()
-- local buf = vim.api.nvim_create_buf(false, true)  -- 创建临时缓冲区
-- local win = vim.api.nvim_open_win(buf, false, {
--   relative = 'editor',
--   anchor = 'SW',  -- 定位到左下角
--   row = vim.o.lines - 1,  -- 最后一行
--   col = 0,  -- 最左侧
--   width = 20,  -- 宽度
--   height = 1,  -- 高度
--   focusable = false,  -- 不可聚焦
--   style = 'minimal',  -- 最小化样式
--   border = 'none',  -- 无边框
--   noautocmd = true,  -- 阻止自动命令
-- })
-- vim.api.nvim_set_current_win(win)
return M

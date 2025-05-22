local Config=require("hc-coordinate.config")
local M={}
function M.fini()
end
local labels=vim.split("abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()","")
local function init_grid()
 local cursor_pos=vim.api.nvim_win_get_cursor(0)
 local row,col=cursor_pos[1],cursor_pos[2]
 local row0=row-1
 local ns_id=vim.api.nvim_create_namespace("coordinate_system")
 vim.api.nvim_buf_clear_namespace(0,ns_id,0,-1)
 local range=1
 vim.api.nvim_buf_set_extmark(0,ns_id,row0,col,{
  virt_text={{"0","Comment"}},
  virt_text_pos="overlay",
  hl_mode="combine",
 })
 local vcol=vim.fn.virtcol(".")
 local line_count=vim.api.nvim_buf_line_count(0)
 local pos0=vim.fn.screenpos(0,row,col)
 -- for i=-range,range do
 for i=-range,range do
  if i~=0 then
   local row_y=row0+i
   if row_y>1 and row_y<=line_count then
    local vcol_y=vim.fn.virtcol2col(0,row0,vcol)-1
    local pos_y=vim.fn.screenpos(0,row0,vcol_y)
     vim.api.nvim_buf_set_extmark(0,ns_id,row_y,vcol_y,{
      priority=1000, -- 汉汉汉汉汉汉
      strict=false,
      virt_text_pos="overlay",
      virt_text={
       {(" "):rep(0)},
       {labels[math.abs(i)],"Substitute"},
      },
     })
   end
   local len_x=#vim.fn.getline(row0+1)
   local col_x=col+i
   if col_x>=0 and col_x<=len_x then
    vim.api.nvim_buf_set_extmark(0,ns_id,row0,col_x,{
     virt_text={{labels[math.abs(i)],"Substitute"}},
     virt_text_pos="overlay",
     hl_mode="combine",
    })
   end
  end
 end
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

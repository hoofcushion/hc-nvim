local Config=require("hc-coordinate.config")
local M={}
function M.fini()
end
local labels=vim.split("abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()","")
local function get_nthchar_pos(line,nth)
 return
end
local function init_grid()
 local cursor_pos=vim.api.nvim_win_get_cursor(0)
 local row,col=cursor_pos[1]-1,cursor_pos[2]
 local ns_id=vim.api.nvim_create_namespace("coordinate_system")
 vim.api.nvim_buf_clear_namespace(0,ns_id,0,-1)
 local range=100
 vim.api.nvim_buf_set_extmark(0,ns_id,row,col,{
  virt_text={{"0","Comment"}},
  virt_text_pos="overlay",
  hl_mode="combine",
 })
 local vcol=vim.fn.virtcol(".")
 local line_count=vim.api.nvim_buf_line_count(0)
 for i=-range,range do
  if i~=0 then
   local row_y=row+i
   if row_y>1 and row_y<=line_count then
    local line_y=vim.fn.getline(row_y+1)
    local len_y=#line_y
    local col_y=math.max(col,vim.fn.virtcol2col(0,row_y+1,vcol-1))
    local blank_width=math.max(0,col_y-len_y)
    vim.api.nvim_buf_set_extmark(0,ns_id,row_y,col_y,{
     priority=1000,
     strict=false,
     virt_text_pos="overlay",
     virt_text={
      {(" "):rep(blank_width)},
      {labels[math.abs(i)],  "Substitute"},
     },
    })
   end
   local len_x=#vim.fn.getline(row+1)
   local col_x=col+i
   if col_x>=0 and col_x<=len_x then
    vim.api.nvim_buf_set_extmark(0,ns_id,row,col_x,{
     virt_text={{labels[math.abs(i)],"Substitute"}},
     virt_text_pos="overlay",
     hl_mode="combine",
    })
   end
  end
 end
end
function M.setup() -- 获取当前光标位置
 vim.keymap.set("n","<leader>cs",init_grid,{desc="Create coordinate system around cursor"})
end
M.setup()
init_grid()
return M

local function swap_win(win1,win2)
 local buf1=vim.api.nvim_win_get_buf(win1)
 local buf2=vim.api.nvim_win_get_buf(win2)
 vim.api.nvim_win_set_buf(win1,buf2)
 vim.api.nvim_win_set_buf(win2,buf1)
end
local window_picker=require("window-picker")
return {
 {
  name=NS.nvim_window_picker_goto_window,
  rhs=function()
   local win_id=window_picker.pick_window()
   if win_id~=nil then
    vim.api.nvim_set_current_win(win_id)
   end
  end,
 },
 {
  name=NS.nvim_window_picker_swap_window,
  rhs=function()
   local win1=window_picker.pick_window()
   if win1~=nil then
    local win2=window_picker.pick_window()
    if win2~=nil then
     swap_win(win1,win2)
    end
   end
  end,
 },
 {
  name=NS.nvim_window_picker_swap_window_with,
  rhs=function()
   local win1=vim.api.nvim_get_current_win()
   local win2=window_picker.pick_window()
   if win2~=nil then
    swap_win(win1,win2)
   end
  end,
 },
}

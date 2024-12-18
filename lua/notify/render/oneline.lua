local api=vim.api
local base=require("notify.render.base")
local Util=require("hc-nvim.util")
return function(bufnr,notif,highlights)
 local namespace=base.namespace()
 local icon=notif.icon
 local message={}
 Util.list_extend(message,notif.message)
 local prefix=icon..(notif.title[1] or "").." "
 message[1]=prefix..message[1]
 api.nvim_buf_set_lines(bufnr,0,-1,false,message)
 api.nvim_buf_set_extmark(bufnr,namespace,0,0,{
  hl_group=highlights.icon,
  end_col=#prefix-1,
  priority=50,
 })
end

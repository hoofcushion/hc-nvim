local toggleterm=require("toggleterm")
return {
 {name=NS.toggleterm_horizontal,rhs=function() toggleterm.toggle(nil,nil,vim.fn.expand("%:h"),"horizontal","Horizontal") end},
 {name=NS.toggleterm_vertical,  rhs=function() toggleterm.toggle(nil,nil,vim.fn.expand("%:h"),"vertical","Vertical") end},
 {name=NS.toggleterm_float,     rhs=function() toggleterm.toggle(nil,nil,vim.fn.expand("%:h"),"float","Float") end},
 {name=NS.toggleterm_tab,       rhs=function() toggleterm.toggle(nil,nil,vim.fn.expand("%:h"),"tab","Tab") end},
 {name=NS.toggleterm_file_dir,  rhs=function() toggleterm.exec_command("cmd=\"cd "..vim.fn.expand("%:p:h").."\"") end},
 {name=NS.toggleterm_cwd,       rhs=function() toggleterm.exec_command("cmd=\"cd "..vim.fn.getcwd().."\"") end},
 {name=NS.toggleterm_sendline,  rhs=function() toggleterm.send_lines_to_terminal("single_line",true,{args=vim.v.count}) end},
 {
  name=NS.toggleterm_sendselection,
  rhs=function()
   local aux={args=vim.v.count}
   if vim.api.nvim_get_mode().mode=="V" then
    toggleterm.send_lines_to_terminal("visual_lines",true,aux)
   else
    toggleterm.send_lines_to_terminal("visual_selection",true,aux)
   end
  end,
 },
}

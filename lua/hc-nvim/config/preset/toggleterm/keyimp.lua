local toggleterm=require("toggleterm")
local function create_cmd(main,arg)
 local cmd={main}
 for k,v in pairs(arg) do
  table.insert(cmd,("%s=%s"):format(k,v))
 end
 return table.concat(cmd," ")
end
return {
 {name=NS.toggleterm_horizontal,cmd=create_cmd("ToggleTerm",{direction="horizontal",name="Horizontal"})},
 {name=NS.toggleterm_vertical,  cmd=create_cmd("ToggleTerm",{direction="vertical",name="Vertical"})},
 {name=NS.toggleterm_float,     cmd=create_cmd("ToggleTerm",{direction="float",name="Float"})},
 {name=NS.toggleterm_tab,       cmd=create_cmd("ToggleTerm",{direction="tab",name="Tab"})},
 {name=NS.toggleterm_file_dir,  cmd=create_cmd("TermExec",{cmd=("%q"):format(vim.fn.shellescape("cd "..vim.fn.expand("%:p:h")))})},
 {name=NS.toggleterm_cwd,       cmd=create_cmd("TermExec",{cmd=("%q"):format(vim.fn.shellescape("cd "..vim.fn.getcwd()))})},
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

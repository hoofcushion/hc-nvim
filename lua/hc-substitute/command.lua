local Util=require("hc-nvim.util")
local M=require("hc-substitute.init_space")
local commands={
 {"HCPaste",
  function(cmd)
   if cmd.args~="" then
    M.Opfunc.start(M.paste_opfunc,cmd.args)
   elseif cmd.range~=0 then
    M.paste(Util.RangeMark:get_line(cmd.line1-1,cmd.line2-cmd.line1))
   end
  end,
  {nargs="?",range=true}},
 {"HCExchange",
  function(cmd)
   if cmd.args~="" then
    M.Opfunc.start(M.exchange_opfunc,cmd.args)
   elseif cmd.range~=0 then
    M.exchange(Util.RangeMark:get_line(cmd.line1-1,cmd.line2-cmd.line1))
   end
  end,
  {nargs="?",range=true}},
}
local Command={}
function Command.setup()
 --- 1. paste_op if has arg
 --- 2, paste_visual if has range
 for _,cmd in ipairs(commands) do
  vim.api.nvim_create_user_command(cmd[1],cmd[2],cmd[3])
 end
end
function Command.fini()
 for _,cmd in ipairs(commands) do
  vim.api.nvim_del_user_command(cmd[1])
 end
end
return Command

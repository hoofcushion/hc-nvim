local api=vim.api
local fn=vim.fn
local function feedkeys(keys,mode)
 vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys,true,false,true),mode,false)
end
local Util=require("hc-nvim.util")
local Config=require("hc-substitute.config")
--- ---
--- OpFunc imp.
--- ---
local OpFunc={}
function OpFunc.set(opfunc,args)
 if args~=nil then
  local _=opfunc
  opfunc=function(vmode)
   _(vmode,unpack(args))
  end
 end
 _G.opfunc=opfunc
 vim.o.opfunc=[[v:lua.opfunc]]
end
--- Set opfunc then start operator mode with a initial motion
function OpFunc.start(opfunc,motion,...)
 OpFunc.set(opfunc,{...})
 feedkeys("g@"..(motion or ""),"n")
end
--- ---
--- Main
--- ---
local M={}
local opfunc_vmode_map={
 char="v",
 line="V",
 block="",
}
---@param marks RangeMark[]
---@param delay integer
---@param hl_group string
---@param hl_opts vim.api.keyset.highlight
local function blink(marks,delay,hl_group,hl_opts)
 local ns=api.nvim_create_namespace("hc-substitute-blink")
 local callback=vim.schedule_wrap(function()
  api.nvim_buf_clear_namespace(0,ns,0,-1)
 end)
 local timer=vim.uv.new_timer()
 if timer~=nil then
  timer:start(delay,0,function()
   callback()
   timer:close()
  end)
 else
  api.nvim_create_autocmd(
   {"CursorHold","CursorHoldI","CursorMoved","CursorMovedI"},
   {once=true,callback=callback}
  )
 end
 for _,mark in ipairs(marks) do
  mark:highlight(hl_group,hl_opts,ns)
 end
end
blink=vim.schedule_wrap(blink)
---@param mark RangeMark
---@param opts Substitute.config.paste?
function M.paste(mark,opts)
 opts=Config.get(Config.current.paste,opts)
 local reg=Util.Register.current
 mark:put(reg)
 if opts.highlight.enabled then
  blink(
   {mark},
   opts.highlight.blink_delay,
   opts.highlight.hl_group,
   opts.highlight.hl_opts
  )
 end
 if opts.end_pos=="finish" then
  mark:set_cursor("finish")
 end
end
---@param opts Substitute.config.paste?
function M.paste_opfunc(vmode,opts)
 local mark=Util.RangeMark:get_mark("[","]",opfunc_vmode_map[vmode])
 M.paste(mark,opts)
end
---@param opts Substitute.config.paste?
function M.paste_op(opts)
 OpFunc.start(M.paste_opfunc,nil,opts)
end
---@param opts Substitute.config.paste?
function M.paste_eol(opts)
 OpFunc.start(M.paste_opfunc,"$",opts)
end
---@param opts Substitute.config.paste?
function M.paste_line(opts)
 M.paste(
  Util.RangeMark:get_line(nil,vim.v.count),
  opts
 )
end
---@param opts Substitute.config.paste?
function M.paste_visual(opts)
 M.paste(Util.RangeMark:get_selection(),opts)
 feedkeys("<esc>","nx")
end
local exchange_ns=api.nvim_create_namespace("hc-substitute-exchange")
---@type RangeMark?
local mark_start=nil
---@param mark RangeMark
---@param opts Substitute.config.exchange?
function M.exchange(mark,opts)
 if mark==nil then
  M.exchange_cancel()
  return false
 end
 opts=Config.get(Config.current.exchange,opts)
 if mark_start==nil then
  mark_start=mark
  if opts.highlight.enabled then
   mark:highlight(
    opts.highlight.hl_group,
    opts.highlight.hl_opts,
    exchange_ns
   )
  end
  return true
 end
 if mark_start:exchange(mark)==false then
  return true
 end
 --- Blink
 if opts.highlight.enabled then
  blink(
   {mark_start,mark},
   opts.highlight.blink_delay,
   opts.highlight.hl_group,
   opts.highlight.hl_opts
  )
 end
 --- Move to the end mark
 local end_mark=opts.end_mark=="start" and mark_start or mark
 if opts.end_select[mark.vmode] then
  vim.schedule(function()
   end_mark:select()
  end)
 else
  end_mark:set_cursor(opts.end_pos)
 end
 M.exchange_cancel()
 return true
end
function M.exchange_cancel()
 mark_start=nil
 api.nvim_buf_clear_namespace(0,exchange_ns,0,-1)
end
---@param vmode visualmode
---@param opts Substitute.config.exchange?
function M.exchange_opfunc(vmode,opts)
 M.exchange(Util.RangeMark:get_mark("[","]",opfunc_vmode_map[vmode]),opts)
end
---@param opts Substitute.config.exchange?
function M.exchange_op(opts)
 OpFunc.start(M.exchange_opfunc,nil,opts)
end
---@param opts Substitute.config.exchange?
function M.exchange_eol(opts)
 OpFunc.start(M.exchange_opfunc,"$",opts)
end
---@param opts Substitute.config.exchange?
function M.exchange_line(opts)
 M.exchange(
  Util.RangeMark:get_line(nil,vim.v.count),
  opts
 )
end
---@param opts Substitute.config.exchange?
function M.exchange_visual(opts)
 local ok=M.exchange(Util.RangeMark:get_selection(),opts)
 if ok then
  feedkeys("<esc>","nx")
 end
end
---@param mark RangeMark
function M.substitute(mark)
 local pattern=table.concat(mark:yank().regcontents,"\\n")
 pattern="\\V"..fn.escape(pattern,"/\\")
 local cmd=string.format(":s/%s/",pattern)
 feedkeys(cmd,"nx")
end
---@param vmode visualmode
function M.substitute_opfunc(vmode)
 M.substitute(Util.RangeMark:get_mark("[","]",opfunc_vmode_map[vmode]))
end
function M.substitute_op()
 OpFunc.start(M.substitute_opfunc)
end
function M.substitute_visual()
 M.substitute(Util.RangeMark:get_selection())
end
local commands={
 {"HCPaste",
  function(cmd)
   if cmd.args~="" then
    OpFunc.start(M.paste_opfunc,cmd.args)
   elseif cmd.range~=0 then
    M.paste(Util.RangeMark:get_line(cmd.line1-1,cmd.line2-cmd.line1))
   end
  end,
  {nargs="?",range=true}},
 {"HCExchange",
  function(cmd)
   if cmd.args~="" then
    OpFunc.start(M.exchange_opfunc,cmd.args)
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
  api.nvim_create_user_command(cmd[1],cmd[2],cmd[3])
 end
end
function Command.fini()
 for _,cmd in ipairs(commands) do
  api.nvim_del_user_command(cmd[1])
 end
end
--- setup is optional since default options works perfectly
---@param opts Substitute.config
function M.setup(opts)
 Config.setup(opts)
 Command.setup()
end
function M.fini()
 Config.fini()
 Command.fini()
end
return M

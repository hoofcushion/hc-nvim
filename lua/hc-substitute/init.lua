--- ---
--- Shortcuts
--- ---
local api=vim.api
local fn=vim.fn
local Util=require("hc-nvim.util")
local RangeMark=Util.RangeMark
local function feedkeys(keys,mode)
 vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys,true,false,true),mode,false)
end
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
local Options={}
---@class Substitute.options
Options.default={
 command=false,
 ---@class Substitute.options.paste
 paste={
  ---@type "start"|"finish"|"cursor_s"|"cursor_e"
  end_pos="cursor_s",
  highlight={
   enabled=true,
   blink_delay=500,
   hl_group="SubstituteBlink",
   hl_opts={link="Substitute"},
  },
 },
 ---@class Substitute.options.exchange
 exchange={
  ---@type "start"|"finish"|"cursor_s"|"cursor_e"
  end_pos="cursor_e",
  ---@type "start"|"finish"|"cursor_s"|"cursor_e"
  end_mark="finish",
  ---@type table<"v"|"V"|"",boolean>
  end_select={
   v=false,
   V=false,
   [""]=false,
  },
  highlight={
   enabled=true,
   blink_delay=500,
   hl_group="SubstituteBlink",
   hl_opts={link="Substitute"},
  },
 },
}
Options.current=Options.default
local Validate=require("hc-nvim.util.validate")
local valitab={
 command="boolean",
 paste={
  end_pos=Validate.mkenum("start","finish","cursor_s","cursor_e"),
  highlight={
   enabled="boolean",
   blink_delay="integer",
   hl_group="string",
   hl_opts="table",
  },
 },
 exchange={
  end_pos=Validate.mkenum("start","finish","cursor_s","cursor_e"),
  end_mark=Validate.mkenum("start","finish","cursor_s","cursor_e"),
  end_select={
   v="boolean",
   V="boolean",
   [""]="boolean",
  },
  highlight={
   enabled="boolean",
   blink_delay="integer",
   hl_group="string",
   hl_opts="table",
  },
 },
}
--- Set options.
--- if opts is nil, reset to default options.
--- else, update opts into current options.
---@param opts Substitute.options
function Options.setup(opts)
 local new_options=vim.tbl_deep_extend("force",Options.current,opts)
 Validate.validate_assert("<hc-substitute>.options",new_options,valitab)
 Options.current=new_options
end
function Options.fini()
 Options.current=Options.default
end
---@generic T
---@param default T
---@param opts table?
---@return T
function Options.get(default,opts)
 opts=(opts~=nil
  and vim.tbl_deep_extend("force",default,opts)
  or default)
 return opts
end
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
---@param opts Substitute.options.paste?
function M.paste(mark,opts)
 opts=Options.get(Options.current.paste,opts)
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
---@param opts Substitute.options.paste?
function M.paste_opfunc(vmode,opts)
 local mark=RangeMark:get_mark("[","]",opfunc_vmode_map[vmode])
 M.paste(mark,opts)
end
---@param opts Substitute.options.paste?
function M.paste_op(opts)
 OpFunc.start(M.paste_opfunc,nil,opts)
end
---@param opts Substitute.options.paste?
function M.paste_eol(opts)
 OpFunc.start(M.paste_opfunc,"$",opts)
end
---@param opts Substitute.options.paste?
function M.paste_line(opts)
 M.paste(
  RangeMark:get_line(nil,vim.v.count),
  opts
 )
end
---@param opts Substitute.options.paste?
function M.paste_visual(opts)
 M.paste(RangeMark:get_selection(),opts)
 feedkeys("<esc>","nx")
end
local exchange_ns=api.nvim_create_namespace("hc-substitute-exchange")
---@type RangeMark?
local mark_start=nil
---@param mark RangeMark
---@param opts Substitute.options.exchange?
function M.exchange(mark,opts)
 if mark==nil then
  M.exchange_cancel()
  return false
 end
 opts=Options.get(Options.current.exchange,opts)
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
---@param opts Substitute.options.exchange?
function M.exchange_opfunc(vmode,opts)
 M.exchange(RangeMark:get_mark("[","]",opfunc_vmode_map[vmode]),opts)
end
---@param opts Substitute.options.exchange?
function M.exchange_op(opts)
 OpFunc.start(M.exchange_opfunc,nil,opts)
end
---@param opts Substitute.options.exchange?
function M.exchange_eol(opts)
 OpFunc.start(M.exchange_opfunc,"$",opts)
end
---@param opts Substitute.options.exchange?
function M.exchange_line(opts)
 M.exchange(
  RangeMark:get_line(nil,vim.v.count),
  opts
 )
end
---@param opts Substitute.options.exchange?
function M.exchange_visual(opts)
 local ok=M.exchange(RangeMark:get_selection(),opts)
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
 M.substitute(RangeMark:get_mark("[","]",opfunc_vmode_map[vmode]))
end
function M.substitute_op()
 OpFunc.start(M.substitute_opfunc)
end
function M.substitute_visual()
 M.substitute(RangeMark:get_selection())
end
local commands={
 {"HCPaste",
  function(cmd)
   if cmd.args~="" then
    OpFunc.start(M.paste_opfunc,cmd.args)
   elseif cmd.range~=0 then
    M.paste(RangeMark:get_line(cmd.line1-1,cmd.line2-cmd.line1))
   end
  end,
  {nargs="?",range=true}},
 {"HCExchange",
  function(cmd)
   if cmd.args~="" then
    OpFunc.start(M.exchange_opfunc,cmd.args)
   elseif cmd.range~=0 then
    M.exchange(RangeMark:get_line(cmd.line1-1,cmd.line2-cmd.line1))
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
---@param opts Substitute.options
function M.setup(opts)
 Options.setup(opts)
 Command.setup()
end
function M.fini()
 Options.fini()
 Command.fini()
end
function M.get_config()
 return Options.current
end
return M

local HCNvim=require("hc-nvim.init_space")
--- ---
--- Main
--- ---
---@class HC-Substitute
local HCSubstitute=require("hc-substitute.init_space")
---@generic T
---@param init fun():T
---@param set? fun(t:T)
---@return T
function HCSubstitute.lazy(init,set)
 set=set or function() end
 local l=setmetatable({},{
  __index=function(_,k)
   local t=init()
   set(t)
   return t[k]
  end,
 })
 set(l)
 return l
end
HCSubstitute.lazy(function() return require("hc-substitute.config") end,  function(t) HCSubstitute.Config=t end)
HCSubstitute.lazy(function() return require("hc-substitute.util") end,    function(t) HCSubstitute.Util=t end)
HCSubstitute.lazy(function() return require("hc-substitute.opfunc") end,  function(t) HCSubstitute.OpFunc=t end)
HCSubstitute.lazy(function() return require("hc-substitute.commands") end,function(t) HCSubstitute.Command=t end)
local opfunc_vmode_map={
 char="v",
 line="V",
 block="\22",
}
---@param marks RangeMark[]
---@param delay integer
---@param hl_group string
---@param hl_opts vim.api.keyset.highlight
local function blink(marks,delay,hl_group,hl_opts)
 local ns=vim.api.nvim_create_namespace("hc-substitute-blink")
 local callback=vim.schedule_wrap(function()
  vim.api.nvim_buf_clear_namespace(0,ns,0,-1)
 end)
 local timer=vim.uv.new_timer()
 if timer~=nil then
  timer:start(delay,0,function()
   callback()
   timer:close()
  end)
 else
  vim.api.nvim_create_autocmd(
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
function HCSubstitute.paste(mark,opts)
 opts=HCSubstitute.Config.get(HCSubstitute.Config.current.paste,opts)
 local reg=HCNvim.Util.Register.current
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
function HCSubstitute.paste_opfunc(vmode,opts)
 local mark=HCNvim.Util.RangeMark:get_mark("[","]",opfunc_vmode_map[vmode])
 HCSubstitute.paste(mark,opts)
end
---@param opts Substitute.config.paste?
function HCSubstitute.paste_op(opts)
 HCSubstitute.OpFunc.start(HCSubstitute.paste_opfunc,nil,opts)
end
---@param opts Substitute.config.paste?
function HCSubstitute.paste_eol(opts)
 HCSubstitute.OpFunc.start(HCSubstitute.paste_opfunc,"$",opts)
end
---@param opts Substitute.config.paste?
function HCSubstitute.paste_line(opts)
 HCSubstitute.paste(
  HCNvim.Util.RangeMark:get_line(nil,vim.v.count),
  opts
 )
end
---@param opts Substitute.config.paste?
function HCSubstitute.paste_visual(opts)
 HCSubstitute.paste(HCNvim.Util.RangeMark:get_selection(),opts)
 HCSubstitute.Util.feedkeys("<esc>","nx")
end
local exchange_ns=vim.api.nvim_create_namespace("hc-substitute-exchange")
---@type RangeMark?
local mark_start=nil
---@param mark RangeMark
---@param opts Substitute.config.exchange?
function HCSubstitute.exchange(mark,opts)
 if mark==nil then
  HCSubstitute.exchange_cancel()
  return false
 end
 opts=HCSubstitute.Config.get(HCSubstitute.Config.current.exchange,opts)
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
 HCSubstitute.exchange_cancel()
 return true
end
function HCSubstitute.exchange_cancel()
 mark_start=nil
 vim.api.nvim_buf_clear_namespace(0,exchange_ns,0,-1)
end
---@param vmode visualmode
---@param opts Substitute.config.exchange?
function HCSubstitute.exchange_opfunc(vmode,opts)
 HCSubstitute.exchange(HCNvim.Util.RangeMark:get_mark("[","]",opfunc_vmode_map[vmode]),opts)
end
---@param opts Substitute.config.exchange?
function HCSubstitute.exchange_op(opts)
 HCSubstitute.OpFunc.start(HCSubstitute.exchange_opfunc,nil,opts)
end
---@param opts Substitute.config.exchange?
function HCSubstitute.exchange_eol(opts)
 HCSubstitute.OpFunc.start(HCSubstitute.exchange_opfunc,"$",opts)
end
---@param opts Substitute.config.exchange?
function HCSubstitute.exchange_line(opts)
 HCSubstitute.exchange(
  HCNvim.Util.RangeMark:get_line(nil,vim.v.count),
  opts
 )
end
---@param opts Substitute.config.exchange?
function HCSubstitute.exchange_visual(opts)
 local ok=HCSubstitute.exchange(HCNvim.Util.RangeMark:get_selection(),opts)
 if ok then
  HCSubstitute.Util.feedkeys("<esc>","nx")
 end
end
---@param mark RangeMark
function HCSubstitute.substitute(mark)
 local pattern=table.concat(mark:yank().regcontents,"\\n")
 pattern="\\V"..vim.fn.escape(pattern,"/\\")
 local cmd=string.format(":s/%s/",pattern)
 HCSubstitute.Util.feedkeys(cmd,"n")
end
---@param vmode visualmode
function HCSubstitute.substitute_opfunc(vmode)
 HCSubstitute.substitute(HCNvim.Util.RangeMark:get_mark("[","]",opfunc_vmode_map[vmode]))
end
function HCSubstitute.substitute_op()
 HCSubstitute.OpFunc.start(HCSubstitute.substitute_opfunc)
end
function HCSubstitute.substitute_visual()
 HCSubstitute.substitute(HCNvim.Util.RangeMark:get_selection())
end
--- setup is optional since default options works perfectly
---@param opts Substitute.config
function HCSubstitute.setup(opts)
 HCSubstitute.Config.setup(opts)
 HCSubstitute.Command.setup()
end
function HCSubstitute.fini()
 HCSubstitute.Config.fini()
 HCSubstitute.Command.fini()
end
return HCSubstitute

local N=require("hc-func.init_space")
local Util=require("hc-nvim.util")
local TogglerAu=Util.ConductedAutocmd.new()
local Options=N.Config.options.toggler
---@type HCFunc.toggler.rule
local Rules=setmetatable({},{
 __index=function(t,name)
  return Util.Fallback.create(Options.rule.default,Options.rule[name])
 end,
})
local function check_bo(rules,name)
 return rules[name][vim.bo[name]]~=false
end
local function get_target(func_name,buf)
 if vim.api.nvim_buf_is_loaded(buf)==false then
  return
 end
 local rule=Rules[func_name]
 if check_bo(rule,"filetype")==false
 or check_bo(rule,"buftype")==false
 then
  return false
 end
 local cond=rule.cond
 if cond~=nil and not cond(buf) then
  return false
 end
 local size=vim.api.nvim_buf_get_offset(buf,vim.api.nvim_buf_line_count(buf))/2^10
 local range=rule.size_kb
 if size<range[1] or range[2]<size then
  return false
 end
 return true
end
TogglerAu:add({
 {{"BufEnter","BufWrite"},{
  callback=function(event)
   for name,toggler in pairs(N.Function.togglers) do
    if  name~="toggler"
    and toggler.enable
    then
     N.Function.suspend(name,get_target(name,event.buf))
    end
   end
  end,
 }},
})
TogglerAu:add({
 {{"FocusLost","FocusGained"},{
  callback=function(event)
   for name,toggler in pairs(N.Function.togglers) do
    if  name~="toggler"
    and toggler.enable
    and Rules[name].auto_suspend
    then
     N.Function.suspend(name,event.event=="FocusGained")
    end
   end
  end,
 }},
})
local M={}
function M.activate()
 TogglerAu:activate()
end
function M.deactivate()
 TogglerAu:deactivate()
end
function M.disable()
 TogglerAu:disable()
end
function M.enable()
 TogglerAu:enable()
end
return M

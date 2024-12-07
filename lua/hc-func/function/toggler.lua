local Config=require("hc-func.config")
local Function=require("hc-func.function")
local Util=require("hc-nvim.util")
local TogglerAu=Util.Autocmd.new()
local Options=Config.options.toggler
--- Short cut to get entries from functionalities name
---@type HCFunc.toggler.rule
local TogglerRules=Util.Cache.table(function(name)
 return Util.Fallback.create(Options.rule.default,Options.rule[name])
end)
local function check_bo(rules,name)
 return rules[name][vim.bo[name]]~=false
end
local function get_target(func_name,buf)
 if vim.api.nvim_buf_is_loaded(buf)==false then
  return
 end
 local rules=TogglerRules[func_name]
 if check_bo(rules,"filetype")==false
 or check_bo(rules,"buftype")==false
 then
  return false
 end
 local cond=rules.cond
 if cond~=nil and not cond(buf) then
  return false
 end
 local size=vim.api.nvim_buf_get_offset(buf,vim.api.nvim_buf_line_count(buf))/2^10
 local range=rules.size_kb
 if size<range[1] or range[2]<size then
  return false
 end
 return true
end
TogglerAu:add({
 {{"BufEnter","BufWrite"},{
  callback=function(event)
   for func_name,status in pairs(Function.statuses) do
    if not (func_name=="toggler"
     or status.enable==false
     or status.suspend==true)
    then
     goto continue
    end
    Function.activate(func_name,get_target(func_name,event.buf))
    ::continue::
   end
  end,
 }},
})
TogglerAu:add({
 {{"FocusLost","FocusGained"},{
  callback=function(event)
   for name,status in pairs(Function.statuses) do
    if name=="toggler"
    or status.enable==false
    or TogglerRules[name].auto_suspend==false
    then
     goto continue
    end
    status.suspend=event.event=="FocusLost"
    Function.activate(name,event.event=="FocusGained")
    ::continue::
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
 TogglerAu:delete()
end
function M.enable()
 TogglerAu:create()
end
return M

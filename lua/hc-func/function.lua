---@class HCFunc.function.context
---@field bufnr integer
---@field winnr integer
---@field tabnr integer
---@class HCFunc.function.main
---@field enable function
---@field disable function
---@field activate function
---@field deactivate function
---@class HCFunc.function.status
---@field enable boolean
---@field active boolean
---@field suspend boolean

local Util=require("hc-nvim.util")
local Config=require("hc-func.config")
local M={}
local modules=Util.LazyTab.from(function()
 ---@enum (key) HCFunc.function.modname
 local ret={
  cursorword        =require("hc-func.function.cursorword"),
  rainbowcursor     =require("hc-func.function.rainbowcursor"),
  toggler           =require("hc-func.function.toggler"),
  document_highlight=require("hc-func.function.document_highlight"),
  code_lens         =require("hc-func.function.code_lens"),
  auto_format       =require("hc-func.function.auto_format"),
 }
 return ret
end)
M.modules=modules
---@class HCFunc.function.func
local Func={
 modname="",
 option={},
 status={enable=false,active=false,suspend=false},
}
function Func:activate(bool)
 if self.status.active==bool then
  return
 end
 if bool==nil then
  bool=not self.status.active
 end
 local mod=modules[self.modname]
 local ok,msg=pcall(bool and mod.activate or mod.deactivate)
 if not ok and msg then
  vim.notify(msg,vim.log.levels.ERROR)
  return
 end
 self.status.active=bool
end
function Func:enable(bool)
 if self.status.enable==bool then
  return
 end
 if bool==nil then
  bool=not self.status.enable
 end
 local mod=modules[self.modname]
 local ok,msg=pcall(bool and mod.enable or mod.disable)
 if not ok and msg then
  vim.notify(msg,vim.log.levels.ERROR)
  return
 end
 self.status.enable=bool
end
function Func.new(modname)
 local obj=setmetatable({},{__index=Func})
 obj.modname=modname
 obj.option=Config.options[modname]
 obj.status={enable=false,active=false,suspend=false}
 return obj
end
---@type table<HCFunc.function.modname,HCFunc.function.func>
M.funcs={}
---@param name HCFunc.function.modname
---@param target boolean|nil
function M.activate(name,target)
 M.funcs[name]:activate(target)
end
---@param name HCFunc.function.modname
---@param target boolean|nil
function M.enable(name,target)
 M.funcs[name]:enable(target)
end
function M.fini()
 for _,func in pairs(M.funcs) do
  func:enable(false)
  func:activate(false)
 end
end
function M.setup()
 for modname in Util.iter_mod("hc-func.function") do
  modname=Util.str_cut_r(modname,".",true)
  M.funcs[modname]=Func.new(modname)
 end
 for _,func in pairs(M.funcs) do
  func:enable(func.option.enabled)
  func:activate(func.option.enabled)
 end
end
return M

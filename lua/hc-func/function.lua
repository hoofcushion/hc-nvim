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
---@enum (key) HCFunc.function.modname
local modnames={
 cursorword="hc-func.function.cursorword",
 rainbowcursor="hc-func.function.rainbowcursor",
 toggler="hc-func.function.toggler",
 document_highlight="hc-func.function.document_highlight",
 code_lens="hc-func.function.code_lens",
 auto_format="hc-func.function.auto_format",
}
---@type table<HCFunc.function.modname,HCFunc.function.main>
local functionality=Util.LazyTab.create(modnames)
local statuses={}
for name in pairs(modnames) do
 statuses[name]={enable=false,active=false,suspend=false}
end
local M={}
---@type table<HCFunc.function.modname,HCFunc.function.status>
M.statuses=statuses
---@class HCFunc.function.funcs
---@field [HCFunc.function.modname] HCFunc.function.func
local funcs={}
for modname in pairs(modnames) do
 ---@class HCFunc.function.func
 local func={
  status=M.statuses[modname],
  activate=function()
   M.activate(modname,true)
  end,
  deactivate=function()
   M.activate(modname,false)
  end,
  setup=function()
   M.enable(modname,true)
   M.activate(modname,true)
  end,
  fini=function()
   M.enable(modname,false)
   M.activate(modname,false)
  end,
 }
 funcs[modname]=func
end
M.funcs=funcs
---@param name HCFunc.function.modname
---@param target boolean|nil
function M.activate(name,target)
 local status=M.statuses[name]
 local current=status.active
 if target==current then return end
 if target==nil then target=not current end
 local func=functionality[name]
 if target==false then
  func.deactivate()
  status.active=target
 elseif status.enable then
  func.activate()
  status.active=target
 end
end
---@param name HCFunc.function.modname
---@param target boolean|nil
function M.enable(name,target)
 local status=M.statuses[name]
 local current=status.enable
 if target==current then return end
 if target==nil then target=not current end
 local func=functionality[name]
 if target then
  func.enable()
 else
  func.disable()
 end
 status.enable=target
end
function M.fini()
 for name in pairs(M.statuses) do
  M.funcs[name].fini()
 end
end
function M.setup()
 for name in pairs(M.statuses) do
  if Config.options[name].enabled then
   M.funcs[name].setup()
  end
 end
end
return M

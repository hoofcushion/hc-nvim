local N=require("hc-func.init_space")
---@class HC-Func.Function.context
---@field bufnr integer
---@field winnr integer
---@field tabnr integer

---@class HC-Func.Function.main
---@field enable function
---@field disable function
---@field activate function
---@field deactivate function

---@class HC-Func.Function.status
---@field enable boolean
---@field active boolean
---@field suspend boolean

---@class HC-Func.Function
local Function={}
---@type table<string,HC-Func.Function.status>
Function.togglers={}
---激活或停用模块功能
---@param name string
---@param target boolean|nil
function Function.activate(name,target)
 local toggler=Function.togglers[name]
 if not toggler then
  return
 end
 if target==nil then
  target=not toggler.active
 end
 if toggler.active==target then
  return
 end
 toggler.active=target
 local mod=N.Module[name]
 local ok,msg=pcall(target and mod.activate or mod.deactivate)
 if not ok and msg then
  vim.notify(msg,vim.log.levels.ERROR)
  return
 end
end
---启用或禁用模块
---@param name string
---@param target boolean|nil
function Function.enable(name,target)
 local toggler=Function.togglers[name]
 if not toggler then
  return
 end
 if target==nil then
  target=not toggler.enable
 end
 if toggler.enable==target then
  return
 end
 toggler.enable=target
 local mod=N.Module[name]
 local ok,msg=pcall(target and mod.enable or mod.disable)
 if not ok and msg then
  vim.notify(msg,vim.log.levels.ERROR)
  return
 end
end
---挂起或恢复模块
---@param name string
---@param target boolean|nil
function Function.suspend(name,target)
 local toggler=Function.togglers[name]
 if not toggler then
  return
 end
 if target==nil then
  target=not toggler.suspend
 end
 if toggler.suspend==target then
  return
 end
 toggler.suspend=target
 Function.activate(name,target)
end
function Function.fini()
 for name,func in pairs(Function.togglers) do
  Function.enable(name,false)
  Function.activate(name,false)
 end
end
function Function.setup()
 for modname in pairs(N.Module) do
  Function.togglers[modname]={enable=false,active=false,suspend=false}
 end
 for name in pairs(N.Module) do
  local target=N.Config.options[name].enabled
  Function.enable(name,target)
  Function.activate(name,target)
 end
end
return Function

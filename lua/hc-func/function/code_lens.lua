local function refesh_codelens(...)
 if vim.lsp.get_clients({bufnr=0,method="textDocument/codeLens"}) then
  vim.lsp.codelens.refresh(...)
 end
end
local Util=require("hc-func.util")
local LocalVars=Util.LocalVars.create()
local CodeLensAu=Util.Autocmd.new()
CodeLensAu:add({
 {"BufWritePre",{
  callback=function(event)
   if vim.bo.modified then
    refesh_codelens({bufnr=event.buf})
   end
  end,
 }},
 {{"InsertLeave","BufEnter","CursorHold"},{
  callback=function(event)
   local b=vim.b
   if b.changedtick~=b.lastchangedtick then
    refesh_codelens({bufnr=event.buf})
   end
   b.lastchangedtick=b.changedtick
  end,
 }},
})
local M={}
function M.activate()
 CodeLensAu:activate()
end
function M.deactivate()
 CodeLensAu:deactivate()
end
function M.enable()
 CodeLensAu:create()
end
function M.disable()
 CodeLensAu:delete()
 LocalVars:reset()
end
return M

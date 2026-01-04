local Util=require("hc-nvim.util")
local LocalEnv=Util.LocalEnv.new()
local CodeLensAu=Util.ConductedAutocmd.new()
local function refesh_codelens(opts)
 if vim.lsp.get_clients({bufnr=0,method="textDocument/codeLens"}) then
  vim.lsp.codelens.refresh(opts)
 end
end
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
   local b=LocalEnv.buffer
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
 CodeLensAu:enable()
end
function M.disable()
 CodeLensAu:disable()
 LocalEnv:reset()
end
return M

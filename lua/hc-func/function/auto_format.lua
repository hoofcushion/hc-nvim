local method="textDocument/formatting"
local Config=require("hc-func.config")
local Options=Config.options.auto_format
local Util=require("hc-func.util")
local AutoFormatAu=Util.Autocmd.new()
AutoFormatAu:add({
 {"BufWritePre",{
  callback=function(event)
   local buf=event.buf
   if vim.bo[buf].modified==false then
    return
   end
   if next(vim.lsp.get_clients({bufnr=buf,method=method}))==nil then
    return
   end
   local opts=vim.deepcopy(Options.opts)
   opts.bufnr=buf
   vim.lsp.buf.format(opts)
  end,
 }},
})
local M={}
function M.activate()
 AutoFormatAu:activate()
end
function M.deactivate()
 AutoFormatAu:deactivate()
end
function M.enable()
 AutoFormatAu:create()
end
function M.disable()
 AutoFormatAu:delete()
end
return M

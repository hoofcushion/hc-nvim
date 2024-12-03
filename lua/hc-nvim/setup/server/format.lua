local Config=require("hc-nvim.config")
if Config.platform.is_vscode then
 return vim.lsp.buf.format
end
local function format(opts)
 if opts==nil then
  opts={}
 end
 local buf=vim.api.nvim_get_current_buf()
 local mode=vim.fn.mode()
 local range=mode=="v" or mode=="V"
 local method=range and "textDocument/rangeFormatting" or "textDocument/formatting"
 local clients=vim.lsp.get_clients({
  bufnr=buf,
  method=method,
 })
 if #clients==0 then
  return
 end
 if #clients==1 then
  vim.lsp.buf.format({name=clients[1].name})
  return
 end
 if vim.b.lsp_format_choice then
  vim.lsp.buf.format({name=vim.b.lsp_format_choice})
  return
 end
 vim.ui.select(
  clients,
  {
   prompt="Select a client",
   format_item=function(item) return item.name end,
  },
  function(choice)
   local name=choice and choice.name or clients[1].name
   vim.b.lsp_format_choice=name
   vim.lsp.buf.format({name=name})
  end
 )
end
return format

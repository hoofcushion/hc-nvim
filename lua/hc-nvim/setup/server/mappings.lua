local N=require("hc-nvim.init_space")
---@param cap string
local function has_cap(cap)
 return function()
  local buf=vim.api.nvim_get_current_buf()
  return vim.lsp.get_clients({method=cap,bufnr=buf})[1]~=nil
 end
end
local function has_client(name)
 return function()
  local client=vim.lsp.get_clients({name=name})[1]
  return client~=nil
 end
end
return {
 {name=NS.lsp_codeAction,             rhs=vim.lsp.buf.code_action,                                                      cond=has_cap("textDocument/codeAction")},
 {name=NS.lsp_declaration,            rhs=vim.lsp.buf.declaration,                                                      cond=has_cap("textDocument/declaration")},
 {name=NS.lsp_definition,             rhs=vim.lsp.buf.definition,                                                       cond=has_cap("textDocument/definition")},
 {name=NS.lsp_diagnostic_next,        rhs=N.Util.Wrapper.fn_eval(vim.diagnostic.jump,{count=1})},
 {name=NS.lsp_diagnostic_previous,    rhs=N.Util.Wrapper.fn_eval(vim.diagnostic.jump,{count=-1})},
 {name=NS.lsp_diagnostic_toggle,      rhs=N.Util.Wrapper.fn_eval(vim.diagnostic.enable,vim.diagnostic.is_enabled,true)},
 {name=NS.lsp_document_symbols,       rhs=vim.lsp.buf.document_symbol,                                                  cond=has_cap("textDocument/documentSymbol")},
 {name=NS.lsp_formatting,             rhs=require("hc-nvim.util.function.format"),                                      cond=has_cap("textDocument/formatting")},
 {name=NS.lsp_hover,                  rhs=vim.lsp.buf.hover,                                                            cond=has_cap("textDocument/hover")},
 {name=NS.lsp_implementation,         rhs=vim.lsp.buf.implementation,                                                   cond=has_cap("textDocument/implementation")},
 {name=NS.lsp_incoming_calls,         rhs=vim.lsp.buf.incoming_calls,                                                   cond=has_cap("callHierarchy/incomingCalls")},
 {name=NS.lsp_outgoing_calls,         rhs=vim.lsp.buf.outgoing_calls,                                                   cond=has_cap("callHierarchy/outgoingCalls")},
 {name=NS.lsp_references,             rhs=vim.lsp.buf.references,                                                       cond=has_cap("textDocument/references")},
 {name=NS.lsp_rename,                 rhs=vim.lsp.buf.rename,                                                           cond=has_cap("textDocument/rename")},
 {name=NS.lsp_signatureHelp,          rhs=vim.lsp.buf.signature_help,                                                   cond=has_cap("textDocument/signatureHelp")},
 {name=NS.lsp_typeDefinition,         rhs=vim.lsp.buf.type_definition,                                                  cond=has_cap("textDocument/typeDefinition")},
 {name=NS.lsp_workspace_add_folder,   rhs=vim.lsp.buf.add_workspace_folder,                                             cond=has_cap("workspace/workspaceFolders")},
 {name=NS.lsp_workspace_list_folders, rhs=N.Util.Wrapper.fn_eval(vim.print,vim.lsp.buf.list_workspace_folders),         cond=has_cap("workspace/workspaceFolders")},
 {name=NS.lsp_workspace_remove_folder,rhs=vim.lsp.buf.remove_workspace_folder,                                          cond=has_cap("workspace/workspaceFolders")},
 {name=NS.lsp_workspace_symbols,      rhs=vim.lsp.buf.workspace_symbol,                                                 cond=has_cap("textDocument/documentSymbol")},
 {name=NS.lsp_workspace_diagnostic,   rhs=require("hc-nvim.util.function.diagnostic"),                                  cond=has_cap("workspace/diagnostic")},
 {name=NS.lsp_inlay_hints_toggle,     rhs=function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,cond=has_cap("textDocument/inlayHint")},
 {
  name=NS.lsp_lua_ls_toggle_hint,
  rhs=function()
   local client=vim.lsp.get_clients({name="lua_ls"})[1]
   local enabled=N.Util.tbl_get(client,{"config","settings","Lua","hint","enable"})
   local target=not enabled
   N.Util.tbl_set(client,{"config","settings","Lua","hint","enable"},target)
   local buf=vim.api.nvim_get_current_buf()
   if vim.lsp.buf_is_attached(buf,client.id) then
    vim.lsp.buf_detach_client(buf,client.id)
    vim.lsp.buf_attach_client(buf,client.id)
   end
   if target==true then
    vim.defer_fn(function()
     vim.lsp.inlay_hint.enable(true)
    end,1000)
   end
  end,
  cond=has_client("lua_ls"),
 },
}

vim.api.nvim_create_autocmd("LspAttach",{
 once=true,
 callback=function()
  local Util=require("hc-nvim.util")
  ---@param cap lsp.Methods
  local function has_cap(cap)
   return function()
    return vim.lsp.get_clients({method=cap,bufnr=vim.api.nvim_get_current_buf()})[1]~=nil
   end
  end
  local Mapping=require("hc-nvim.setup.mapping")
  Mapping:extend({
   {name=NS.lsp_codeAction,             rhs=vim.lsp.buf.code_action,                                                  cond=has_cap("textDocument/codeAction")},
   {name=NS.lsp_declaration,            rhs=vim.lsp.buf.declaration,                                                  cond=has_cap("textDocument/declaration")},
   {name=NS.lsp_definition,             rhs=vim.lsp.buf.definition,                                                   cond=has_cap("textDocument/definition")},
   {name=NS.lsp_document_symbols,       rhs=vim.lsp.buf.document_symbol,                                              cond=has_cap("textDocument/documentSymbol")},
   {name=NS.lsp_formatting,             rhs=require("hc-nvim.setup.lsp.format"),                                      cond=has_cap("textDocument/formatting")},
   {name=NS.lsp_hover,                  rhs=vim.lsp.buf.hover,                                                        cond=has_cap("textDocument/hover")},
   {name=NS.lsp_implementation,         rhs=vim.lsp.buf.implementation,                                               cond=has_cap("textDocument/implementation")},
   {name=NS.lsp_incoming_calls,         rhs=vim.lsp.buf.incoming_calls,                                               cond=has_cap("callHierarchy/incomingCalls")},
   {name=NS.lsp_outgoing_calls,         rhs=vim.lsp.buf.outgoing_calls,                                               cond=has_cap("callHierarchy/outgoingCalls")},
   {name=NS.lsp_references,             rhs=vim.lsp.buf.references,                                                   cond=has_cap("textDocument/references")},
   {name=NS.lsp_rename,                 rhs=vim.lsp.buf.rename,                                                       cond=has_cap("textDocument/rename")},
   {name=NS.lsp_signatureHelp,          rhs=vim.lsp.buf.signature_help,                                               cond=has_cap("textDocument/signatureHelp")},
   {name=NS.lsp_typeDefinition,         rhs=vim.lsp.buf.type_definition,                                              cond=has_cap("textDocument/typeDefinition")},
   {name=NS.lsp_workspace_add_folder,   rhs=vim.lsp.buf.add_workspace_folder,                                         cond=has_cap("workspace/workspaceFolders")},
   {name=NS.lsp_workspace_list_folders, rhs=Util.Wrapper.fn_eval(vim.print,vim.lsp.buf.list_workspace_folders),       cond=has_cap("workspace/workspaceFolders")},
   {name=NS.lsp_workspace_remove_folder,rhs=vim.lsp.buf.remove_workspace_folder,                                      cond=has_cap("workspace/workspaceFolders")},
   {name=NS.lsp_workspace_symbols,      rhs=vim.lsp.buf.workspace_symbol,                                             cond=has_cap("textDocument/documentSymbol")},
   {name=NS.lsp_diagnostic_toggle,      rhs=Util.Wrapper.fn_eval(vim.diagnostic.enable,vim.diagnostic.is_enabled,true)},
   {name=NS.lsp_diagnostic_next,        rhs=Util.Wrapper.fn_eval(vim.diagnostic.jump,{count=1})},
   {name=NS.lsp_diagnostic_previous,    rhs=Util.Wrapper.fn_eval(vim.diagnostic.jump,{count=-1})},
  })
  local lspMaps=Mapping:export("lsp")
  vim.api.nvim_create_autocmd("LspAttach",{
   callback=function(ev)
    lspMaps:create(ev.buf)
   end,
  })
  lspMaps:create(true)
 end,
})

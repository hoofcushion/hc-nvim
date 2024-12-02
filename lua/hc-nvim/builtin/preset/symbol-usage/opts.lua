local function get_hl_by_name(name)
 return vim.api.nvim_get_hl(0,{name=name})
end
local Util=require("hc-nvim.util")
Util.HLGroup.create({
 {"SymbolUsageRounding",{fg=get_hl_by_name("CursorLine").bg,italic=true}},
 {"SymbolUsageContent", {bg=get_hl_by_name("CursorLine").bg,fg=get_hl_by_name("Comment").fg,italic=true}},
 {"SymbolUsageRef",     {fg=get_hl_by_name("Function").fg,bg=get_hl_by_name("CursorLine").bg,italic=true}},
 {"SymbolUsageDef",     {fg=get_hl_by_name("Type").fg,bg=get_hl_by_name("CursorLine").bg,italic=true}},
 {"SymbolUsageImp",     {fg=get_hl_by_name("@keyword").fg,bg=get_hl_by_name("CursorLine").bg,italic=true}},
})
 :set_hl()
 :attach()
local Config=require("hc-nvim.config")
local kind=require("hc-nvim.rsc").kind[Config.ui.kind]
local defs={
 references={kind.Reference,"SymbolUsageRef"},
 definition={kind.Definition,"SymbolUsageDef"},
 implementation={kind.Implementation,"SymbolUsageImp"},
 block={" ","SymbolUsageContent"},
 space={" ","NonText"},
}
local range={"references","definition","implementation"}
local SymbolKind=vim.lsp.protocol.SymbolKind
return {
 ---@type lsp.SymbolKind[] Symbol kinds what need to be count (see `lsp.SymbolKind`)
 kinds={SymbolKind.Method,SymbolKind.Function},
 ---@type 'above'|'end_of_line'|'textwidth'|'signcolumn'
 vt_position="end_of_line",
 ---@type string|table|false
 request_pending_text="...",
 ---@alias symbol-usage.type "references"|"definition"|"implementation"
 ---@param symbol table<symbol-usage.type,integer>
 ---@return string|{[1]:string,[2]:string}
 text_format=function(symbol)
  local ret={}
  table.insert(ret,defs.space)
  table.insert(ret,defs.block)
  for name,count in Util.rpairs(symbol,range) do
   local def=defs[name]
   table.insert(ret,{tostring(count),def[2]})
   table.insert(ret,defs.block)
   table.insert(ret,def)
   table.insert(ret,defs.block)
  end
  return ret
 end,
 references={enabled=true,include_declaration=true},
 definition={enabled=true},
 implementation={enabled=true},
 ---@type 'start'|'end'
 symbol_request_pos="end",
}

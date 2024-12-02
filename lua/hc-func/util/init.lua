local M=require("hc-func.util.lazy_tab").create({
 Autocmd="hc-func.util.autocmd",
 Cache="hc-func.util.cache",
 FallbackTbl="hc-func.util.fallbacktbl",
 FuncBind="hc-func.util.funcbind",
 Highlight="hc-func.util.highlight",
 Iter="hc-func.util.iter",
 LocalVars="hc-func.util.localvars",
 ReferenceTbl="hc-func.util.referencetbl",
 Timer="hc-func.util.timer",
 LazyTab="hc-func.util.lazy_tab",
})
--- Lua_ls annotation
if false then
 M={
  Autocmd=require("hc-func.util.autocmd"),
  Cache=require("hc-func.util.cache"),
  FallbackTbl=require("hc-func.util.fallbacktbl"),
  FuncBind=require("hc-func.util.funcbind"),
  Highlight=require("hc-func.util.highlight"),
  Iter=require("hc-func.util.iter"),
  LocalVars=require("hc-func.util.localvars"),
  ReferenceTbl=require("hc-func.util.referencetbl"),
  Timer=require("hc-func.util.timer"),
  LazyTab=require("hc-func.util.lazy_tab"),
 }
end
function M.new_timer()
 local timer,err=(vim.uv or vim.loop).new_timer()
 if timer==nil then
  error(err)
 end
 return timer
end
return M

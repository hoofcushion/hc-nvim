local Config=require("hc-nvim.config")
local sign=require("hc-nvim.config.rsc").sign[Config.ui.sign]
vim.diagnostic.config({
 signs={
  text=sign,
 },
 virtual_text={
  prefix=function(diag) return sign[diag.severity] end,
 },
 float={
  ---@diagnostic disable-next-line: assign-type-mismatch
  border=require("hc-nvim.config.rsc").border[Config.ui.border],
  severity_sort=true,
 },
 severity_sort=true,
})
--- disable DiagnosticUnnecessary highlight group
local function clear()
 vim.cmd([[
 hi! clear DiagnosticUnnecessary
 hi! link DiagnosticUnnecessary NONE
 ]])
end
if vim.v.vim_did_enter then
 clear()
end
vim.api.nvim_create_autocmd({"VimEnter","ColorScheme"},{
 group=vim.api.nvim_create_augroup("Disable DiagnosticUnnecessary Highlight",{clear=true}),
 callback=clear,
})

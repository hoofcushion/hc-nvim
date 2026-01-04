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

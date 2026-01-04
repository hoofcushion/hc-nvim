vim.api.nvim_create_autocmd("ColorScheme",{
 callback=function()
  vim.api.nvim_set_hl(0,"DiagnosticUnnecessary",{link="NONE"})
 end,
})

return {
 lazy=false,
 config=function()
  vim.cmd("call mkdp#util#install()")
  vim.g.mkdp_filetypes={"markdown"}
 end,
}

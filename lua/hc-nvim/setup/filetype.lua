local Util=require("hc-nvim.util")
local FileType={
 detectors={},
}
function FileType.add(ftspec)
 if type(ftspec)=="function" then
  table.insert(FileType.detectors,ftspec)
  return
 end
 if type(ftspec)~="table" then
  error("table expected")
 end
 if not Util.is_list(ftspec) then
  error("list expected")
 end
 for _,v in ipairs(ftspec) do
  FileType.add(v)
 end
end
function FileType.check(s)
 for _,v in ipairs(FileType.detectors) do
  local ft=v(s)
  if ft then
   vim.bo[s.buf].filetype=ft
   return
  end
 end
end
for modname in Util.iter_mod({
 "hc-nvim.builtin.filetype",
 "hc-nvim.user.filetype",
}) do
 FileType.add(require(modname))
end
vim.api.nvim_create_autocmd("VimEnter",{
 once=true,
 callback=FileType.check,
})
vim.api.nvim_create_autocmd("BufEnter",{
 callback=FileType.check,
})

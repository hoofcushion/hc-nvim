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
vim.api.nvim_create_autocmd({"VimEnter","BufAdd"},{
 callback=function(ev)
  for _,v in ipairs(FileType.detectors) do
   local ft=v(ev)
   if ft then
    vim.bo[ev.buf].filetype=ft
    return
   end
  end
 end,
})
for modname in Util.iter_mod({
 "hc-nvim.builtin.filetype",
 "hc-nvim.user.filetype",
}) do
 FileType.add(require(modname))
end

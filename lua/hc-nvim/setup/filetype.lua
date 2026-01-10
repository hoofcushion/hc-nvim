local N=require("hc-nvim.init_space")
---@class HC-Nvim.FileType
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
 if not N.Util.is_list(ftspec) then
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
function FileType.setup()
 for modname,modpath in N.Util.iter_mod({
  "hc-nvim.config.filetype",
  "hc-nvim.user.filetype",
 }) do
  N.Util.try(
   function()
    local filetypes=N.Util.path_require(modname,modpath)
    FileType.add(filetypes)
   end,
   N.Util.ERROR
  )
 end
 vim.api.nvim_create_autocmd("BufEnter",{
  callback=FileType.check,
 })
end
return FileType

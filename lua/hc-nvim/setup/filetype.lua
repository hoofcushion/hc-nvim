local HCNvim=require("hc-nvim.init_space")
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
 if not HCNvim.Util.is_list(ftspec) then
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
 for modname,modpath in HCNvim.Util.iter_mod({
  "hc-nvim.config.filetype",
  "hc-nvim.user.filetype",
 }) do
  HCNvim.Util.try(
   function()
    local filetypes=HCNvim.Util.path_require(modname,modpath)
    FileType.add(filetypes)
   end,
   HCNvim.Util.ERROR
  )
 end
 vim.api.nvim_create_autocmd({"BufReadPost","BufNewFile"},{
  callback=FileType.check,
 })
 HCNvim.Util.reload_file_buffers()
end
return FileType

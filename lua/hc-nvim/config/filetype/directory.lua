return {
 function(ev)
  local stat=vim.uv.fs_stat(ev.file)
  if stat and stat.type=="directory" then
   return "directory"
  end
 end,
}

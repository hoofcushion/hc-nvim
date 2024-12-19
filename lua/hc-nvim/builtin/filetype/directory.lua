return {
 function(ev)
  if vim.fn.isdirectory(ev.file)==1 then
   return "directory"
  end
 end,
}

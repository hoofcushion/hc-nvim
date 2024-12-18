vim.api.nvim_create_autocmd({"VimEnter","BufAdd"},{
 callback=function(ev)
  if vim.fn.isdirectory(ev.file)==1 then
   vim.bo[ev.buf].filetype="directory"
  end
 end,
})

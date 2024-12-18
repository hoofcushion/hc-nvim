local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
vim.api.nvim_create_autocmd({"VimEnter","BufAdd"},{
 callback=function(ev)
  if (Util.get_size(ev.file) or Util.get_size(ev.buf))>Config.performance.bigfile.bytes
  or vim.api.nvim_buf_line_count(ev.buf)>Config.performance.bigfile.lines
  then
   vim.bo[ev.buf].filetype="bigfile"
  end
 end,
})

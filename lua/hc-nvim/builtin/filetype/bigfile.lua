local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
vim.filetype.add({
 pattern={
  [".*"]={
   function(path,buf)
    if (path
     and Util.get_size(path)>Config.performance.bigfile.bytes)
    or (buf
     and Util.get_size(buf)>Config.performance.bigfile.bytes
     or vim.api.nvim_buf_line_count(buf)>Config.performance.bigfile.bytes)
    then
     return "bigfile"
    end
   end,
   {priority=math.huge},
  },
 },
})

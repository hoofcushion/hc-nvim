local Config=require("hc-nvim.config")
local Util=require("hc-nvim.util")
vim.filetype.add({
 pattern={
  [".*"]={
   function(path,buf)
    return (
      (Util.get_size(path) or Util.get_size(buf))>Config.performance.bigfile.bytes
      or vim.api.nvim_buf_line_count(buf)>Config.performance.bigfile.lines
     )
     and "bigfile"
     or nil
   end,
   {priority=math.huge},
  },
 },
})

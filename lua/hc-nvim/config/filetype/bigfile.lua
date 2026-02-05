local HCNvim=require("hc-nvim.init_space")
local Config=HCNvim.Config
local Util=HCNvim.Util
return {
 function(ev)
  if (Util.get_size(ev.file) or Util.get_size(ev.buf))>Config.performance.bigfile.bytes
  or vim.api.nvim_buf_line_count(ev.buf)>Config.performance.bigfile.lines
  then
   return "bigfile"
  end
 end,
}

local Config=require("hc-nvim.config")
local function get_size(id)
 if type(id)=="number" then
  return vim.api.nvim_buf_get_offset(0,vim.api.nvim_buf_line_count(0))
 else
  local info=vim.uv.fs_stat(id)
  return info~=nil and info.size or nil
 end
end
vim.filetype.add({
 pattern={
  [".*"]={
   function(path,buf)
    return path
     and (
      (get_size(path) or get_size(buf))>Config.performance.bigfile:as("B")
      or vim.api.nvim_buf_line_count(buf)>Config.performance.bigfile:as("l")
     )
     and "bigfile"
     or nil
   end,
   {priority=math.huge},
  },
 },
})

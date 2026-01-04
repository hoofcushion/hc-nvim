---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
--- a version of nvim_buf_set_text with shorter function signature
---@param buf integer
---@param range range
---@param text string|string[]
function Util.buf_set_text(buf,range,text)
 if type(text)=="string" then
  text=vim.split(text,"\n")
 end
 vim.api.nvim_buf_set_text(
  buf,
  range[1],
  range[2],
  range[3],
  range[4],
  text
 )
end
--- a version of nvim_buf_get_text with shorter function signature
---@param buf integer
---@param range range
---@return string[] text
function Util.buf_get_text(buf,range)
 return table.concat(vim.api.nvim_buf_get_text(
  buf,
  range[1],
  range[2],
  range[3],
  range[4],
  {}
 ),"\n")
end

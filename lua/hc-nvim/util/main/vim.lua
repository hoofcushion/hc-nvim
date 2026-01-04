---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@enum (key) visualmode
local is_visualmode={
 v=true,
 V=true,
 [""]=true,
}
---@return visualmode
function Util.get_vmode()
 local vmode=vim.api.nvim_get_mode().mode:sub(1,1)
 if is_visualmode[vmode]==nil then
  vmode=vim.fn.visualmode()
  if vmode=="" then
   vmode="v"
  end
 end
 return vmode
end
function Util.is_visualmode()
 local vmode=vim.api.nvim_get_mode().mode:sub(1,1)
 return is_visualmode[vmode]==true
end
local _pattern={
 vim.fs.normalize(vim.fn.stdpath("config")) --[[@as string]],
 vim.fs.normalize(vim.fn.stdpath("data")) --[[@as string]],
}
--- Tells current file is or not part of  neovim profile
---@param file string
---@return boolean
function Util.is_profile(file)
 file=vim.fs.normalize(file)
 for _,v in ipairs(_pattern) do
  if Util.startswith(file,v) then
   return true
  end
 end
 return false
end
function Util.get_size(id)
 if type(id)=="number" then
  return vim.api.nvim_buf_get_offset(id,vim.api.nvim_buf_line_count(id))
 else
  local info=vim.uv.fs_stat(id)
  return info~=nil and info.size or nil
 end
end

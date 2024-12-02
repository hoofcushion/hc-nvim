local Base=require("hc-nvim.util.keymod.base")
local M={}
---@param lhs keymod.key
---@param rhs keymod.key
function M.create(lhs,rhs)
 local continuous=false
 local function cond()
  local line=vim.api.nvim_get_current_line()
  local non_blank_start=string.find(line,"%S")
  if non_blank_start~=nil then
   local pos_col=vim.api.nvim_win_get_cursor(0)[2]+1
   if pos_col<=non_blank_start then
    if continuous then
     return true
    end
    continuous=true
    return false
   end
  end
  continuous=false
 end
 return Base.create(lhs,rhs,cond)
end
return M

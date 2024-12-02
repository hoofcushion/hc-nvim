--- ---
--- Reg imp.
--- ---
---@enum (key) RegAlias
local reg_alias={
 xselection="*",
 xclipboard="+",
 yanked="\"",
 deleted="\"",
 changed="\"",
 deleted1="-",
 changed1="-",
 command=":",
 inserted=".",
 file="%",
 search="/",
 current=nil,
}
---@class position
---@field [1] integer
---@field [2] integer
---@class reginfo
---@field regcontents string[]
---@field regtype visualmode
---@field isunnamed? boolean
---@field points_to? string
---@class Registers
---@field [RegAlias] reginfo
local Register=setmetatable({},{
 __index=function(_,k)
  if k=="current" then
   k=vim.v.register
  end
  return vim.fn.getreginfo(reg_alias[k] or k)
 end,
 __newindex=function(_,k,v)
  if k=="current" then k=vim.v.register end
  vim.fn.setreg(reg_alias[k] or k,v)
 end,
})
return Register

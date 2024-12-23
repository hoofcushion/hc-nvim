---
--- Module that deal with keymod wrapping.
--- Generic for string and function.
---@alias keymod.key nil|string|keymod.keyfn
---@alias keymod.keyfn (fun(...:any):string|nil)

---@return function
local function tokey_fn(any)
 return type(any)=="function"
  and any
  or (type(any)=="string" or any==nil)
  and function()
   return any or ""
  end
  or error("string or function expected, got: "..tostring(any))
end
local M={}
---@param lhs keymod.key|nil
---@param rhs keymod.key|nil
function M.concat(lhs,rhs)
 lhs=tokey_fn(lhs)
 rhs=tokey_fn(rhs)
 return function()
  return lhs()..rhs()
 end
end
---
--- Generic function combine for string and function
---@param lhs keymod.key|nil # A string, or function that could return string
---@param rhs keymod.key|nil # A string, or function that could return string
---@param cond fun():boolean # A function determine whether or not to return rhs instead of lhs
---@return keymod.keyfn ExprKey Could use in vim.keymap.set as rhs
function M.create(lhs,rhs,cond)
 lhs=tokey_fn(lhs)
 rhs=tokey_fn(rhs)
 return function(...)
  if cond() then
   return rhs(...)
  else
   return lhs(...)
  end
 end
end
return M

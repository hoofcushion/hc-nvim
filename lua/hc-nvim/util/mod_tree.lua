--- Travel filesystem in table.
local  Util=require("hc-nvim.util.init_space")
local function modtree(tree,path,func)
 return setmetatable({},{
  __index=function(_,name)
   if tree[name]==true then
    return func(table.concat(path,".").."."..name)
   end
   local new_path=Util.deepcopy(path)
   table.insert(new_path,name)
   return modtree(tree[name],new_path,func)
  end,
 })
end
local M={}
---@param tree table
---@param path table
---@param func function?
---@return table
function M.create(tree,path,func)
 return modtree(tree,path,func or require)
end
return M

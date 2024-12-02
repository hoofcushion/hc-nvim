local Util=require("hc-nvim.util")
---@class HLGroup
---@field public groups {[1]:string,[2]:vim.api.keyset.hl_info}
local HLGroup={}
function HLGroup:pairs()
 local i=1
 local groups=self.groups
 return function()
  local group=groups[i]
  if group then
   i=i+1
   return group[1],group[2]
  end
 end
end
function HLGroup:set_hl(opts)
 for name,opt in self:pairs() do
  if opts then
   opt=vim.tbl_extend("force",opt,opts)
  end
  vim.api.nvim_set_hl(0,name,opt)
 end
 return self
end
function HLGroup:clear()
 for name in self:pairs() do
  vim.api.nvim_set_hl(0,name,{})
 end
 return self
end
local cbs={}
vim.api.nvim_create_autocmd("ColorScheme",{
 callback=function()
  for _,cb in pairs(cbs) do
   cb()
  end
 end,
})
function HLGroup:attach()
 cbs[self]=function()
  self:set_hl()
 end
 return self
end
function HLGroup:add(group)
 table.insert(self.groups,group)
 return self
end
function HLGroup:extend(groups)
 for _,v in ipairs(groups) do
  self:add(v)
 end
 return self
end
function HLGroup:getnames()
 local ret={}
 for _,group in ipairs(self.groups) do
  table.insert(ret,group[1])
 end
 return ret
end
function HLGroup.create(groups)
 local obj=Util.Class.new(HLGroup)
 obj.groups={}
 if groups~=nil then
  obj:extend(groups)
 end
 return obj
end
return HLGroup

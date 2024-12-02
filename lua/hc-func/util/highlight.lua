local Class=require("hc-func.class")
---@class Highlight
local Highlight={
 hls={},
}
function Highlight:set()
 for _,v in ipairs(self.hls) do
  vim.api.nvim_set_hl(0,v[1],v[2])
 end
end
local empty={}
function Highlight:clear()
 for _,v in ipairs(self.hls) do
  vim.api.nvim_set_hl(0,v[1],empty)
 end
end
function Highlight:fini()
 self:clear()
 self.hls={}
end
---@param opts vim.api.keyset.highlight
function Highlight:add(group,opts)
 table.insert(self.hls,{group,opts})
end
function Highlight:extend(groups)
 for _,v in ipairs(groups) do
  table.insert(self.hls,v)
 end
end
function Highlight.new()
 local obj=Class.new(Highlight)
 obj.hls={}
 return obj
end
return Highlight

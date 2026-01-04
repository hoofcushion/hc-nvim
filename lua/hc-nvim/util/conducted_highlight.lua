local Util=require("hc-nvim.util.init_space")
---@class ConductedHighlight
local Highlight={
 highlights={},
}
---@param opts vim.api.keyset.highlight
function Highlight:add(group,opts)
 table.insert(self.highlights,{group,opts})
end
function Highlight:extend(groups)
 for _,v in ipairs(groups) do
  table.insert(self.highlights,v)
 end
end
function Highlight:attach()
 self:enable()
 self.autocmd=vim.api.nvim_create_autocmd("ColorScheme",{
  callback=function()
   self:enable()
  end,
 })
end
function Highlight:enable()
 for _,v in ipairs(self.highlights) do
  vim.api.nvim_set_hl(0,v[1],v[2])
 end
end
local empty={}
function Highlight:disable()
 for _,v in ipairs(self.highlights) do
  vim.api.nvim_set_hl(0,v[1],empty)
 end
end
function Highlight:fini()
 self:disable()
 self.highlights={}
end
function Highlight.new()
 local obj=setmetatable({},{__index=Highlight})
 obj.highlights={}
 return obj
end
return Highlight

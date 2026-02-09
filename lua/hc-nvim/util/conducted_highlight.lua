local Util=require("hc-nvim.util.init_space")
---@class ConductedHighlight
local Highlight={highlights={}}
Highlight.__index=Highlight
---@param opts vim.api.keyset.highlight
function Highlight:add(group,opts)
 table.insert(self.highlights,{group,opts})
end
function Highlight:extend(groups)
 for _,v in ipairs(groups) do
  table.insert(self.highlights,v)
 end
end
local function safe_set_hl(ns_id,name,val)
 Util.try(function() vim.api.nvim_set_hl(ns_id,name,val) end,Util.ERROR)
end
function Highlight:attach()
 local function enable() self:enable() end
 if vim.v.vim_did_enter then
  enable()
 else
  vim.api.nvim_create_autocmd("VimEnter",{
   once=true,
   callback=function() enable() end,
  })
 end
 local ok,id=pcall(function()
  return vim.api.nvim_create_autocmd("ColorScheme",{
   callback=function() enable() end,
  })
 end)
 if ok then
  self.autocmd=id
 end
end
function Highlight:enable()
 for _,v in ipairs(self.highlights) do
  local ns_id,name,val=0,v[1],v[2]
  safe_set_hl(ns_id,name,val)
 end
end
local empty={}
function Highlight:disable()
 for _,v in ipairs(self.highlights) do
  local ns_id,name=0,v[1]
  safe_set_hl(ns_id,name,empty)
 end
end
function Highlight:fini()
 self:disable()
 self.highlights={}
end
function Highlight.new()
 local obj=setmetatable({},Highlight)
 obj.highlights={}
 return obj
end
return Highlight

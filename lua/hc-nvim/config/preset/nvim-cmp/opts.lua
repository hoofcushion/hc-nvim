---@diagnostic disable: missing-fields
local Config=require("hc-nvim.config")
local Rsc=require("hc-nvim.config.rsc")
---@module "cmp.config"
---@type cmp.ConfigSchema
return {
 view={
  docs={
   auto_open=true,
  },
  entries={
   name="custom",
   selection_order="near_cursor",
  },
 },
 window={
  completion={
   border=Rsc.border[Config.ui.border],
   side_padding=0,
   col_offset=0,
   winblend=Config.ui.blend,
  },
  documentation={
   border=Rsc.border[Config.ui.border],
   winblend=Config.ui.blend,
   max_height=30,
   max_width=40,
  },
 },
 formatting={
  fields={"abbr","kind","menu"},
  format=(function()
   local function truncate(str,len,ellipsis)
    if ellipsis==nil then ellipsis="…" end
    if #str>len then
     return string.sub(str,1,len-#ellipsis)..ellipsis
    end
    return str
   end
   local kinds=Rsc.kind[Config.ui.kind]
   ---@type fun(entry: cmp.Entry, vim_item: vim.CompletedItem): vim.CompletedItem
   return function(entry,item)
    -- custom menu name
    local menu=kinds[entry.source.name] or entry.source.name
    if menu~=nil then
     item.menu=menu
    end
    -- custom kind naame
    local kind=kinds[item.kind]
    if kind~=nil then
     item.kind=kind
    end
    -- add lsp client source to lsp item
    local has_lsp_name,lsp_name=pcall(function()
     return assert(entry.source.name=="nvim_lsp")
      and assert(type(entry.source.source.client.name)=="string")
      and entry.source.source.client.name
    end)
    if has_lsp_name then
     item.menu=("%s(%s)"):format(item.menu,lsp_name)
    end
    -- truncate abbr text
    item.abbr=truncate(item.abbr,math.floor(vim.o.columns)*0.5)
    return item
   end
  end)(),
 },
 performance={
  -- debounce=60,
  -- throttle=30,
  -- fetching_timeout=500,
  -- filtering_context_budget=3,
  -- confirm_resolve_timeout=80,
  -- async_budget=1,
  -- max_view_entries=200,

  -- realtime adjustment
  debounce=30,
  throttle=15,
  fetching_timeout=100,
  filtering_context_budget=1,
  confirm_resolve_timeout=50,
  async_budget=1,
  max_view_entries=50,
 },
}

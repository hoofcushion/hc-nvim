---@diagnostic disable: missing-fields
local Config=require("hc-nvim.config")
local Rsc=require("hc-nvim.rsc")
---@module "cmp.config"
---@type cmp.ConfigSchema
return {
 view={
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
  },
  documentation={
   border=Rsc.border[Config.ui.border],
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
  -- (60) the interval (in ms) used to group up completions from different sources
  -- debounce=60,
  -- (30) time (in ms) to delay filtering and displaying completions.
  throttle=Config.performance.throttle,
  -- (500) the timeout  (in ms)of candidate fetching process.
  -- fetching_timeout=500,
  -- (80) the timeout (in ms) for resolving item before confirmation.
  -- confirm_resolve_timeout=80,
  -- (1) the maximum time (in ms) an async function is allowed to run during one step of the event loop.
  -- async_budget=1,
  -- (200) the maximum number of items to show in the entries list.
  -- max_view_entries=25,
 },
}

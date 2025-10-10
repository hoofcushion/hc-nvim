return function(_,opts)
 ---@module "cmp.config"

 local cmp=require("cmp")
 --- ---
 --- Sources
 --- ---
 ---@class cmp.SourceObj:cmp.SourceConfig
 local Source={
  max_item_count=1000,
 }
 function Source:new(name,properties)
  local source=vim.tbl_deep_extend("force",Source,properties)
  source.name=name
  return source
 end
 function Source:with(override)
  return vim.tbl_deep_extend("force",self,override)
 end
 ---@type table<string,cmp.SourceObj|{}>
 local src=setmetatable({},{
  -- auto create filed when index
  __index=function(t,name)
   local ret=rawget(t,name)
   if ret==nil then
    ret=Source:new(name,{})
    rawset(t,name,ret)
   end
   return ret
  end,
  -- auto merge field when newindex
  __newindex=function(t,name,option)
   rawset(t,name,Source:new(name,option))
  end,
 })
 src.cmdline={
  option={
   ignore_cmds={"Man","!"},
  },
 }
 src.buffer={
  option={
   get_bufnrs=function()
    local res={}
    for _,buf in ipairs(vim.api.nvim_list_bufs()) do
     if vim.fn.bufname(buf)~="" or vim.fn.bufwinid(buf)~=-1 then
      table.insert(res,buf)
     end
    end
    return res
   end,
  },
 }
 cmp.setup.filetype("gitcommit",{
  sources={
   src.git,
   src.async_path,
   src.bufname,
   src.rg:with({max_item_count=5}),
   src.buffer:with({max_item_count=5}),
  },
 })
 --- Search
 cmp.setup.cmdline({"?","/"},{
  sources={
   src.async_path,
   src.buffer,
   src.bufname,
   src.cmdline_history:with({
    options={history_type="/"},
    max_item_count=5,
   }),
   src.treesitter,
   src.rg:with({max_item_count=5}),
   src.buffer:with({max_item_count=5}),
  },
 })
 --- Command
 cmp.setup.cmdline(":",{
  sources={
   src.cmdline:with({priority=2^31}),
   src.async_path,
   src.bufname,
   src.cmdline_history:with({
    options={history_type=":"},
    max_item_count=5,
   }),
   src.treesitter,
   src.rg:with({max_item_count=5}),
   src.buffer:with({max_item_count=5}),
  },
 })
 cmp.setup({
  sources={
   src.nvim_lsp:with({priority=2^31}),
   src.luasnip,
   src.lazydev,
   src.bufname,
   src.async_path,
   src.treesitter,
   src.rg:with({max_item_count=5}),
   src.buffer:with({max_item_count=5}),
  },
 })
 local compare=require("cmp.config.compare")
 cmp.setup({ ---@type {}
  sorting={
   comparators={
    compare.score,
    compare.offset,
    compare.exact,
    compare.scopes, --
    compare.recently_used,
    compare.locality,
    compare.kind,
    compare.sort_text, --
    compare.length,
    compare.order,
   },
  },
 })
 cmp.setup(opts)
end

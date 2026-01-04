local Config=require("hc-nvim.config")
if Config.platform.is_vscode and not Config.server.vscode then
 return
end
local Util=require("hc-nvim.util")
if Config.server.auto_setup then
 vim.api.nvim_create_autocmd("User",{
  pattern="LazyDone",
  once=true,
  callback=function()
   local Handler=require("hc-nvim.setup.server.handler")
   local specs=Config.server.list
   for _,spec in ipairs(specs) do
    Handler.load(spec)
   end
  end,
 })
end
local lspMaps; Util.lazy(function()
 local Mapping=require("hc-nvim.setup.mapping")
 Mapping:extend(require("hc-nvim.setup.server.mappings"))
 return Mapping:export("lsp")
end,function(t)
 lspMaps=t
end)
-- use timer to prevent creating mappings multiple times
local timer=assert(vim.uv.new_timer())
local queue={}
vim.api.nvim_create_autocmd("LspAttach",{
 callback=function(ev)
  queue[ev.buf]=true
  timer:start(100,0,function()
   vim.schedule(function()
    for buf in pairs(queue) do
     lspMaps:create(buf)
    end
    queue={}
   end)
  end)
 end,
})

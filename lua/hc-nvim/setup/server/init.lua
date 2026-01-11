local N=require("hc-nvim.init_space")
---@class HC-Nvim.Server
local Server={}
function Server.setup()
 if N.Config.platform.is_vscode and not N.Config.server.vscode then
  return
 end
 if N.Config.server.auto_setup then
  vim.api.nvim_create_autocmd(N.Setup.Event.File.event,{
   pattern=N.Setup.Event.File.pattern,
   once=true,
   callback=function()
    local Handler=require("hc-nvim.setup.server.handler")
    local specs=N.Config.server.list
    for _,spec in ipairs(specs) do
     Handler.load(spec)
    end
    if vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) then
     vim.cmd("e")
    end
   end,
  })
 end
 local lspMaps
 N.Util.lazy(function()
  local interface_lsp=require("hc-nvim.setup.mapping").Interface:export("lsp")
  interface_lsp:extend(require("hc-nvim.setup.server.mappings"))
  return interface_lsp
 end,function(t)
  lspMaps=t
 end)
 -- use timer to prevent creating mappings multiple times
 local timer=assert(vim.uv.new_timer())
 local lsp_mapping_queue={}
 local function create()
  for buf in pairs(lsp_mapping_queue) do
   lspMaps:create(buf)
  end
  lsp_mapping_queue={}
 end
 vim.api.nvim_create_autocmd("LspAttach",{
  group=vim.api.nvim_create_augroup("LSPMappingCreater",{}),
  callback=function(ev)
   lsp_mapping_queue[ev.buf]=true
   timer:start(100,0,function()
    vim.schedule(create)
   end)
  end,
 })
end
return Server

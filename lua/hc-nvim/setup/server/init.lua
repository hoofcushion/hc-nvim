local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.Server
local Server={}
function Server.setup()
 if HCNvim.Config.platform.is_vscode and not HCNvim.Config.server.vscode then
  return
 end
 if HCNvim.Config.server.auto_setup then
  local Handler=require("hc-nvim.setup.server.handler")
  local specs=HCNvim.Config.server.list
  for _,spec in ipairs(specs) do
   Handler.load(spec)
  end
  HCNvim.Util.reload_file_buffers()
 end
 local lspMaps; lspMaps=HCNvim.Util.lazy(function()
  local interface_lsp=HCNvim.Setup.Mapping.Interface:export("lsp")
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
   lsp_mapping_queue[buf]=nil
   lspMaps:create(buf)
  end
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

local HCNvim=require("hc-nvim.init_space")
---@class HC-Nvim.Setup
local Setup=require("hc-nvim.setup.init_space")
HCNvim.lazy(function() return require("hc-nvim.setup.luatyped") end,function(t) Setup.LuaTyped=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.basic") end,   function(t) Setup.Basic=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.event") end,   function(t) Setup.Event=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.filetype") end,function(t) Setup.FileType=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.i18n") end,    function(t) Setup.I18N=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.lazy") end,    function(t) Setup.Lazy=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.luafile") end, function(t) Setup.Luafile=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.mapping") end, function(t) Setup.Mapping=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.option") end,  function(t) Setup.Option=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.server") end,  function(t) Setup.Server=t end)
HCNvim.lazy(function() return require("hc-nvim.setup.vscode") end,  function(t) Setup.Vscode=t end)
function Setup.setup()
 HCNvim.Util.track("Setup")
 -- init plugin rtp
 vim.opt.rtp:append(HCNvim.Util.root_path)
 -- init NS for string reference
 _G.NS=HCNvim.Util.namespace
 -- load modules
 local loaders={
  {name="LuaTyped",schedule=false,load=function() Setup.LuaTyped.setup() end},
  {name="Luafile", schedule=false,load=function() Setup.Luafile.setup() end},
  {name="Option",  schedule=false,load=function() Setup.Option.setup() end},   -- set neovim options
  {name="I18N",    schedule=false,load=function() Setup.I18N.setup() end},     -- load language packs
  {name="Event",   schedule=false,load=function() Setup.Event.setup() end},    -- register custom events
  {name="Mapping", schedule=false,load=function() Setup.Mapping.setup() end},  -- register keymaps
  {name="Lazy",    schedule=false,load=function() Setup.Lazy.setup() end},     -- load lazy.nvim plugin configs
  {name="Vscode",  schedule=false,load=function() Setup.Vscode.setup() end},   -- load extra vscode-neovim setting
  {name="Basic",   schedule=true, load=function() Setup.Basic.setup() end},    -- run basic setup scripts
  {name="FileType",schedule=true, load=function() Setup.FileType.setup() end}, -- load custom filetypes
  {name="Server",  schedule=true, load=function() Setup.Server.setup() end},   -- load language tools settings
 }
 for _,spec in ipairs(loaders) do
  local function load()
   HCNvim.Util.track(spec.name)
   HCNvim.Util.try(spec.load,HCNvim.Util.ERROR)
   HCNvim.Util.track()
  end
  if spec.schedule then
   vim.schedule(load)
  else
   load()
  end
 end
 HCNvim.Util.track()
end
return Setup

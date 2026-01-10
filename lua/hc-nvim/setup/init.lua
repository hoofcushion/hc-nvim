local N=require("hc-nvim.init_space")
---@class HC-Nvim.Setup
local Setup=require("hc-nvim.setup.init_space")
N.lazy(function() return require("hc-nvim.setup.i18n") end,    function(t) Setup.I18N=t end)
N.lazy(function() return require("hc-nvim.setup.option") end,  function(t) Setup.Option=t end)
N.lazy(function() return require("hc-nvim.setup.basic") end,   function(t) Setup.Basic=t end)
N.lazy(function() return require("hc-nvim.setup.filetype") end,function(t) Setup.FileType=t end)
N.lazy(function() return require("hc-nvim.setup.event") end,   function(t) Setup.Event=t end)
N.lazy(function() return require("hc-nvim.setup.mapping") end, function(t) Setup.Mapping=t end)
N.lazy(function() return require("hc-nvim.setup.lazy") end,    function(t) Setup.Lazy=t end)
N.lazy(function() return require("hc-nvim.setup.vscode") end,  function(t) Setup.Vscode=t end)
N.lazy(function() return require("hc-nvim.setup.server") end,  function(t) Setup.Server=t end)
function Setup.setup()
 -- init plugin rtp
 vim.opt.rtp:append(N.Util.root_path)
 -- init NS for string reference
 _G.NS=N.Util.namespace
 -- load modules
 local modules={
  "I18N",     -- load language packs
  "Option",   -- set neovim options
  "Basic",    -- run basic setup scripts
  "FileType", -- load custom filetypes
  "Event",    -- register custom events
  "Mapping",  -- register keymaps
  "Lazy",     -- load lazy.nvim plugin configs
  "Vscode",   -- load extra vscode-neovim setting
  "Server",   -- load language tools settings
 }
 for _,key in ipairs(modules) do
  N.Util.track(key)
  N.Util.try(function()
   local mod=Setup[key]
    mod.setup()
  end,N.Util.ERROR)
  N.Util.track()
 end
end
return Setup

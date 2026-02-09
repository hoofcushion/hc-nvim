---@class HC-Nvim
local HCNvim=require("hc-nvim.init_space")
if vim.env.UNITTEST then
 _G.UnitTest=require("hc-nvim.util.unit_test").new()
 vim.schedule(function()
  UnitTest:test()
 end)
end
---@class HC-Nvim.Util
local Util=require("hc-nvim.util.init_space")
local res={}
local function collect(fn)
 table.insert(res,{pcall(fn)})
end
collect(function() require("hc-nvim.util.main.async") end)
collect(function() require("hc-nvim.util.main.base") end)
collect(function() require("hc-nvim.util.main.buffer") end)
collect(function() require("hc-nvim.util.main.iter") end)
collect(function() require("hc-nvim.util.main.module") end)
collect(function() require("hc-nvim.util.main.notify") end)
collect(function() require("hc-nvim.util.main.perf") end)
collect(function() require("hc-nvim.util.main.string") end)
collect(function() require("hc-nvim.util.main.table") end)
collect(function() require("hc-nvim.util.main.treesitter") end)
collect(function() require("hc-nvim.util.main.type") end)
collect(function() require("hc-nvim.util.main.vim") end)
collect(function() require("hc-nvim.util.main.workspace") end)
for _,v in ipairs(res) do
 local ok,msg=v[1],v[2]
 if not ok then
  vim.notify(msg,vim.log.levels.ERROR)
 end
end
HCNvim.lazy(function() return require("hc-nvim.util.buffercache") end,        function(t) Util.BufferCache=t end)
HCNvim.lazy(function() return require("hc-nvim.util.cache") end,              function(t) Util.Cache=t end)
HCNvim.lazy(function() return require("hc-nvim.util.color_format") end,       function(t) Util.ColorFormat=t end)
HCNvim.lazy(function() return require("hc-nvim.util.conducted_autocmd") end,  function(t) Util.ConductedAutocmd=t end)
HCNvim.lazy(function() return require("hc-nvim.util.conducted_highlight") end,function(t) Util.ConductedHighlight=t end)
HCNvim.lazy(function() return require("hc-nvim.util.conducted_timer") end,    function(t) Util.ConductedTimer=t end)
HCNvim.lazy(function() return require("hc-nvim.util.event") end,              function(t) Util.Event=t end)
HCNvim.lazy(function() return require("hc-nvim.util.fallback") end,           function(t) Util.Fallback=t end)
HCNvim.lazy(function() return require("hc-nvim.util.i18n") end,               function(t) Util.I18n=t end)
HCNvim.lazy(function() return require("hc-nvim.util.interface") end,          function(t) Util.Interface=t end)
HCNvim.lazy(function() return require("hc-nvim.util.key_recorder") end,       function(t) Util.KeyRecorder=t end)
HCNvim.lazy(function() return require("hc-nvim.util.keymod") end,             function(t) Util.Keymod=t end)
HCNvim.lazy(function() return require("hc-nvim.util.lazy") end,               function(t) Util.Lazy=t end)
HCNvim.lazy(function() return require("hc-nvim.util.local_env") end,          function(t) Util.LocalEnv=t end)
HCNvim.lazy(function() return require("hc-nvim.util.mod_tree") end,           function(t) Util.ModTree=t end)
HCNvim.lazy(function() return require("hc-nvim.util.option") end,             function(t) Util.Option=t end)
HCNvim.lazy(function() return require("hc-nvim.util.range_mark") end,         function(t) Util.RangeMark=t end)
HCNvim.lazy(function() return require("hc-nvim.util.reference") end,          function(t) Util.Reference=t end)
HCNvim.lazy(function() return require("hc-nvim.util.register") end,           function(t) Util.Register=t end)
HCNvim.lazy(function() return require("hc-nvim.util.rgb_format") end,         function(t) Util.RGBFormat=t end)
HCNvim.lazy(function() return require("hc-nvim.util.sheet") end,              function(t) Util.Sheet=t end)
HCNvim.lazy(function() return require("hc-nvim.util.ts_proxy") end,           function(t) Util.TSProxy=t end)
HCNvim.lazy(function() return require("hc-nvim.util.type") end,               function(t) Util.Type=t end)
HCNvim.lazy(function() return require("hc-nvim.util.wrapper") end,            function(t) Util.Wrapper=t end)
HCNvim.lazy(function() return require("hc-nvim.util.relation_graph") end,     function(t) Util.RelationGraph=t end)
HCNvim.lazy(function() return require("hc-nvim.util.response") end,           function(t) Util.Response=t end)
HCNvim.lazy(function() return require("hc-nvim.util.change_status") end,      function(t) Util.ChangeStatus=t end)
HCNvim.lazy(function() return require("hc-nvim.util.trace") end,              function(t) Util.Trace=t end)
return Util

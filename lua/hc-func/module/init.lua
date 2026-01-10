local N=require("hc-func.init_space")
local Module={}
N.lazy(function() return require("hc-func.module.cursorword") end,        function(t) Module.cursorword=t end)
N.lazy(function() return require("hc-func.module.rainbowcursor") end,     function(t) Module.rainbowcursor=t end)
N.lazy(function() return require("hc-func.module.toggler") end,           function(t) Module.toggler=t end)
N.lazy(function() return require("hc-func.module.document_highlight") end,function(t) Module.document_highlight=t end)
N.lazy(function() return require("hc-func.module.code_lens") end,         function(t) Module.code_lens=t end)
N.lazy(function() return require("hc-func.module.auto_format") end,       function(t) Module.auto_format=t end)
return Module

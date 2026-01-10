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

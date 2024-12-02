local base=require("hc-nvim.rsc.kind._meta")
---@type table<string,"">
local kinds={}
for word in pairs(base) do
 kinds[word]=""
end
return require("hc-nvim.rsc.kind")(kinds)

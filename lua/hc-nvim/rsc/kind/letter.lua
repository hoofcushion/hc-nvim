local base=require("hc-nvim.rsc.kind._meta")
---@type table<string,string>
local kinds={}
local function format(str)
 return str:sub(1,1):upper()..str:sub(2)
end
for word in pairs(base) do
 kinds[word]=format(word)
end
return require("hc-nvim.rsc.kind")(kinds)

return function(signs)
 for name,value in pairs(signs) do
  signs[name:sub(1,1)]=value
 end
 for name,value in pairs(signs) do
  signs[name:lower()]=value
 end
 for name,value in pairs(signs) do
  local int=vim.diagnostic.severity[name]
  if int~=nil then
   signs[int]=value
  end
 end
 return signs
end

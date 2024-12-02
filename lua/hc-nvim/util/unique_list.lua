local Util=require("hc-nvim.util")
local UniqueList={}
function UniqueList:new()
 local obj=Util.Class.new(UniqueList)
 obj.list={}
 obj.exists={}
 return obj
end
function UniqueList:insert(item)
 local list=self.list
 local exists=self.exists
 if exists[item]==nil then
  table.insert(list,item)
  exists[item]=#list
 end
end
function UniqueList:remove(item)
 local list=self.list
 local exists=self.exists
 local index=exists[item]
 if index~=nil then
  table.remove(list,index)
  for i=index,#list do
   exists[list[i]]=i
  end
  exists[item]=nil
 end
end
return UniqueList

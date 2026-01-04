---@class RelationGraph
local RelationGraph={
 k_to_vs={},
 v_to_ks={},
 vs_to_ks={},
 ks_to_vs={},
}
RelationGraph.__index=RelationGraph
function RelationGraph.new()
 local new=setmetatable({},RelationGraph)
 new.k_to_vs={}
 new.v_to_ks={}
 new.vs_to_ks={}
 new.ks_to_vs={}
 return new
end
function RelationGraph:write(v,k)
 do
  local ks=self.v_to_ks[v] or {}
  self.v_to_ks[v]=ks
  ks[k]=true
  local vs=self.ks_to_vs[ks] or {}
  self.ks_to_vs[ks]=vs
  vs[v]=true
 end
 do
  local vs=self.k_to_vs[k] or {}
  self.k_to_vs[k]=vs
  vs[v]=true
  local ks=self.vs_to_ks[vs] or {}
  self.vs_to_ks[vs]=ks
  ks[k]=true
 end
end
function RelationGraph:extend_k(v,ks)
 for _,k in ipairs(ks) do
  self:write(v,k)
 end
end
function RelationGraph:extend_v(vs,k)
 for _,v in ipairs(vs) do
  self:write(v,k)
 end
end
function RelationGraph:del_v(v)
 local rets={}
 local ks=self.v_to_ks[v]
 if not ks then return end
 local vs=self.ks_to_vs[ks]
 for k in pairs(ks) do
  local _vs=self.k_to_vs[k]
  if _vs then
   _vs[v]=nil
   if next(_vs)==nil then
    self.k_to_vs[k]=nil
    table.insert(rets,k)
   end
   for _v in pairs(vs) do
    local _ks=self.v_to_ks[_v]
    if _ks then
     _ks[k]=nil
     if next(ks)==nil then
      self.v_to_ks[v]=nil
      self.ks_to_vs[ks]=nil
      self.ks_to_vs[_vs]=nil
     end
    end
   end
  end
 end
 return rets
end
function RelationGraph:del_k(k)
 local vs=self.k_to_vs[k]
 if not vs then
  return
 end
 local rets={}
 local ks=self.vs_to_ks[vs]
 for v in pairs(vs) do
  local _ks=self.v_to_ks[v]
  if _ks then
   _ks[k]=nil
   if next(_ks)==nil then
    self.v_to_ks[v]=nil
    table.insert(rets,v)
   end
   for _k in pairs(ks) do
    local _vs=self.k_to_vs[_k]
    if _vs then
     _vs[v]=nil
     if next(vs)==nil then
      self.k_to_vs[k]=nil
      self.vs_to_ks[vs]=nil
      self.ks_to_vs[_ks]=nil
     end
    end
   end
  end
 end
 return rets
end
function RelationGraph:read_k(k)
 return self.k_to_vs[k]
end
function RelationGraph:read_v(v)
 return self.v_to_ks[v]
end
function RelationGraph.example()
 -- define a hook list
 local hooks={
  {
   name="hook 1",
   events={"a","b"},
   callback=function()
    print("1")
   end,
  },
  {
   name="hook 2",
   events={"a","c"},
   callback=function()
    print("2")
   end,
  },
 }
 -- define a event list
 local events={"a","b","c"}
 -- new relation graph
 local rg=RelationGraph.new()
 -- register hooks with thier events
 for _,hook in ipairs(hooks) do
  rg:extend_k(hook,hook.events)
 end
 -- process event list
 -- del each event, then return hook list
 for _,event in ipairs(events) do
  local _hooks=rg:del_k(event)
  if _hooks then
   for _,hook in ipairs(_hooks) do
    print(event,"Triggered",hook.name)
    -- hook.callback()
   end
  end
 end
 -- relation graph is symmetrical
 for _,hook in ipairs(hooks) do
  rg:extend_v(hook.events,hook)
 end
 for _,event in ipairs(events) do
  local _events=rg:del_v(event)
  if _events then
   for _,hook in ipairs(_events) do
    print(event,"Triggered",hook.name)
   end
  end
 end
 -- it can also do reverse lookup
 for _,hook in ipairs(hooks) do
  rg:extend_k(hook,hook.events)
 end
 for _,hook in ipairs(hooks) do
  local _events=rg:read_v(hook)
  for k in pairs(_events) do
   print(hook.name,"Link to",k)
  end
 end
end
return RelationGraph

local unpack=table.unpack or unpack
local function packlen(...)
 return {n=select("#",...),...}
end
local function unpacklen(pack,i)
 return unpack(pack,i or 1,pack.n)
end
--- pack a iterator tulple into a closure
local function compress(next,t,k)
 return function()
  local tp=packlen(next(t,k))
  if tp[1]==nil then return end
  k=tp[1]
  return unpacklen(tp)
 end
end
--- concat a map at
local function concat(map,next)
 local function map_next(t,k)
  local tp=packlen(next(t,k))
  if tp[1]==nil then return end
  k=tp[1]
  local tpv=packlen(map(unpacklen(tp)))
  if tpv[1] then
   return unpacklen(tpv)
  end
  return map_next(t,k)
 end
 return map_next
end
local Iter={}
local _Iter={__index=Iter}
function Iter.new(next)
 local obj=setmetatable({},_Iter)
 obj.next=next
 return obj
end
function Iter.from(next,t,k)
 return Iter.new(compress(next,t,k))
end
function Iter:map(fn)
 return Iter.new(concat(fn,self.next))
end
function Iter:filter(fn)
 return self:map(function(...)
  if fn(...) then
   return ...
  end
 end)
end
function Iter:on(tbl)
 local ret={}
 local i=1
 for k,v in self.next,tbl do
  ret[i]={k,v}
 end
 return ret
end
function Iter:run(fn)
 return self:map(function(...)
  fn(...)
  return ...
 end)
end
function Iter:iterate(tbl)
 return self.next,tbl
end
-- Iter.from(pairs({1,2,3}))
--  :run(print)
--  :on({1,2,3})
-- local iter=Iter.new(next)
--  :filter(function(_,x) return x%2==0 end)
--  :map(function(_,x) return _,x*2 end)
-- iter
--  :run(print)
--  :on({1,2,3,4,5,6})
-- print("---")
-- iter
--  :run(print)
--  :on({11,12,13,14,15,16})
-- print("---")
-- for _,v in iter:iterate({1,2,3,4,5}) do
--  print(v)
-- end

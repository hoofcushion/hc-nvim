local TimeUsed={
 logs={},
}
function TimeUsed.log(start,finish,name)
 local usedtime=(finish-start)*1000
 TimeUsed.logs[name]=TimeUsed.logs[name] or {
  name=name,
  usedtime=0,
  count=0,
 }
 local spec=TimeUsed.logs[name]
 spec.usedtime=spec.usedtime+usedtime
 spec.count=spec.count+1
end
local clock=function()
 return vim.uv.hrtime()/(10^9)
end
local function _fn(...)
end
function TimeUsed.create(fn,name)
 name=name or fn
 local function count(...)
  local start=clock()
  local ret={fn(...)}
  local fix_start=clock()
  _fn(...)              --- fix for pass parameters
  local _={unpack(ret)} --- fix for creating table
  local fix_end=clock()
  TimeUsed.log(start,clock()-(fix_end-fix_start),name)
  return unpack(ret)
 end
 return count
end
local last
function TimeUsed.track(name)
 if last then
  TimeUsed.log(last.start,clock(),last.name)
  last=nil
 elseif name~=nil then
  last={name=name,start=clock()}
 end
end
local function tacit(obj)
 return function(fn,...)
  if fn==nil then
   return obj
  end
  return tacit(fn(obj,...))
 end
end
function TimeUsed.print(sort)
 local total=0
 for _,v in pairs(TimeUsed.logs) do
  total=total+v.usedtime
 end
 local query={}
 for _,v in pairs(TimeUsed.logs) do
  local spec={
   name=v.name,
   usedtime=v.usedtime,
   count=v.count,
   avgtime=v.usedtime/v.count,
   avgusage=v.usedtime/total*100,
  }
  table.insert(query,spec)
 end
 if next(query)==nil then
  return
 end
 sort=sort or "usedtime"
 table.sort(query,function(a,b)
  return a[sort]>b[sort]
 end)
 for _,spec in ipairs(query) do
  spec.name=("%s"):format(spec.name)
  spec.usedtime=("%.6fms"):format(spec.usedtime)
  spec.count=("%s"):format(spec.count)
  spec.avgtime=("%.6fms"):format(spec.avgtime)
  spec.avgusage=("%.3f%%"):format(spec.avgusage)
 end
 local length={}
 for _,spec in ipairs(query) do
  for entry,v in pairs(spec) do
   length[entry]=math.max(length[entry] or 0,#v)
  end
 end
 local entries={"name","usedtime","count","avgtime","avgusage"}
 local format={}
 for _,entry in ipairs(entries) do
  table.insert(format,"%-"..tostring(length[entry]).."s")
 end
 format=table.concat(format,"|")
 local ret={
  "Total: "..tostring(total),
  format:format(unpack(entries)),
 }
 for _,spec in ipairs(query) do
  local values={}
  for _,entry in ipairs(entries) do
   table.insert(values,spec[entry])
  end
  table.insert(ret,(
   format:format(unpack(values))
  ))
 end
 print(table.concat(ret,"\n"))
end
return TimeUsed

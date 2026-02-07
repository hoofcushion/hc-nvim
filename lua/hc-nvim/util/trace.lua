---@class Trace
---@field entries table[]
---@field level fun():integer
local Trace={}
Trace.__index=Trace
-- 级别常量函数
Trace.TRACE=function() return vim.log.levels.TRACE end
Trace.DEBUG=function() return vim.log.levels.DEBUG end
Trace.INFO=function() return vim.log.levels.INFO end
Trace.WARN=function() return vim.log.levels.WARN end
Trace.ERROR=function() return vim.log.levels.ERROR end
Trace.OFF=function() return vim.log.levels.OFF end
Trace.ALL=function() return -math.huge end
Trace.NONE=function() return math.huge end
local ignore; ignore=setmetatable({},{
 __index=function() return ignore end,
 __call=function() end,
 __tostring="ignored",
})
Trace.Ignore=ignore
---@param level? integer|fun():integer
function Trace.new(level)
 local obj=setmetatable({},Trace)
 obj.entries={}
 obj:set_level(level)
 return obj
end
function Trace:record(level,type,msg,data)
 local entry={time=os.time(),level=level,type=type,msg=msg,data=data}
 table.insert(self.entries,entry)
 if level>=self:level() then
  vim.notify(msg,level)
 end
 return entry
end
-- 快捷方法
function Trace:trace(type,msg,data)
 return self:record(vim.log.levels.TRACE,type,msg,data)
end
function Trace:debug(type,msg,data)
 return self:record(vim.log.levels.DEBUG,type,msg,data)
end
function Trace:info(type,msg,data)
 return self:record(vim.log.levels.INFO,type,msg,data)
end
function Trace:warn(type,msg,data)
 return self:record(vim.log.levels.WARN,type,msg,data)
end
function Trace:error(type,msg,data)
 return self:record(vim.log.levels.ERROR,type,msg,data)
end
-- 设置level函数
function Trace:set_level(level)
 if type(level)=="function" then
  self.level=level
 else
  self.level=function() return level or vim.log.levels.INFO end
 end
end
-- 获取过滤后的条目
function Trace:filter(level)
 local result={}
 for _,entry in ipairs(self.entries) do
  if entry.level==level then
   table.insert(result,entry)
  end
 end
 return result
end
-- 获取最终摘要
function Trace:get_summary()
 return {
  traces=self:filter(vim.log.levels.TRACE),
  debugs=self:filter(vim.log.levels.DEBUG),
  infos=self:filter(vim.log.levels.INFO),
  warnings=self:filter(vim.log.levels.WARN),
  errors=self:filter(vim.log.levels.ERROR),
 }
end
-- 清空记录
function Trace:clear()
 self.entries={}
end
-- 打印摘要
function Trace:write_summary()
 local summary=self:get_summary()
 print("=== Trace Summary ===")
 print(string.format("Total entries: %d",#self.entries))
 print(string.format("  Traces: %d",#summary.traces))
 print(string.format("  Debugs: %d",#summary.debugs))
 print(string.format("  Infos: %d",#summary.infos))
 print(string.format("  Warnings: %d",#summary.warnings))
 print(string.format("  Errors: %d",#summary.errors))
end
return Trace

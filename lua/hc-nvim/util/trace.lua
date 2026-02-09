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
if false then
 ---@class Trace.Entry
 local Struct_Entry={
  time=0,
  level=0,
  type=nil,
  msg=nil,
  data=nil,
 }
end
---@param level integer
---@param type any
---@param msg any
---@param data? any
---@return Trace.Entry
function Trace:record(level,type,msg,data)
 local entry={time=os.time(),level=level,type=type,msg=msg,data=data}
 table.insert(self.entries,entry)
 if level>=self:level() then
  vim.notify(tostring(msg),level)
 end
 return entry
end
---@param type any
---@param msg any
---@param data? any
---@return Trace.Entry
function Trace:trace(type,msg,data) return self:record(vim.log.levels.TRACE,type,msg,data) end
---@param type any
---@param msg any
---@param data? any
---@return Trace.Entry
function Trace:debug(type,msg,data) return self:record(vim.log.levels.DEBUG,type,msg,data) end
---@param type any
---@param msg any
---@param data? any
---@return Trace.Entry
function Trace:info(type,msg,data) return self:record(vim.log.levels.INFO,type,msg,data) end
---@param type any
---@param msg any
---@param data? any
---@return Trace.Entry
function Trace:warn(type,msg,data) return self:record(vim.log.levels.WARN,type,msg,data) end
---@param type any
---@param msg any
---@param data? any
---@return Trace.Entry
function Trace:error(type,msg,data) return self:record(vim.log.levels.ERROR,type,msg,data) end
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
 ---@class Trace.Summary
 local summary={
  traces={},
  debugs={},
  infos={},
  warnings={},
  errors={},
 }
 local map={
  [vim.log.levels.TRACE]=summary.traces,
  [vim.log.levels.DEBUG]=summary.debugs,
  [vim.log.levels.INFO]=summary.infos,
  [vim.log.levels.WARN]=summary.warnings,
  [vim.log.levels.ERROR]=summary.errors,
 }
 for _,entry in ipairs(self.entries) do
  local sub_list=map[entry.level]
  if sub_list then
   table.insert(sub_list,entry)
  end
 end
 return summary
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
--- 按顺序dump指定级别及以上的所有记录
---@param level? integer 日志级别，默认为INFO
---@return table[]
function Trace:dump(level)
 level=level or vim.log.levels.INFO
 local result={}
 for _,entry in ipairs(self.entries) do
  if entry.level>=level then
   table.insert(result,entry)
  end
 end
 return result
end
function Trace:dump_string(level)
 level=level or vim.log.levels.INFO
 local entries=self:dump(level)
 local lines={}
 local level_names={
  [vim.log.levels.TRACE]="TRACE",
  [vim.log.levels.DEBUG]="DEBUG",
  [vim.log.levels.INFO]="INFO",
  [vim.log.levels.WARN]="WARN",
  [vim.log.levels.ERROR]="ERROR",
 }
 for i,entry in ipairs(entries) do
  local time_str=os.date("%Y-%m-%d %H:%M:%S",entry.time)
  local level_str=level_names[entry.level] or tostring(entry.level)
  local line=string.format("[%s] %-5s %s: %s",
   time_str,level_str,entry.type or "",entry.msg or "")
  if entry.data then
   line=line.." | "..vim.inspect(entry.data)
  end
  lines[i]=line
 end
 return table.concat(lines,"\n")
end
-- 清空记录
function Trace:clear()
 self.entries={}
end
return Trace

if false then
 ---@class UnitTest.Case
 local case={
  name=Lua.string,
  test=Lua._function,
  expect=Lua._function, ---@type fun(...):boolean
 }
 ---@class UnitTest.Record
 local record={
  status=Lua.union("passed","error","failed"),
  result={Lua.boolean,Lua.list(Lua.any)},
  expect=Lua._function, ---@type fun(...):boolean
 }
 ---@class UnitTest
 local UnitTest={
  cases=Lua.list(case), ---@private
  records=Lua.list(record), ---@private
  buf=Lua.integer, ---@private
 }
end
---@class UnitTest
local UnitTest={
 cases={},
 records={},
}
---@param case UnitTest.Case
function UnitTest:add_case(case)
 table.insert(self.cases,case)
end
---@param cases UnitTest.Case[]
function UnitTest:add_cases(cases)
 for _,case in ipairs(cases) do
  self:add_case(case)
 end
end
---@param record UnitTest.Record
function UnitTest:add_record(record)
 table.insert(self.records,record)
end
---@param expect function
---@param ... any
---@return boolean
local function check_result(expect,...)
 if type(expect)=="function" then
  return (function(ok,...) return ok and (...) end)(pcall(expect,...))
 end
 return expect==(...)
end
---@private
function UnitTest:run_cases()
 self.records={}
 for _,case in pairs(self.cases) do
  local ok,result=(function(_,...) return _,{n=select("#",...),...} end)(pcall(case.test,case))
  local status
  if not ok then
   status="error"
  elseif check_result(case.expect,unpack(result,1,result.n)) then
   status="passed"
  else
   status="failed"
  end
  self:add_record({status=status,result=result,expect=case.expect})
 end
 print(#self.cases,#self.records)
end
---@param str string
---@return string
local function smart_qoute(str)
 if string.gsub(str,'"',"")>string.gsub(str,"'","") then
  str=string.gsub(str,"[\"']",function(v)
   return v=="'" and '"' or "'"
  end)
 end
 str=string.format("%q",str)
 return str
end
---@param t any[]
---@return string
local function format_list(t)
 local buffer={}
 for _,v in ipairs(t) do
  if type(v)=="string" then
   v=smart_qoute(v)
  else
   v=tostring(v)
  end
  table.insert(buffer,v)
 end
 return table.concat(buffer,"	")
end
---@private
---@return string[]
function UnitTest:get_summary()
 local buffer={}
 local status_counts={passed=0,failed=0,error=0}
 table.insert(buffer,"Cases: ")
 for i,entry in ipairs(self.records) do
  local test=self.cases[i]
  table.insert(buffer,string.format("  Name: %-25s  Status: %-6s  Expect: %-6s  Result: %s",test.name,entry.status,entry.expect,format_list(entry.result)))
  if entry.status=="error" then
   table.insert(buffer,string.format("  Error: %s",entry.result[2]))
  end
  status_counts[entry.status]=status_counts[entry.status]+1
 end
 table.insert(buffer,string.format("Total Cases: %d",#self.records))
 table.insert(buffer,string.format("  Passed: %d",status_counts.passed))
 table.insert(buffer,string.format("  Failed: %d",status_counts.failed))
 table.insert(buffer,string.format("  Errors: %d",status_counts.error))
 return buffer
end
---@private
---@return integer
function UnitTest:getbuf()
 if not self.buf then
  -- 创建新缓冲区
  local buf=vim.api.nvim_create_buf(false,true)
  if buf==0 then
   error("Failed to create buffer")
  end
  self.buf=buf
 end
 return self.buf
end
---@private
function UnitTest:print()
 local buf=self:getbuf()
 -- 设置缓冲区选项
 vim.api.nvim_buf_set_name(buf,"MyCustomBuffer")
 vim.api.nvim_set_option_value("buftype", "nofile",{buf=buf})
 vim.api.nvim_set_option_value("filetype","text",  {buf=buf})
 -- 要写入的内容
 local lines=self:get_summary()
 vim.api.nvim_buf_set_lines(buf,0,-1,false,lines)
 vim.api.nvim_set_current_buf(buf)
end
function UnitTest:test()
 self:run_cases()
 self:print()
end
function UnitTest.new()
 local obj=setmetatable({},{__index=UnitTest})
 obj.cases={}
 obj.records={}
 return obj
end
return UnitTest

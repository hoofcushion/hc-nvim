---@alias StringOrTable string|table<string,string>|string[]
---@alias ValidScope string
---@alias Options table<string, any>
---@alias ScopeOpts table<string, Options>

---将值转换为选项字符串
---@param value StringOrTable
---@return string
local function to_option(value)
 if type(value)~="table" then
  return value
 end
 local ret={}
 -- 处理数组式表格
 if value[1]~=nil then
  for _,v in ipairs(value) do
   table.insert(ret,tostring(v))
  end
 else
  -- 处理键值对表格
  for k,v in pairs(value) do
   table.insert(ret,k..":"..v)
  end
 end
 return table.concat(ret,",")
end

-- 有效的选项作用域
local VALID_SCOPES={
 o=true,
 go=true,
 wo=true,
 bo=true,
 opt=true,
 opt_global=true,
 opt_local=true,
 env=true,
 g=true,
 v=true,
 b=true,
 w=true,
 t=true,
}
-- 需要延迟设置的选项
local DELAYED_OPTIONS={
 clipboard="SafeState",
}
---设置选项值
---@param scope ValidScope
---@param name string
---@param value StringOrTable
local function set_option(scope,name,value)
 if DELAYED_OPTIONS[name] then
  local event=DELAYED_OPTIONS[name]
  vim.api.nvim_create_autocmd(event,{
   once=true,
   callback=function()
    set_option(scope,name,value)
   end,
  })
  DELAYED_OPTIONS[name]=nil
  return
 end
 vim[scope][name]=to_option(value)
end

---获取包含指定缓冲区的所有窗口
---@param buf integer 缓冲区ID
---@return integer[] 窗口ID列表
local function get_windows_for_buf(buf)
 local wins={}
 for _,win in ipairs(vim.api.nvim_list_wins()) do
  if vim.api.nvim_win_get_buf(win)==buf then
   table.insert(wins,win)
  end
 end
 return wins
end

---在缓冲区关联的所有窗口中执行函数
---@param buf integer 缓冲区ID
---@param fn function 要执行的函数
local function local_do(buf,fn)
 local wins=get_windows_for_buf(buf)
 for _,win in ipairs(wins) do
  vim.api.nvim_win_call(win,function()
   vim.api.nvim_buf_call(buf,function()
    fn()
   end)
  end)
 end
end

---@class AutoOptsSpec
---@field event string|string[]? 触发事件
---@field pattern string|string[]? 匹配模式
---@field scheduled boolean? 是否调度执行
---@field options ScopeOpts 选项配置

---@alias OptSpec AutoOptsSpec|ScopeOpts|OptSpec[]

local Option={}
---@param opts OptSpec
local function set_list(opts)
 for _,v in ipairs(opts) do
  Option.set(v)
 end
end
---@param opts AutoOptsSpec
local function set_auto(opts)
 local event=opts.event or "FileType"
 local function local_set(buf,options)
  local_do(buf,function()
   Option.set(options)
  end)
 end

 local callback=local_set
 if opts.scheduled then
  callback=vim.schedule_wrap(callback)
 end
 vim.api.nvim_create_autocmd(event,{
  pattern=opts.pattern,
  callback=function(env)
   callback(env.buf,opts.options)
  end,
 })
end
---@param opts ScopeOpts
local function set_scoped(opts)
 for scope,options in pairs(opts) do
  if VALID_SCOPES[scope] then
   for name,value in pairs(options) do
    set_option(scope,name,value)
   end
  end
 end
end
---@param opts OptSpec 选项配置
function Option.set(opts)
 if #opts~=0 then
  return set_list(opts)
 end
 if opts.pattern and opts.options then
  return set_auto(opts)
 end
 set_scoped(opts)
end
return Option

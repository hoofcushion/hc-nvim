--- ---
--- A reference of a table is a fake table that correspond to key index
--- And return real value of that index, but it block all newindex.
--- ---
local Util=require("hc-nvim.util.init_space")
local Reference={}
--- return a reference table of `main`
--- non table value and plian table will be automaticly dereference
--- table reference need ref() to dereference
--- example:
---```lua
--- local raw={
---  a={
---   b="c",
---  },
--- }
--- local t=Ref.create(raw)
---
--- t.a.b=nil
--- print(t.a.b) -- "c"
---
--- raw.a.b=nil
--- print(t.a.b) -- nil
---
--- print(t.a()) -- { b = "c" }
---
--- t.a().d="e"
--- print(t.a().d) -- "e"
---```
local function node(ref,keys)
 -- non table value auto dereference
 local orig=Util.tbl_get(ref(),keys)
 if type(orig)~="table" then
  return orig
 end
 -- plain table auto dereference
 local nested=false
 for _,v in pairs(orig) do
  if type(v)=="table" then
   nested=true
   break
  end
 end
 local tbl=nested and {} or Util.copy(orig)
 -- reference proxy for table
 return setmetatable(tbl,{
  __index=function(_,k)
   local _keys=Util.deepcopy(keys)
   table.insert(_keys,k)
   return node(ref,_keys)
  end,
  __newindex=function()
  end,
  __call=function()
   return Util.tbl_get(ref(),keys)
  end,
 })
end
---@generic T
---@param main T
---@return T
function Reference.create(main)
 return node(function() return (main) end,{})
end
--- Use `sup` to keep access local environment's table locals
---@generic T
---@param sup fun():T
---@return T
function Reference.get(sup)
 return node(sup,{})
end
if UnitTest then
 UnitTest:add_cases({
  -- 基础访问测试
  {
   name="reference_basic_access",
   expect=true,
   test=function()
    local raw={a=1,b="hello"}
    local ref=Reference.create(raw)
    return ref.a==1 and ref.b=="hello"
   end,
  },

  -- 嵌套访问测试
  {
   name="reference_nested_access",
   expect=true,
   test=function()
    local raw={a={b={c="nested"}}}
    local ref=Reference.create(raw)
    return ref.a.b.c=="nested"
   end,
  },

  -- 实时性测试
  {
   name="reference_realtime_update",
   expect=true,
   test=function()
    local raw={options={value="initial"}}
    local ref=Reference.create(raw)
    raw.options.value="updated"
    return ref.options.value=="updated"
   end,
  },

  -- 写保护测试
  {
   name="reference_write_protection",
   expect=true,
   test=function()
    local raw={a=1}
    local ref=Reference.create(raw)
    ref.a=2
    return raw.a==1
   end,
  },

  -- 解引用测试
  {
   name="reference_dereference",
   expect=true,
   test=function()
    local raw={a={b="value"}}
    local ref=Reference.create(raw)
    return ref.a().b=="value"
   end,
  },

  -- 自动解引用测试（非表值）
  {
   name="reference_auto_dereference",
   expect=true,
   test=function()
    local raw={str="hello",num=42}
    local ref=Reference.create(raw)
    return type(ref.str)=="string" and type(ref.num)=="number"
   end,
  },

  -- Reference.get 功能测试
  {
   name="reference_get_function",
   expect=true,
   test=function()
    local env={value="test"}
    local ref=Reference.get(function() return env end)
    return ref.value=="test"
   end,
  },
 })
end
return Reference

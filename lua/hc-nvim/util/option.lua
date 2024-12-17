---@param value string|table<string,string>|string[]
local function to_option(value)
 if type(value)=="table" then
  local ret={}
  if value[1]~=nil then
   for _,v in ipairs(value) do
    table.insert(ret,tostring(v))
   end
  else
   for k,v in pairs(value) do
    table.insert(ret,k..":"..v)
   end
  end
  value=table.concat(ret,",")
 end
 return value
end
local is_valid={
 o         =true,
 go        =true,
 wo        =true,
 bo        =true,
 opt       =true,
 opt_global=true,
 opt_local =true,
 env       =true,
 g         =true,
 v         =true,
 b         =true,
 w         =true,
 t         =true,
}
--- some option is slow to set, lazy load it for startup speed
local delay={
 clipboard="SafeState",
}
local function set(scope,name,value)
 if delay[name] then
  vim.api.nvim_create_autocmd(delay[name],{
   once=true,
   callback=function()
    set(scope,name,value)
   end,
  })
  delay[name]=nil
  return
 end
 vim[scope][name]=to_option(value)
end
---@alias options table<string,any>
---@alias scope_options table<string,table<string,any>>
local Option={}
---@class AutoOptsSpec
---@field event   string|string[]?
---@field pattern nil|string|string[]
---@field options scope_options
---@type AutoOptsSpec[]
---@alias OptSpec AutoOptsSpec|scope_options|OptSpec[]
---@param opts OptSpec
function Option.set(opts)
 if #opts~=0 then
  for _,v in ipairs(opts) do
   Option.set(v)
  end
 elseif opts.options then
  vim.api.nvim_create_autocmd(opts.event or "filetype",{
   pattern=opts.pattern,
   callback=function()
    Option.set(opts.options)
   end,
  })
  return
 end
 for scope,opt in pairs(opts) do
  for name,value in pairs(opt) do
   if is_valid[scope] then
    set(scope,name,value)
   end
  end
 end
end
return Option

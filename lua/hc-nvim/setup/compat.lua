---@class HC-Nvim.Compat
local Compat={}
---@type table<string, {orig: function, setter: function, hooks: function[]}>
Compat.hooks={}
---注册一个兼容性 hook
---@param id string 标识符
---@param orig function 返回原始函数的函数
---@param setter function 写回函数，如 function(v) vim.api.nvim_create_autocmd = v end
---@param fn function hook 逻辑，接收 (args, orig)，返回修改后的 args
function Compat.register(id,orig,setter,fn)
 if not Compat.hooks[id] then
  Compat.hooks[id]={orig=orig,setter=setter,hooks={}}
 end
 table.insert(Compat.hooks[id].hooks,fn)
end
local function okpack(ok,...)
 return ok,{n=select("#",...),...}
end
function Compat.setup()
 for id,group in pairs(Compat.hooks) do
  local orig=group.orig() -- 保存原始函数引用
  local wrapped=function(...)
   local args={n=select("#",...),...}
   for _,fn in ipairs(group.hooks) do
    local ok,result=okpack(pcall(fn,unpack(args,1,args.n)))
    if ok then
     args=result
    else
     vim.notify(string.format("[Compat] Hook '%s' failed",id),vim.log.levels.WARN)
    end
   end
   return orig(unpack(args,1,args.n))
  end
  group.setter(wrapped)
 end
end
-- 注册 BufModifiedSet hook，最新 nightly BufModifiedSet 已被移除，部分插件未跟进
Compat.register("nvim_create_autocmd",
 function() return vim.api.nvim_create_autocmd end,
 function(v) vim.api.nvim_create_autocmd=v end,
 function(event,opts)
  if type(event)=="string" and event=="BufModifiedSet" then
   event="OptionSet"
   opts=vim.deepcopy(opts or {})
   opts.pattern="modified"
  elseif type(event)=="table" then
   local modified=false
   for i,e in ipairs(event) do
    if e=="BufModifiedSet" then
     modified=true
     event[i]="OptionSet"
    end
   end
   if modified then
    opts=vim.deepcopy(opts or {})
    opts.pattern="modified"
   end
  end
  return event,opts
 end
)
return Compat

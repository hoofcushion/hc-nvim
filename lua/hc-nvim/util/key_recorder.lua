---@alias KeyRecorder.hook fun(key:string,...:any)
---@alias KeyRecorder.body fun(key:string,...:any):boolean
---@alias KeyRecorder.replace fun(key:string,...:any):string
---
---@class KeyRecorder
local K={
 key="",
 keys="",
 key_seq={}, ---@type string[]
}
---@class KeyRecorder
--- Syntax sugar for scheduled function
local S=setmetatable({},{
 __newindex=function(_,k,v)
  K[k]=vim.schedule_wrap(v)
 end,
})
function K.keyseq()
 local keys=table.concat(K.key_seq)
 K.key_seq={}
 return keys
end
function K.getchar()
 local key=vim.fn.getcharstr()
 table.insert(K.key_seq,key)
 K.key=key
 return key
end
--- Schedule version of getcharstr
S.getchar_next=K.getchar
function K.recievechar()
 local key=K.getchar()
 vim.api.nvim_feedkeys(key,"m",false)
 return key
end
--- Schedule version of recievekey
S.recievechar_next=K.recievechar
---
--- monitor next `char` and call the `hook` with it.
--- `hook`(`key: string`, `...any`)
--- - `key` the character it gets.
--- - `...` the other parameters from the first place.
---@param hook KeyRecorder.hook
---@param ... any
---@return string
function K.hookchar(hook,...)
 local key=K.recievechar()
 hook(key,...)
 return key
end
S.hookchar_next=K.hookchar
---
--- block next `char` and call the `hook` with it.
--- `hook`(`key: string`, `...any`)
--- - `key` the character it gets.
--- - `...` the other parameters from the first place.
---@param repl KeyRecorder.replace
---@param ... any
---@return string
function K.replacechar(repl,...)
 local key=K.getchar()
 key=repl(key,...)
 if key~=nil then
  vim.api.nvim_feedkeys(key,"m",false)
 end
 return key or ""
end
S.replacechar_next=K.replacechar
local function escape(str)
 return string.gsub(str,"([%^%%%%[%]%-$().*+?])","%%%1")
end
function K.getchars(target)
 if type(target)=="number" then
  for _=1,target do
   K.getchar()
  end
  return true,K.keyseq()
 end
 local chars=""
 for _=1,#target do
  chars=chars..K.getchar()
  if nil==string.find(target,"^"..escape(chars)) then
   return false,K.keyseq()
  end
 end
 return true,K.keyseq()
end
S.getchars_next=K.getchars
function K.recievechars(target)
 local ok,chars=K.getchars(target)
 vim.api.nvim_feedkeys(chars,"m",false)
 return ok,chars
end
S.recievechars_next=K.recievechars
---
--- Get key string by `target`.
--- Then call `hook` with this key string and the `...`.
---@param target string
---@param hook KeyRecorder.hook
---@param ... any
---@return string
function K.hookchars(target,hook,...)
 local _,keys=K.recievechars(target)
 hook(keys,...)
 return keys
end
S.hookchars_next=K.hookchars
---
--- Get key string by `target`.
--- Then call `hook` with this key string and the `...`.
---@param target string
---@param repl KeyRecorder.replace
---@param ... any
---@return string
function K.replacechars(target,repl,...)
 local _,keys=K.getchars(target)
 keys=repl(keys,...)
 if keys~=nil then
  vim.api.nvim_feedkeys(keys,"m",false)
 end
 return keys or ""
end
S.replacechars_next=K.replacechars
---
---@generic key
---@param lhs string
---@param keys key[]
---@return fun():key
function K.loop_keys(lhs,keys)
 local i,max=1,#keys
 local function iter(str)
  i=str==lhs and i%max+1 or 1
 end
 return function()
  K.hookchars_next(lhs,iter)
  return keys[i]
 end
end
---
---@generic key
---@param lhs string
---@param map table<vim.api.keyset.set_keymap.mode,string>
---@param esc table<vim.api.keyset.set_keymap.mode,string>
---@return fun():key
function K.loop_keys_with_mode(lhs,map,esc)
 return function()
  K.recievechars_next(lhs)
  local mode=vim.api.nvim_get_mode().mode
  if K.key==lhs then
   return map[mode] or lhs
  end
  return esc[mode] or lhs
 end
end
return K

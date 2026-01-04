---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
---@param stack integer?
function Util.get_source(stack)
 local info=debug.getinfo(stack~=nil and stack or 2,"S")
 return info and info.source:sub(2) or "?"
end
Util.root_path=vim.fn.fnamemodify(Util.get_source(),":h:h:h:h:h")
Util.paths={
 Util.root_path,
 vim.fn.stdpath("config"),
}
do
 local opts={paths=Util.paths,rtp=false}
 local function _find_local_mod(modname)
  return vim.loader.find(modname,opts)[1]
 end
 function Util.find_local_mod(...)
  return Util.batch(_find_local_mod,...)
 end
end
--- Similar to `require`, but slightly faster
--- It only search module in `Util.paths`
function Util.local_require(modname)
 local info=Util.find_local_mod(modname)
 if info then
  local ret=assert(loadfile(info.modpath))() or true
  package.loaded[modname]=ret
  return ret
 end
 return nil
end
---@return unknown
function Util.path_require(modname,modpath)
 local ret=assert(loadfile(modpath))() or true
 package.loaded[modname]=ret
 return ret
end
if false then
 Util.path_require=require
end
do
 local function _find_file(modname)
  return vim.loader.find(modname,{patterns={""}})[1]
 end
 function Util.find_file(...)
  return Util.batch(_find_file,...)
 end
end
do
 local function _find_mod(modname)
  return vim.loader.find(modname)[1]
 end
 function Util.find_mod(...)
  return Util.batch(_find_mod,...)
 end
end
do
 local function _iter_mod(modnames)
  for _,modname in Util.pipairs(modnames) do
   local dir=Util.find_file(modname)
   if dir then
    for name in vim.fs.dir(dir.modpath) do
     local mod=Util.find_mod(modname.."."..Util.trimsuffix(name,".lua"))
     if mod then
      coroutine.yield(mod.modname,mod.modpath)
     end
    end
   end
  end
 end
 --- Get all mod starts in giving prefix
 ---@param modnames string|string[]
 ---@return fun():string
 ---@return any
 function Util.iter_mod(modnames)
  return coroutine.wrap(_iter_mod),modnames
 end
end
---@param path string
---@param fn fun(name: string, type: string, full_path: string)
function Util.scan(path,fn)
 for name,type in vim.fs.dir(path) do
  local full_path=path.."/"..name
  fn(name,type,full_path)
  if type=="directory" then
   Util.scan(full_path,fn)
  end
 end
end
---@param full_path string
---@param base_path string
---@return string[]
local function get_relative_parts(full_path,base_path)
 local relative_path=full_path:sub(#base_path+2)
 local parts={}
 for part in relative_path:gmatch("[^/]+") do
  table.insert(parts,part)
 end
 return parts
end
---@param modname string
---@return table
function Util.create_modmap(modname)
 local found=vim.loader.find(modname,{patterns={""}})[1]
 local modpath=found and found.modpath or nil
 if not modpath then
  return {}
 end
 local modmap={}
 Util.scan(modpath,function(name,type,full_path)
  local parts=get_relative_parts(full_path,modpath)
  local current_table=modmap
  for i,part in ipairs(parts) do
   if i==#parts and type=="file" then
    local clean_name=part:gsub("%.lua$","")
    current_table[clean_name]=full_path
   else
    current_table[part]=current_table[part] or {}
    current_table=current_table[part]
   end
  end
 end)
 return modmap
end

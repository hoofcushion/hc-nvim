---@class HC-Nvim.Util
local Util=require("hc-nvim.util.init_space")
---@param stack integer?
function Util.get_source(stack)
 local info=debug.getinfo(stack~=nil and stack or 2,"S")
 return info and info.source:sub(2) or "?"
end
Util.root_path=vim.fn.fnamemodify(Util.get_source(),":h:h:h:h:h")
---@return unknown
function Util.path_require(modname,modpath)
 local fn=assert(loadfile(modpath))
 local ret=fn()
 if not ret then
  ret=true
 end
 package.loaded[modname]=ret
 return ret
end
local function with_fallback(fn,...)
 for i=1,select("#",...) do
  local ret=fn(select(i,...))
  if ret then return ret end
 end
end
local function _find_file(modname)
 return vim.loader.find(modname,{patterns={""}})[1]
end
function Util.find_file(...)
 return with_fallback(_find_file,...)
end
local function _find_mod(modname)
 return vim.loader.find(modname)[1]
end
function Util.find_mod(...)
 return with_fallback(_find_mod,...)
end
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
local function list_files(res,path)
 for name,type in vim.fs.dir(path) do
  local full_path=path.."/"..name
  if type=="directory" then
   list_files(res,full_path)
  else
   table.insert(res,full_path)
  end
 end
end
---@param path string
---@return string[] 文件路径列表
function Util.list_files(path)
 local result={}
 local stat=vim.uv.fs_stat(path)
 if stat and stat.type=="directory" then
  list_files(result,path)
 end
 return result
end
local function build_path(modmap,modpath,full_path)
 local relative_path=full_path:sub(#modpath+2)
 local current_table=modmap
 local list=Util.split(relative_path,"/")
 local len=#list
 for i,part in ipairs(list) do
  local clean_name=Util.trimsuffix(part,".lua")
  if i==len then
   current_table[clean_name]=full_path
  else
   current_table[part]=current_table[part] or {}
   current_table=current_table[part]
  end
 end
end
-- print(table.concat(Util.split(relative_path,"/"),"/"))
---@param modname string
---@return table
function Util.create_modmap(modname)
 local found=vim.loader.find(modname,{patterns={""}})[1]
 local modpath=found and found.modpath or nil
 if modpath==nil then
  return {}
 end
 local modmap={}
 local files=Util.list_files(modpath)
 for _,full_path in ipairs(files) do
  build_path(modmap,modpath,full_path)
 end
 return modmap
end

local uv=vim.uv
---@param s1 uv.fs_stat.result
---@param s2 uv.fs_stat.result
---@return boolean
local function uv_stat_eq(s1,s2)
 if  s1~=nil
 and s2~=nil
 and s1.size==s2.size
 and s1.type==s2.type
 and s1.mtime.sec==s2.mtime.sec
 and s1.mtime.nsec==s2.mtime.nsec
 then
  return true
 end
 return false
end
--- @param path string
--- @param content string
local function writefile(path,content)
 local f=io.open(path,"w")
 if f then
  f:write(content)
  f:close()
 end
end
--- @param path string
--- @return string?
local function readfile(path)
 local f=io.open(path,"r")
 if f then
  local data=f:read("*a")
  f:close()
  return data
 end
end
local buffer=require("string.buffer")
local BufferCache={
 hashes={}, ---@type table<string,string>
 paths={}, ---@type table<string,string>
 encode=buffer.encode,
 decode=buffer.decode,
 path=vim.fs.joinpath(vim.fn.stdpath("cache"),"buffercache"),
 enabled=true,
}
function BufferCache.setup()
 vim.fn.mkdir(BufferCache.path,"p",tonumber("700",8))
end
function BufferCache.turn(bool)
 BufferCache.enabled=bool
end
---@alias BufferHash uv.fs_stat.result
---@alias BufferCacheEntry {hash:BufferHash,data:string}
---@param name string
---@return string
function BufferCache.get_path(name)
 local ret=BufferCache.paths[name]
 if ret==nil then
  ret=vim.fs.joinpath(BufferCache.path,vim.uri_encode(name,"rfc2396"))
  BufferCache.paths[name]=ret
 end
 return ret
end
---@generic T
---@param expr fun():T
---@return T
function BufferCache.load(name,path,expr)
 if BufferCache.enabled==false then
  return expr()
 end
 return BufferCache.loadfile(name,path,expr)
end
---@generic T
---@param expr fun():T
---@return T
function BufferCache.loadfile(name,path,expr)
 if path==nil then
  path=debug.getinfo(expr).source:sub(2)
 end
 local stat=uv.fs_stat(path)
 if not stat then
  return expr()
 end
 if name==nil then
  local info=debug.getinfo(expr)
  name=info.source..info.currentline
 end
 local hash=BufferCache.read(BufferCache.get_path(name)..".hash")
 if type(hash)=="table" and uv_stat_eq(hash,stat) then
  return BufferCache.read(BufferCache.get_path(name)..".data")
 end
 local ret=expr()
 BufferCache.write(name,{
  hash=stat,
  data=ret,
 })
 return ret
end
function BufferCache.require(modname)
 local info=vim.loader.find(modname)[1]
 if info then
  return BufferCache.load("module-"..info.modname,info.modpath,function()
   return require(info.modname)
  end)
 end
end
---@param name string
---@param entry BufferCacheEntry
---@private
function BufferCache.write(name,entry)
 local path=BufferCache.get_path(name)
 writefile(path..".hash",BufferCache.encode(entry.hash))
 writefile(path..".data",BufferCache.encode(entry.data))
end
function BufferCache.read(path)
 local content=readfile(path)
 if content then
  return BufferCache.decode(content)
 end
end
return BufferCache

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
local function tbl_check(t,k,e)
 local r=t[k]
 if r==nil then
  r=e()
  t[k]=r
 end
 return r
end
local buffer=require("string.buffer")
local BufferCache={
 hashes={}, ---@type table<string,string>
 paths={}, ---@type table<string,string>
 encode=buffer.encode,
 decode=buffer.decode,
 path=vim.fs.joinpath(vim.fn.stdpath("cache"),"luabin"),
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
---@param path string
---@return uv.fs_stat.result|false
function BufferCache.get_hash(path)
 return tbl_check(BufferCache.hashes,path,function()
  return uv.fs_stat(path) or false
 end)
end
---@param name string
---@return string
function BufferCache.get_path(name)
 return tbl_check(BufferCache.paths,name,function()
  return vim.fs.joinpath(
   BufferCache.path,
   vim.uri_encode(name,"rfc2396")
  )
 end)
end
---@generic T
---@param expr fun():T
---@return T
function BufferCache.load(name,path,expr)
 if BufferCache.enabled==false then
  return expr()
 end
 local ret
 if path==nil then
  path=debug.getinfo(expr).source:sub(2)
 end
 local stat=uv.fs_stat(path)
 if stat then
  if name==nil then
   local info=debug.getinfo(expr)
   name=info.source..info.currentline
  end
  local hash=BufferCache.readhash(name)
  if hash~=nil and uv_stat_eq(hash,stat) then
   local data=BufferCache.readdata(name)
   if data~=nil then
    ret=data
   end
  else
   ret=expr()
   BufferCache.write(name,{
    hash=stat,
    data=ret,
   })
  end
 else
  ret=expr()
 end
 return ret
end
function BufferCache.loadmod(modname)
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
---@param name string module name or filename
function BufferCache.readhash(name)
 local path=BufferCache.get_path(name)..".hash"
 local content=readfile(path)
 if content then
  return BufferCache.decode(content) --[[@as uv.fs_stat.result]]
 end
end
---@param name string module name or filename
function BufferCache.readdata(name)
 local path=BufferCache.get_path(name)..".data"
 local content=readfile(path)
 if content then
  return BufferCache.decode(content)
 end
end
return BufferCache

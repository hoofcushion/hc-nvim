---BufferCache - A high-performance caching system for Neovim Lua modules and functions
---
---## PRINCIPLE:
---Uses LuaJIT's string.buffer for efficient serialization of Lua data structures,
---bypassing bytecode compilation and VM execution stages to accelerate data reading.
---Note this is way more faster than loading a lua script.
---
---Traditional Lua module loading:
---1. Read source file from disk
---2. Parse and compile to bytecode
---3. Execute bytecode in VM
---4. Return module table
---
---BufferCache acceleration:
---1. Check cache validity (based on file changed time)
---2. Read pre-serialized data from disk
---3. Directly decode using string.buffer
---4. Return cached result (no compilation/execution)
---
---## IMPORTANT LIMITATIONS:
---- Only supports basic data types: string, boolean, number, and tables
---- Only compatible with LuaJIT (uses string.buffer module)
---
---## Features:
---- Disk-based persistent caching
---- Automatic cache invalidation based on file mtime
---- Zero-configuration setup
---- Performance profiling mode
---- Support for both function results and module requires
---
---## Environment Variables:
---- `BC_NOCACHE=1` - Disable caching entirely
---- `BC_PROFILER=1` - Enable performance profiling
---
---## Usage:
---- `BufferCache.get(fn)` - Cache function results (basic types only)
---- `BufferCache.require(modname)` - Cache module loading (basic types only)
---- `BufferCache.print_stats()` - Show profiling results
---

local Util=require("hc-nvim.util.init_space")
local BufferCache={}
---@boolean # Whether caching is enabled (set via BC_NOCACHE environment variable)
BufferCache.enabled=vim.env.BC_NOCACHE==nil
---@boolean # Whether performance profiling is enabled (set via BC_PROFILER environment variable)
BufferCache.profiler=vim.env.BC_PROFILER~=nil
---@table # Storage for performance profiling records
BufferCache.records={
 _={name="_",cache=0,source=0},
}
local stringbuffer=require("string.buffer")
---@string # Directory where cache files are stored
local cache_dir=vim.fn.stdpath("cache").."/buffercache/"
-- Ensure cache directory exists
vim.fn.mkdir(cache_dir,"p")
local bit32=require("bit")
---@param data string
---@return string
local function fnv1a32(data)
 local hash=0x811c9dc5
 for i=1,#data do
  hash=bit32.bxor(hash,string.byte(data,i))
  hash=hash*0x01000193
 end
 return string.format("%08x",hash)
end
local function write(filename,value)
 local cache_file=cache_dir..fnv1a32(filename)..".bin"
 local encoded=stringbuffer.encode(value)
 local fd=vim.uv.fs_open(cache_file,"w",438)
 if fd then
  vim.uv.fs_write(fd,encoded,0)
  vim.uv.fs_close(fd)
 end
end
local function read(filename)
 local cache_file=cache_dir..fnv1a32(filename)..".bin"
 local source_stat=vim.uv.fs_stat(filename)
 local cache_stat=vim.uv.fs_stat(cache_file)
 if cache_stat and source_stat and cache_stat.mtime.sec>source_stat.mtime.sec then
  local fd=vim.uv.fs_open(cache_file,"r",438)
  if fd then
   local encoded=vim.uv.fs_read(fd,cache_stat.size,0)
   vim.uv.fs_close(fd)
   if encoded then
    return stringbuffer.decode(encoded)
   end
  end
 end
end
---Internal function to handle cached execution with automatic invalidation
---@param filename string The source file path to use as cache key
---@param fn function The function to execute and cache
---@return any The result of the function (either from cache or fresh execution)
local function get_cached(filename,fn)
 if not BufferCache.enabled then
  return fn()
 end
 local result
 local cache_start=vim.uv.hrtime()
 result=Util.try(function() return read(filename) end,Util.ERROR)
 local cache_end=vim.uv.hrtime()
 if result and not BufferCache.profiler then
  return result
 end
 local source_start=vim.uv.hrtime()
 result=Util.try(fn,Util.ERROR)
 local source_end=vim.uv.hrtime()
 write(filename,result)
 if BufferCache.profiler then
  local record={
   name=filename,
   cache=(cache_end-cache_start)/1e9,
   source=(source_end-source_start)/1e9,
  }
  table.insert(BufferCache.records,record)
 end
 return result
end

---Cache the result of a function based on its source file location
---@param fn function The function to cache
---@return any The cached or freshly computed result
function BufferCache.get(fn)
 if not BufferCache.enabled then
  return fn()
 end
 local fninfo=debug.getinfo(fn,"S")
 if not fninfo or not fninfo.source or fninfo.source:sub(1,1)~="@" then
  return fn()
 end
 local source_file=fninfo.source:sub(2)
 return get_cached(source_file,fn)
end
---Cache module loading using Neovim's built-in module loader
---@param modname string The module name to require and cache
---@return any The cached or freshly loaded module
function BufferCache.require(modname)
 if not BufferCache.enabled then
  return require(modname)
 end
 local found=vim.loader.find(modname)[1]
 if not found then
  return require(modname)
 end
 local modpath=found.modpath
 return get_cached(modpath,function() return Util.path_require(modname,modpath) end)
end
-- 使用 Sheet.print 打印性能分析数据
function BufferCache.print_stats()
 local records=BufferCache.records
 if not BufferCache.profiler or #records==0 then
  print("No profiler data available")
  return
 end
 -- 准备表格数据
 local table_data={}
 -- 添加表头
 local headers={"Filename","Cache(ms)","Source(ms)","Saved(ms)","Cached"}
 -- 添加数据行
 for _,record in ipairs(records) do
  if record.name~="_" then
   table.insert(table_data,{
    vim.fn.fnamemodify(record.name,":t"),
    string.format("%.3f",record.cache*1000),
    string.format("%.3f",record.source*1000),
    string.format("%.3f",(record.source-record.cache)*1000),
   })
  end
 end
 -- 添加总计行
 local total_cache=0
 local total_source=0
 for _,record in ipairs(records) do
  if record.name~="_" then
   total_cache=total_cache+record.cache
   total_source=total_source+record.source
  end
 end
 local total_saved=total_source-total_cache
 table.insert(table_data,{
  "TOTAL",
  string.format("%.3f",total_cache*1000),
  string.format("%.3f",total_source*1000),
  string.format("%.3f",total_saved*1000),
 })
 -- 添加效率行
 table.insert(table_data,{
  "Efficiency",
  "",
  "",
  string.format("%.1f%%",(total_source/total_cache)*100),
  "",
 })
 Util.Sheet.print(table_data,{
  headers=headers,
  alignments={"left","right","right","right","center"},
  style="single",
 })
end
return BufferCache

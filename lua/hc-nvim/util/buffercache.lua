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

local BufferCache={}
---@boolean # Whether caching is enabled (set via BC_NOCACHE environment variable)
BufferCache.enabled=vim.env.BC_NOCACHE==nil
---@boolean # Whether performance profiling is enabled (set via BC_PROFILER environment variable)
BufferCache.profiler=vim.env.BC_PROFILER~=nil
---@table # Storage for performance profiling records
BufferCache.records={
 _={name="_",cache=0,source=0},
}
---@string # Directory where cache files are stored
local cache_dir=vim.fn.stdpath("cache").."/buffercache/"
-- Ensure cache directory exists
vim.fn.mkdir(cache_dir,"p")
---Check if value contains only basic LuaJIT-compatible types
---@param value any
---@return boolean
local function is_basic_type(value)
 local t=type(value)
 -- Basic primitive types
 if t=="string" or t=="number" or t=="boolean" or t=="nil" then
  return true
 end
 -- Simple tables (only contain basic types)
 if t=="table" then
  for k,v in pairs(value) do
   if not is_basic_type(k) or not is_basic_type(v) then
    return false
   end
  end
  return true
 end
 -- Unsupported types: function, userdata, thread
 return false
end

---Internal function to handle cached execution with automatic invalidation
---@param filename string The source file path to use as cache key
---@param fn function The function to execute and cache
---@return any The result of the function (either from cache or fresh execution)
local function get_cached(filename,fn)
 if not BufferCache.enabled then
  return fn()
 end
 local cache_file=cache_dir..vim.fn.sha256(filename)..".bin"
 local source_stat=vim.uv.fs_stat(filename)
 local cache_stat=vim.uv.fs_stat(cache_file)
 local result
 local cache_start=vim.uv.hrtime()
 if cache_stat and source_stat and cache_stat.mtime.sec>source_stat.mtime.sec then
  local fd=vim.uv.fs_open(cache_file,"r",438)
  if fd then
   local encoded=vim.uv.fs_read(fd,cache_stat.size,0)
   vim.uv.fs_close(fd)
   if encoded then
    result=require("string.buffer").decode(encoded)
    if not BufferCache.profiler and is_basic_type(result) then
     return result
    end
   end
  end
 end
 local cache_end=vim.uv.hrtime()
 local source_start=vim.uv.hrtime()
 result=fn()
 local source_end=vim.uv.hrtime()
 -- Only cache basic types (LuaJIT compatible)
 if is_basic_type(result) then
  local encoded=require("string.buffer").encode(result)
  local fd=vim.uv.fs_open(cache_file,"w",438)
  if fd then
   vim.uv.fs_write(fd,encoded,0)
   vim.uv.fs_close(fd)
  end
 end
 if BufferCache.profiler then
  local record={
   name=filename,
   cache=(cache_end-cache_start)/1e9,
   source=(source_end-source_start)/1e9,
   cached=is_basic_type(result),
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
 return get_cached(modpath,function() return require(modname) end)
end
---Print performance profiling statistics when profiling is enabled
---Shows cache hit rates, time savings, and efficiency metrics
function BufferCache.print_stats()
 local records=BufferCache.records
 if not BufferCache.profiler or #records==0 then
  print("No profiler data available")
  return
 end
 local total_cache=0
 local total_source=0
 local total_saved=0
 local cached_count=0
 print("BufferCache Profiler Results:")
 print("="..string.rep("=",80))
 print(string.format("%-15s %12s %12s %12s %8s","Filename","Cache(ms)","Source(ms)","Saved(ms)","Cached"))
 print(string.rep("-",96))
 for _,record in ipairs(records) do
  if record.name~="_" then
   local cache_ms=record.cache*1000
   local source_ms=record.source*1000
   local saved_ms=source_ms-cache_ms
   total_cache=total_cache+cache_ms
   total_source=total_source+source_ms
   total_saved=total_saved+saved_ms
   if record.cached then cached_count=cached_count+1 end
   print(string.format("%-15s %12.3f %12.3f %12.3f %8s",
                       vim.fn.fnamemodify(record.name,":t"),
                       cache_ms,
                       source_ms,
                       saved_ms,
                       record.cached and "✓" or "✗"
   ))
  end
 end
 print(string.rep("-",96))
 print(string.format("%-15s %12.3f %12.3f %12.3f %8d/%d",
                     "TOTAL",total_cache,total_source,total_saved,cached_count,#records-1))
 print(string.format("%-15s %12.1f%%",
                     "Efficiency",(total_saved/total_source)*100))
 print(string.format("%-15s %12.1f%%",
                     "Cacheable",(cached_count/(#records-1))*100))
end
return BufferCache

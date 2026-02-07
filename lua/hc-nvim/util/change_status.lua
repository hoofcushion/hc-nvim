local Util=require("hc-nvim.util.init_space")
---@class ChangeStatus
---@field cache table<string, table> 存储 {sec, nsec} 的表
---@field cache_file string
local ChangeStatus={}
ChangeStatus.__index=ChangeStatus
function ChangeStatus.new(name)
 local new=setmetatable({},ChangeStatus)
 local dir=vim.fn.stdpath("cache").."/changestatus"
 if vim.fn.isdirectory(dir)==0 then
  vim.fn.mkdir(dir,"p")
 end
 new.cache_file=dir.."/"..(name or "default")..".lua"
 new.cache={}
 local ok,data=pcall(dofile,new.cache_file)
 if ok and type(data)=="table" then
  -- 转换旧格式（如果是整数格式的话）
  for k,v in pairs(data) do
   if type(v)=="number" then
    -- 旧格式：整数，需要转换为表格式
    new.cache[k]={
     sec=math.floor(v/1e9),
     nsec=v%1e9,
    }
   elseif type(v)=="table" and v.sec and v.nsec then
    -- 新格式：直接使用
    new.cache[k]=v
   end
  end
 end
 return new
end
---获取时间戳
---@param file string
---@return table? timestamp {sec: integer, nsec: integer}
local function get_timestamp(file)
 local stat=vim.uv.fs_stat(file)
 if not (stat~=nil and stat.mtime~=nil) then
  return nil
 end
 return {
  sec=stat.mtime.sec,
  nsec=stat.mtime.nsec,
 }
end

---比较两个时间戳
---@param t1 table {sec: integer, nsec: integer}
---@param t2 table {sec: integer, nsec: integer}
---@return boolean t1 > t2
local function timestamp_greater(t1,t2)
 if t1.sec>t2.sec then
  return true
 elseif t1.sec==t2.sec then
  return t1.nsec>t2.nsec
 end
 return false
end

---检查文件是否变更
---@param file string
---@return boolean
function ChangeStatus:is_changed(file)
 local current_ts=get_timestamp(file)
 -- 获取失败
 if not current_ts then
  if not self.cache[file] then
   return false
  end
  -- 移除缓存
  self.cache[file]=nil
  self:save()
  return true
 end
 local cached_ts=self.cache[file]
 local changed=false
 if not cached_ts then
  changed=true
 else
  changed=timestamp_greater(current_ts,cached_ts)
 end
 if changed then
  self.cache[file]={sec=current_ts.sec,nsec=current_ts.nsec}
  self:save()
 end
 return changed
end
---保存缓存
function ChangeStatus:save()
 local content="return "..Util.serialize_simple(self.cache)
 vim.fn.writefile({content},self.cache_file)
end
return ChangeStatus

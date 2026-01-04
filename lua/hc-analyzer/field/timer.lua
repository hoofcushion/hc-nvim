TimerTrack={}
TimerTrack.record={}
TimerTrack.leak={}
local weekt=setmetatable({},{__mode="k"})
local function replace_self(real,fake,fn)
 return function(self,...)
  if self==fake then -- pass with t, is method call
   return fn(real,...)
  end
  return fn(self,...)
 end
end
function TimerTrack.setup_timer_gc()
 ---@class uv
 local uv=vim.uv
 local KEY={}
 ---@generic T
 ---@return T
 local function uv_timer_wrap(f)
  return function(t,...)
   if t[KEY] then
    return f(t[KEY],...)
   end
   return f(t,...)
  end
 end
 ---@generic T
 ---@return T
 local function new_timer_wrap(new_timer)
  if false then
   new_timer=uv.new_timer
  end
  return function()
   -- Track memory leak
   local info=debug.getinfo(2)
   local src=info.source..":"..info.currentline
   TimerTrack.record[src]=(TimerTrack.record[src] or 0)+1
   local to_close=false
   local timer=assert(new_timer())
   local hooks={
    close=function(f)
     return function(...)
      TimerTrack.record[src]=(TimerTrack.record[src] or 1)-1
      return f(...)
     end
    end,
    start=function(f)
     return function(self,timeout,_repeat,fn)
      return f(self,timeout,_repeat,function()
       local ok,msg=pcall(fn)
       if to_close and not timer:is_closing() then
        timer:close()
       end
       if not ok then
        error(msg)
       end
      end)
     end
    end,
   }
   local ud=newproxy(true)
   getmetatable(ud).__gc=function()
    TimerTrack.leak[src]=(TimerTrack.leak[src] or 0)+1
    to_close=true
    if not timer:is_active() and not timer:is_closing() then
     timer:close()
    end
   end
   local cached={}
   getmetatable(ud).__index=function(t,k)
    if cached[k] then
     return cached[k]
    end
    local v
    if k==KEY then
     v=timer
    else
     v=timer[k]
     local hook=hooks[k]
     if hook then
      v=hook(v)
     end
     if type(v)=="function" then
      v=replace_self(timer,t,v)
     end
    end
    cached[k]=v
    return v
   end
   weekt[ud]=true
   return ud
  end
 end
 uv.new_timer=new_timer_wrap(vim.uv.new_timer)
 uv.timer_start=uv_timer_wrap(vim.uv.timer_start)
 uv.timer_stop=uv_timer_wrap(vim.uv.timer_stop)
 uv.timer_again=uv_timer_wrap(vim.uv.timer_again)
 uv.timer_get_due_in=uv_timer_wrap(vim.uv.timer_get_due_in)
 uv.timer_get_repeat=uv_timer_wrap(vim.uv.timer_get_repeat)
 uv.timer_set_repeat=uv_timer_wrap(vim.uv.timer_set_repeat)
end
TimerTrack.snapshots={}
function TimerTrack.snapshot()
 table.insert(TimerTrack.snapshots,vim.deepcopy(TimerTrack.record))
 while #TimerTrack.snapshots>100 do
  table.remove(TimerTrack.snapshots,1)
 end
end
-- 每秒记录一个 snapshot 的 timer
TimerTrack.auto_snapshot_timer=nil
function TimerTrack.start_auto_snapshot(interval_ms)
 interval_ms=interval_ms or 1000 -- 默认 1 秒
 -- 如果已经有定时器在运行，先停止它
 if TimerTrack.auto_snapshot_timer then
  TimerTrack.stop_auto_snapshot()
 end
 TimerTrack.auto_snapshot_timer=vim.uv.new_timer()
 TimerTrack.auto_snapshot_timer:start(
  0,           -- 初始延迟
  interval_ms, -- 重复间隔
  vim.schedule_wrap(function()
   TimerTrack.snapshot()
   -- print("自动记录 snapshot #"..#TimerTrack.snapshots)
  end)
 )
end
function TimerTrack.stop_auto_snapshot()
 if TimerTrack.auto_snapshot_timer then
  TimerTrack.auto_snapshot_timer:stop()
  TimerTrack.auto_snapshot_timer:close()
  TimerTrack.auto_snapshot_timer=nil
 end
end
-- 对比从第 i 个到第 e 个 snapshot 的差异
function TimerTrack.diff_snapshots(start_idx,end_idx)
 start_idx=start_idx or 1
 end_idx=end_idx or #TimerTrack.snapshots
 if start_idx<0 then
  start_idx=end_idx+start_idx+1
 end
 start_idx=math.max(1,start_idx)
 if not TimerTrack.snapshots[start_idx] or not TimerTrack.snapshots[end_idx] then
  error("快照索引超出范围")
 end
 local start_snapshot=TimerTrack.snapshots[start_idx]
 local end_snapshot=TimerTrack.snapshots[end_idx]
 local diff={}
 -- 收集所有出现的源文件
 local all_sources={}
 for src in pairs(start_snapshot) do
  all_sources[src]=true
 end
 for src in pairs(end_snapshot) do
  all_sources[src]=true
 end
 -- 计算差异
 for src in pairs(all_sources) do
  local start_count=start_snapshot[src] or 0
  local end_count=end_snapshot[src] or 0
  local increase=end_count-start_count
  if increase>0 then
   diff[src]={
    start=start_count,
    finish=end_count,
    increase=increase,
   }
  end
 end
 return diff
end
-- 打印格式化的差异结果
function TimerTrack.print_diff(diff)
 if not diff or vim.tbl_isempty(diff) then
  print("没有检测到 timer 数量的增长")
  return
 end
 print(string.format("Timer 增长统计:"))
 print(string.format("%-60s %-10s %-10s %-10s","源文件","开始时","结束时","增长量"))
 print(string.rep("-",90))
 for src,data in pairs(diff) do
  print(string.format("%-60s %-10d %-10d %-10d",
   src:sub(-60), -- 只显示最后60个字符
   data.start,
   data.finish,
   data.increase))
 end
end
function TimerTrack.diff(i,e)
 TimerTrack.print_diff(TimerTrack.diff_snapshots(i,e))
end
TimerTrack.setup_timer_gc()
--- test
-- local timer=vim.uv.new_timer()
-- timer:start(1,0,function() end)
-- vim.uv.timer_stop(timer)
-- timer:close()
TimerTrack.start_auto_snapshot(5000)

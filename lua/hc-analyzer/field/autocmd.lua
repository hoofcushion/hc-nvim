-- 04时49分15秒 msg_show.lua_print   vim.api.nvim_get_autocmds({})[1] {
--   buflocal = false,
--   callback = <function 1>,
--   command = "",
--   event = "BufAdd",
--   group = 59,
--   group_name = "NeoTreeEvent_vim_buffer_added",
--   id = 320,
--   once = false,
--   pattern = "*"
-- }
local function schedule(opts)
 local fn=opts.fn
 local i=1
 local e=opts.e
 local callback=opts.callback
 local function step()
  if i<=e then
   i=i+1
   fn()
   vim.schedule(step)
   return
  end
  callback()
 end
 step()
end
vim.api.nvim_create_user_command(
 "Test",
 function()
  print("Before:",#vim.api.nvim_get_autocmds({}))
  vim.schedule(function()
   schedule({
    fn=vim.schedule_wrap(function() vim.cmd.edit() end),
    e=100,
    callback=function()
     print("After:",#vim.api.nvim_get_autocmds({}))
    end,
   })
  end)
 end
 ,{}
)
vim.api.nvim_create_user_command(
 "AnalyzeAutocmds",
 function()
  ---@return nil
  local function print_autocmd_stats()
   local autocmds = vim.api.nvim_get_autocmds({})
   local stats = {
    total = #autocmds,
    event_patterns = {},
    buflocal = {[true] = 0, [false] = 0},
    once = {[true] = 0, [false] = 0},
    group_stats = {},
    callback_details = {},  -- 改为存储详细回调信息
    command_stats = {has_command = 0, no_command = 0},
    buffer_specific = {},
    file_patterns = {},
   }

   for _, autocmd in ipairs(autocmds) do
    -- 事件模式统计
    local pattern = type(autocmd.pattern) == "table" and table.concat(autocmd.pattern, ",") or autocmd.pattern or "*"
    local key = autocmd.event .. "@" .. pattern
    stats.event_patterns[key] = (stats.event_patterns[key] or 0) + 1
    
    -- 基础属性统计
    stats.buflocal[autocmd.buflocal] = stats.buflocal[autocmd.buflocal] + 1
    stats.once[autocmd.once] = stats.once[autocmd.once] + 1
    
    -- 命令统计
    if autocmd.command and autocmd.command ~= "" then
     stats.command_stats.has_command = stats.command_stats.has_command + 1
    else
     stats.command_stats.no_command = stats.command_stats.no_command + 1
    end
    
    -- 分组统计
    if autocmd.group_name then
     stats.group_stats[autocmd.group_name] = (stats.group_stats[autocmd.group_name] or 0) + 1
    end
    
    -- 回调详细分析（路径+行号+函数名）
    if autocmd.callback then
     local info = debug.getinfo(autocmd.callback)
     local source = info.source:sub(2) -- 移除开头的@符号
     local func_name = info.name or "<anonymous>"
     local detail = string.format("%s:%d [%s]", source, info.linedefined, func_name)
     stats.callback_details[detail] = (stats.callback_details[detail] or 0) + 1
    end
    
    -- 缓冲区特定统计
    if autocmd.buffer then
     local ft = vim.bo[autocmd.buffer].filetype
     stats.buffer_specific[ft] = (stats.buffer_specific[ft] or 0) + 1
    end
    
    -- 文件模式分析
    if pattern ~= "*" then
     stats.file_patterns[pattern] = (stats.file_patterns[pattern] or 0) + 1
    end
   end

   local buffer = {}
   local function push(str) table.insert(buffer, str) end

   push("=== Autocmd Detailed Statistics ===")
   push(string.format("Total autocmds: %d", stats.total))
   
   push("\n[Event Patterns]")
   local sorted_events = {}
   for key, count in pairs(stats.event_patterns) do
    table.insert(sorted_events, {key = key, count = count})
   end
   table.sort(sorted_events, function(a, b) return a.count > b.count end)
   for _, item in ipairs(sorted_events) do
    push(string.format("  %-35s: %3d", item.key, item.count))
   end
   
   push("\n[Group Statistics]")
   local sorted_groups = {}
   for name, count in pairs(stats.group_stats) do
    table.insert(sorted_groups, {name = name, count = count})
   end
   table.sort(sorted_groups, function(a, b) return a.count > b.count end)
   for _, item in ipairs(sorted_groups) do
    push(string.format("  %-30s: %3d", item.name, item.count))
   end
   
   push("\n[Callback Details]")  -- 修改标题
   local sorted_callbacks = {}
   for detail, count in pairs(stats.callback_details) do
    table.insert(sorted_callbacks, {detail = detail, count = count})
   end
   table.sort(sorted_callbacks, function(a, b) return a.count > b.count end)
   for _, item in ipairs(sorted_callbacks) do
    push(string.format("  %-80s: %3d", item.detail, item.count))  -- 增加宽度以适应详细信息
   end
   
   push("\n[Buffer Specific]")
   for ft, count in pairs(stats.buffer_specific) do
    push(string.format("  %-30s: %3d", ft, count))
   end
   
   push("\n[File Patterns]")
   for pattern, count in pairs(stats.file_patterns) do
    push(string.format("  %-30s: %3d", pattern, count))
   end
   
   push("\n[Basic Attributes]")
   push(string.format("  Buflocal: true=%d, false=%d", stats.buflocal[true], stats.buflocal[false]))
   push(string.format("  Once: true=%d, false=%d", stats.once[true], stats.once[false]))
   push(string.format("  Commands: has_command=%d, no_command=%d",
                      stats.command_stats.has_command, stats.command_stats.no_command))
   
   print(table.concat(buffer, "\n"))
  end

  print_autocmd_stats()
 end,
 {}
)

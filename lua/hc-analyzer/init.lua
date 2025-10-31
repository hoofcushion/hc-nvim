local Util=require("hc-nvim.util")
---@class ResourceRecord
---@field autocmds integer
---@field commands integer
---@field keymaps integer
---@field namespaces integer
---@field timestamp? integer

---@class ResourceMonitor
local M={}
local records={} ---@type ResourceRecord[]
---@param opts? {max_records?:integer, interval?:integer}
function M.setup(opts)
 opts=opts or {}
 local max_records=opts.max_records or 100
 local interval=opts.interval or 5000 -- 5秒
 -- 安全获取运行时数据
 ---@return ResourceRecord
 local function collect_stats()
  local stats={
   autocmds=0,
   commands=0,
   keymaps=0,
   namespaces=0,
   timestamp=os.time(),
  }
  pcall(function()
   stats.autocmds=#vim.api.nvim_get_autocmds({})
   stats.commands=Util.count(vim.api.nvim_get_commands({}))
   stats.keymaps=#vim.api.nvim_get_keymap("n") -- 修正模式参数
   stats.namespaces=Util.count(vim.api.nvim_get_namespaces())
  end)
  return stats
 end

 -- 启动定时器
 local timer=vim.uv.new_timer()
 if not timer then
  vim.notify("Failed to create timer",vim.log.levels.ERROR)
  return
 end
 timer:start(0,interval,vim.schedule_wrap(function()
  local stats=collect_stats()
  table.insert(records,stats)
  -- 环形缓冲区管理
  while #records>max_records do
   table.remove(records,1)
  end
 end))
 for modname,modpath in Util.iter_mod({"hc-analyzer.field"}) do
  Util.path_require(modname,modpath)
 end
end
--- 获取统计数据
---@param opts? {last_n?:integer}
---@return ResourceRecord[]
function M.get_stats(opts)
 opts=opts or {}
 local last_n=opts.last_n or #records
 return vim.list_slice(records,math.max(1,#records-last_n+1),#records)
end
--- 生成统计报告
---@return string
function M.report()
 if #records==0 then return "No data collected" end
 local latest=records[#records]
 local diff=#records>1 and {
  autocmds=latest.autocmds-records[1].autocmds,
  commands=latest.commands-records[1].commands,
  keymaps=latest.keymaps-records[1].keymaps,
  namespaces=latest.namespaces-records[1].namespaces,
 } or nil
 local lines={
  "=== Resource Usage Report ===",
  string.format("Current: autocmds=%d, commands=%d, keymaps=%d, namespaces=%d",
                latest.autocmds,latest.commands,latest.keymaps,latest.namespaces),
 }
 if diff then
  table.insert(
   lines,
   string.format("Change: autocmds=%+d, commands=%+d, keymaps=%+d, namespaces=%+d",
                 diff.autocmds,diff.commands,diff.keymaps,diff.namespaces)
  )
 end
 return table.concat(lines,"\n")
end
return M

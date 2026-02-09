local HCNvim=require("hc-nvim.init_space")
local function get_ft(path)
 return vim.filetype.match({filename=path})
end
local function get_params(path)
 return {
  textDocument={
   uri=vim.uri_from_fname(path),
   text=HCNvim.Util.work_readfile(path),
  },
 }
end
local function get_client_filetypes(client)
 local _,filetypes=pcall(function() return client.config.filetypes end)
 if type(filetypes)~="table" then
  filetypes={}
 end
 return filetypes
end
---@class DiagnosticWorkspace
local DiagnosticWorkspace={}
--- 主函数：格式化工作区
---@param opts? {
--- quiet?:boolean; -- 是否禁用 log 打印
--- level?:integer|fun():integer; -- 设置 log 过滤等级
--- callback?:fun(ok:boolean,...:any); -- 格式化完毕后执行的 callback
---}
function DiagnosticWorkspace.diagnostic_workspace(opts)
 opts=opts or {}
 local log=opts.quiet==nil or (not opts.quiet)
 local level=opts.level
 local trace=log and HCNvim.Util.Trace.new(level) or HCNvim.Util.Trace.Ignore
 opts.callback=(opts.callback or function(ok,...)
  if not ok then
   trace:error("error",...)
   trace:write_summary()
  end
 end)
 local function block()
  local cached_get_ft=HCNvim.Util.Cache.create(get_ft)
  local cached_get_params=HCNvim.Util.Cache.create(get_params)
  local clients=vim.lsp.get_clients()
  local files=HCNvim.Util.get_ws_git_files()
  for _,client in ipairs(clients) do
   local filetypes=get_client_filetypes(client)
   local filetype_set=HCNvim.Util.tbl_to_set(filetypes)
   for _,file in ipairs(files) do
    HCNvim.Util.await_schedule()
    local filetype=cached_get_ft(file)
    if filetype_set[filetype] then
     local method="textDocument/didOpen"
     local params=cached_get_params(file)
     client:notify(method,params)
    end
   end
  end
 end
 HCNvim.Util.async(function()
  opts.callback(pcall(block))
 end)
end
; (LUAFILEDO or type)(not LUAFILE or function()
 DiagnosticWorkspace.diagnostic_workspace({})
end)
return DiagnosticWorkspace

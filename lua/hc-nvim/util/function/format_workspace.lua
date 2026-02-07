local HCNvim=require("hc-nvim.init_space")
---@class FormatWorkspace
local FormatWorkspace={}
---@param path? string 指定路径
---@param trace? any Trace对象
---@return string[]
local function get_ws_git_files(path,trace)
 local files=HCNvim.Util.get_ws_git_files(path)
 if files then
  trace:debug("git_files_found",string.format("%d git files",#files))
 end
 return files or {}
end
---@param path? string 指定路径
---@param trace? any Trace对象
---@return string[]
local function get_ws_files(path,trace)
 local files=HCNvim.Util.get_ws_files(path)
 if files then
  trace:debug("ws_files_found",string.format("%d workspace files",#files))
 end
 return files or {}
end
---@param client any
---@param files string[]
---@param trace any
---@return string[]
local function filter_by_client_filetypes(client,files,trace)
 local filetype_set={}
 local ok,client_filetypes=pcall(function()
  return client.config.filetypes
 end)
 if ok and client_filetypes then
  for _,ft in ipairs(client_filetypes) do
   filetype_set[ft]=true
  end
 end
 local filtered={}
 for _,path in ipairs(files) do
  local filetype=vim.filetype.match({filename=path})
  if filetype_set[filetype] then
   table.insert(filtered,path)
  end
 end
 if #filtered<#files then
  trace:debug("client_filtered",string.format("Filtered by filetypes: %d -> %d files",#files,#filtered))
 end
 return filtered
end
---@param files string[]
---@param trace any
---@return string[]
---@return integer
local function filter_by_changed_files(files,trace)
 local change_status=HCNvim.Util.ChangeStatus.new("format_workspace")
 local changed={}
 for _,path in ipairs(files) do
  local ok,is_changed=pcall(change_status.is_changed,change_status,path)
  if ok and is_changed then
   table.insert(changed,path)
  end
 end
 if #changed<#files then
  trace:debug("changed_filtered",string.format("Filtered by changed: %d > %d",#files,#changed))
 end
 return changed,#files-#changed
end
---@return any[]
local function get_clients()
 return vim.lsp.get_clients({method="textDocument/formatting"})
end
---@async
---@param clients any[]
---@return any?
local function select_lsp_client(clients)
 return HCNvim.Util.await(function(resume)
  vim.ui.select(clients,{
   prompt="Select LSP client:",
   format_item=function(item)
    return string.format("%s (%s)",item.name,item.id)
   end,
  },resume)
 end)
end
---@return integer
local function get_current_tabstop()
 local shiftwidth=vim.bo.shiftwidth
 return (shiftwidth==0 and vim.bo.tabstop) or shiftwidth
end
---@param path string
---@return any
local function get_formatting_params(path)
 local options={
  tabSize=get_current_tabstop(),
  insertSpaces=vim.bo.expandtab,
 }
 return {
  textDocument={
   uri=vim.uri_from_fname(path),
  },
  options=options,
 }
end
---@param client any
---@param path string
---@param trace any
---@return string?
local function client_format_file(client,path,trace)
 local function job(resume)
  client:request("textDocument/formatting",get_formatting_params(path),function(_,result)
   local ok,ret=pcall(function()
    return result[1].newText
   end)
   resume(ok and ret or nil)
  end)
 end
 local timeouted_job=HCNvim.Util.async_timeout(job,10000)
 local ok,result=HCNvim.Util.await(timeouted_job)
 if not ok then
  trace:warn("format_timeout",string.format("Timeout: %s",path))
  return nil
 end
 local original=HCNvim.Util.work_readfile(path)
 if not original then
  trace:warn("read_failed",string.format("Can't read original: %s",path))
  return
 end
 if original:sub(-1,-1)=="\n" then
  original=original:sub(1,-2)
 end
 if original~=result then
  return result
 end
end
local needupdate=true
local buffer_name_table={}
---@return table<string, integer>
local function update_buffer_name_table()
 buffer_name_table={}
 local buffers=vim.api.nvim_list_bufs()
 for _,buf in ipairs(buffers) do
  local name=vim.api.nvim_buf_get_name(buf)
  buffer_name_table[name]=buf
 end
 needupdate=false
 return buffer_name_table
end
---@return table<string, integer>
local function get_buffer_name_table()
 return needupdate and update_buffer_name_table() or buffer_name_table
end
vim.api.nvim_create_autocmd({"BufNew","BufDelete"},{
 group=vim.api.nvim_create_augroup("buffer_name_table_updater",{clear=true}),
 callback=function()
  needupdate=true
 end,
})
---@param filename string
---@return integer?
local function buf_exists(filename)
 return get_buffer_name_table()[filename]
end
---@param filename string
---@return integer
local function buf_new(filename)
 local buf=vim.api.nvim_create_buf(false,true)
 vim.api.nvim_buf_set_name(buf,filename)
 return buf
end
---@param filename string
---@param content string
---@param trace any
---@return boolean
---@return string?
local function buf_write_file(filename,content,trace)
 local ok,err=pcall(function()
  local existing_buf=buf_exists(filename)
  local buf=existing_buf or buf_new(filename)
  local lines=vim.split(content,"\n")
  vim.api.nvim_buf_set_lines(buf,0,-1,false,lines)
  vim.api.nvim_buf_call(buf,function()
   vim.cmd("noautocmd silent write")
  end)
  if not existing_buf then
   vim.api.nvim_buf_delete(buf,{force=true})
  end
 end)
 if not ok then
  trace:warn("buf_write_file_failed",string.format("%s: %s",filename,err))
  return false,err
 end
 return true
end
---@class Progress
local Progress={}
Progress.__index=Progress
---@param status fun(): integer, integer
---@param write fun(index: integer, total: integer)
function Progress.new(status,write)
 ---@class Progress
 local obj=setmetatable({},Progress)
 obj.status=status
 obj.write=write
 obj.index=-1
 obj.timer=nil
 return obj
end
function Progress:start()
 if not self.timer then
  self.timer=vim.uv.new_timer()
 end
 if self.timer then
  self.timer:start(0,1000,function()
   self:update()
  end)
 end
end
function Progress:update()
 local i,e=self.status()
 if i>self.index then
  self.index=i
  self.write(i,e)
 end
end
function Progress:close()
 if self.timer then
  self.timer:close()
  self.timer=nil
 end
end
---@param client any
---@param files string[]
---@param trace any
---@param progress? boolean
---@return table[]
local function client_format_files(client,files,trace,progress)
 local index,total=0,#files
 local progress_obj
 if progress then
  progress_obj=Progress.new(
   function() return index,total end,
   function(i,e)
    local percentage=e>0 and math.floor(i/e*100) or 0
    trace:info("format_progress",string.format("Format progress: %d/%d (%d%%)",i,e,percentage))
   end
  )
  progress_obj:start()
 end
 local formatted_files={}
 for i,path in ipairs(files) do
  HCNvim.Util.await_schedule(nil)
  local formatted=client_format_file(client,path,trace)
  if formatted then
   table.insert(formatted_files,{path=path,content=formatted})
  end
  index=i
 end
 if progress_obj then
  progress_obj:update()
  progress_obj:close()
 end
 if #formatted_files>0 then
  trace:debug("formatted_files",string.format("Formatted: %d",#formatted_files))
 end
 return formatted_files
end

---@param results table[]
---@param trace any
---@param progress? boolean
---@return integer
---@return integer
local function write_format_results(results,trace,progress)
 local index,total=0,#results
 local progress_obj
 if progress then
  progress_obj=Progress.new(
   function() return index,total end,
   function(i,e)
    local percentage=e>0 and math.floor(i/e*100) or 0
    trace:info("write_progress",string.format("Write progress: %d/%d (%d%%)",i,e,percentage))
   end
  )
  progress_obj:start()
 end
 local success_count=0
 for i,result in ipairs(results) do
  HCNvim.Util.await_schedule()
  local success=buf_write_file(result.path,result.content,trace)
  if success then
   success_count=success_count+1
  end
  index=i
 end
 if progress_obj then
  progress_obj:update()
  progress_obj:close()
 end
 return success_count,#results-success_count
end
if false then
 ---@class show_format_summary.summary
 local summary={
  success=0,
  failed=0,
  total=0,
  formatted=0,
  unchanged=0,
 }
end
---@param summary show_format_summary.summary
---@param trace any
local function show_format_summary(summary,trace)
 local success=summary.success or 0
 local failed=summary.failed or 0
 local total=summary.total or 0
 local unchanged=summary.unchanged or 0
 local formatted=summary.formatted or 0
 local buffer={}
 table.insert(buffer,"=== Format Summary ===")
 table.insert(buffer,string.format("Total files: %d",total))
 table.insert(buffer,string.format("Formatted: %d",formatted))
 table.insert(buffer,string.format("Written: %d",success))
 table.insert(buffer,string.format("Failed: %d",failed))
 table.insert(buffer,string.format("Skipped: %d",unchanged))
 local msg
 if success>0 then
  msg=string.format("Done: %d/%d files formatted",success,total)
  if unchanged>0 then
   msg=msg..string.format(" (%d skipped)",unchanged)
  end
 else
  if formatted>0 then
   msg=string.format("Failed: %d/%d files unwritable",failed,formatted)
  else
   msg="No formatting needed"
  end
 end
 table.insert(buffer,msg)
 table.insert(buffer,"======================")
 local level=success>0 and vim.log.levels.INFO or vim.log.levels.WARN
 trace:record(level,"complete",table.concat(buffer,"\n"))
end
--- 主函数：格式化工作区
---@param opts? {
--- path?:string; -- 要格式化的目录路径
--- git?:boolean; -- 是否要使用 git 过滤
--- quiet?:boolean; -- 是否禁用 log 打印
--- level?:integer|fun():integer; -- 设置 log 过滤等级
--- callback?:fun(ok:boolean,...:any); -- 格式化完毕后执行的 callback
--- progress?:boolean; -- 是否显示进度
--- dry?:boolean; -- 是否避免写入任何文件
---}
function FormatWorkspace.format_workspace(opts)
 opts=opts or {}
 local log=opts.quiet==nil or (not opts.quiet)
 local level=opts.level
 local trace=log and HCNvim.Util.Trace.new(level) or HCNvim.Util.Trace.Ignore
 local progress=opts.progress==nil or (not not opts.progress)
 local dry=not not opts.dry
 opts.callback=(opts.callback or function(ok,...)
  if not ok then
   trace:error("error",...)
   trace:write_summary()
  end
 end)
 local function job()
  local clients=get_clients()
  if #clients==0 then
   trace:info("no_clients","No LSP clients found")
   return nil
  end
  local client=select_lsp_client(clients)
  if not client then
   trace:info("no_selection","No client selected")
   return
  end
  local use_git=(opts.git==nil or opts.git)
  local get_files=(use_git and get_ws_git_files or get_ws_files)
  local all_files=get_files(opts.path,trace)
  if #all_files==0 then
   trace:info("no_files","No files found")
   return
  end
  local type_filtered=filter_by_client_filetypes(client,all_files,trace)
  if #type_filtered==0 then
   trace:info("no_matching","No matching filetypes")
   return
  end
  local changed_files,unchanged_count=filter_by_changed_files(type_filtered,trace)
  if #changed_files==0 then
   trace:info("no_changes","No files to format")
   return
  end
  local formatted_files=client_format_files(client,changed_files,trace,progress)
  if #formatted_files==0 then
   trace:info("no_changes","No files formatted")
   return
  end
  local write=dry and function() return #formatted_files,0 end or write_format_results
  local success_count,failed_count=write(formatted_files,trace,progress)
  if success_count==0 then
   trace:info("no_changes","No files writed")
   return
  end
  show_format_summary({
   success=success_count,
   failed=failed_count,
   total=#type_filtered,
   formatted=#formatted_files,
   unchanged=unchanged_count,
  },trace)
 end
 HCNvim.Util.async(function()
  opts.callback(pcall(job))
 end)
end
; (LUAFILEDO or type)(not LUAFILE or function()
 FormatWorkspace.format_workspace({
  dry=true,
  level=-math.huge,
  -- quiet=true,
 })
end)
return FormatWorkspace

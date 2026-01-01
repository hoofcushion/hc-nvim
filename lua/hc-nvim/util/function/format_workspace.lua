local Util=require("hc-nvim.util")
-- 定义错误集合
local e_format_workspace={
 no_lsp_client=function()
  return {
   msg=debug.traceback("No LSP clients found",2),
   level=vim.log.levels.WARN,
  }
 end,
 no_lsp_client_selected=function()
  return {
   msg=debug.traceback("No LSP client selected",2),
   level=vim.log.levels.WARN,
  }
 end,
 cant_read_file=function(file)
  return {
   msg=debug.traceback("Can't read file: "..file,2),
   level=vim.log.levels.WARN,
  }
 end,
 file_is_opened=function(file)
  return {
   msg=debug.traceback("File is loaded in another buffer: "..file,2),
   level=vim.log.levels.WARN,
  }
 end,
}
local function try(fn)
 xpcall(fn,function(e)
  -- 统一的错误处理
  if type(e)=="table" and e.msg and e.level then
   vim.notify(e.msg,e.level)
  else
   vim.notify(tostring(e),vim.log.levels.ERROR)
  end
 end)
end
-- 获取已加载缓冲区名称
local function get_names()
 local names={}
 local bufs=vim.api.nvim_list_bufs()
 for _,v in ipairs(bufs) do
  if vim.api.nvim_buf_is_loaded(v) then
   local name=vim.api.nvim_buf_get_name(v)
   names[name]=true
  end
 end
 return names
end
-- 创建新缓冲区
local function tmp_buf()
 local buf=vim.api.nvim_create_buf(false,false)
 local bo=vim.bo[buf]
 bo.buflisted=false
 bo.bufhidden="hide"
 bo.swapfile=false
 return buf
end
-- 格式化单个文件
local function format_file(client,file)
 local names=get_names()
 if names[file] then
  return
 end
 local buf=tmp_buf()
 assert(vim.lsp.buf_attach_client(buf,client.id),"attach client failed")
 vim.api.nvim_buf_call(buf,function()
  vim.api.nvim_buf_set_name(buf,file)
  vim.cmd("edit")
  vim.cmd("syntax off")
  vim.bo[buf].filetype=""
  vim.lsp.buf.format({
   id=client.id,
   bufnr=buf,
   name=client.name,
   async=false,
   timeout_ms=3000,
  })
  vim.cmd("write")
 end)
 vim.defer_fn(function()
  vim.api.nvim_buf_delete(buf,{force=true})
 end,6000)
end
local function new_schedule(jobs,ps)
 local total=#jobs
 local current=0
 local timer=assert(vim.uv.new_timer())
 local process
 local process_scheduled
 function process()
  if current+1>total then
   return
  end
  current=current+1
  jobs[current]()
  timer:start(1000/ps,0,process_scheduled)
 end
 process_scheduled=vim.schedule_wrap(process)
 return {
  start=process_scheduled,
  stop=function()
   timer:stop()
  end,
 }
end
-- 主函数：格式化工作区
local function format_workspace()
 Util.async(function()
  try(function()
   -- 获取支持格式化的LSP客户端
   local clients=vim.lsp.get_clients({
    method="textDocument/formatting",
   })
   assert(#clients>0,e_format_workspace.no_lsp_client())
   -- 选择LSP客户端
   local client=Util.await(function(resume)
    vim.ui.select(clients,{
     prompt="Select LSP client:",
     format_item=function(item)
      return string.format("%s (%s)",item.name,item.id)
     end,
    },resume)
   end)
   assert(client,e_format_workspace.no_lsp_client_selected())
   -- 获取客户端支持的文件类型
   local filetype_set={}
   do
    local ok,filetypes=pcall(function()
     return assert(client.config.filetypes)
    end)
    if ok then
     for _,filetype in ipairs(filetypes) do
      filetype_set[filetype]=true
     end
    end
   end
   local jobs={}
   do
    -- 获取工作区中的git文件
    local files=Util.get_ws_git_files()
    -- 格式化文件
    for _,file in ipairs(files) do
     local filetype=vim.filetype.match({filename=file})
     if filetype_set[filetype] then
      table.insert(jobs,function()
       format_file(client,file)
      end)
     end
    end
   end
   local schedule=new_schedule(jobs,10)
   local cmd="StopFormat"
   vim.api.nvim_create_user_command(cmd,function()
    vim.api.nvim_del_user_command(cmd)
    schedule.stop()
   end,{})
   schedule.start()
  end)
 end)
end
-- 导出
format_workspace()
return format_workspace

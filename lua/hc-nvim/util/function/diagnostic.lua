local Util=require("hc-nvim.util")
local function get_params(path)
 local filetype=vim.filetype.match({filename=path})
 return {
  textDocument={
   uri=vim.uri_from_fname(path),
   version=0,
   text=table.concat(vim.fn.readfile(path),"\n"),
   languageId=filetype,
  },
 }
end
local function new_schedule()
 local tasks={}
 tasks.fns={}
 function tasks.add(fn)
  table.insert(tasks.fns,fn)
 end
 tasks.s=0
 tasks.e=0
 local function run0(step)
  for _=1,step do
   local fn=table.remove(tasks.fns)
   if not fn then
    break
   end
   pcall(fn)
  end
  if tasks.fns[1]==nil then
   tasks.e=vim.uv.hrtime()
   tasks.on_close()
   return
  end
  run0(step)
 end
 run0=vim.schedule_wrap(run0)
 function tasks.on_close() end
 function tasks.run(step)
  tasks.s=vim.uv.hrtime()
  run0(step)
 end
 return tasks
end
local function disgnostic_workspace()
 local clients=vim.lsp.get_clients()
 local files=Util.get_ws_files()
 local client_files={}
 for _,client in ipairs(clients) do
  local cfiles={}
  client_files[client]=cfiles
  local filetypes=client.config.filetypes or {}
  for _,path in ipairs(files) do
   local filetype=vim.filetype.match({filename=path})
   if filetype and vim.tbl_contains(filetypes,filetype) then
    table.insert(cfiles,path)
   end
  end
 end
 local schedule=new_schedule()
 local cached_get_params=Util.Cache.create(get_params)
 for client,cfiles in pairs(client_files) do
  for _,file in ipairs(cfiles) do
   schedule.add(function()
    client:notify("textDocument/didOpen",cached_get_params(file))
   end)
  end
 end
 vim.schedule(function()
  schedule.on_close=function()
   print(string.format("Done: %.3fs",(schedule.e-schedule.s)/1e9))
  end
  schedule.run(math.max(1,#schedule.fns/100))
 end)
end
return disgnostic_workspace

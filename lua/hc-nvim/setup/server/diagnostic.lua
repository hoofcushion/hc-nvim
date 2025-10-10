local Util=require("hc-nvim.util")
local function get_ws_folders()
 local workspace_folders=vim.lsp.buf.list_workspace_folders()
 workspace_folders=Util.list_unique(workspace_folders)
 return workspace_folders
end
local function get_opened_files()
 local opened={}
 for _,buf in ipairs(vim.api.nvim_list_bufs()) do
  local buf_file=vim.api.nvim_buf_get_name(buf)
  if buf_file and vim.fn.bufloaded(buf) and vim.fn.buflisted(buf) then
   opened[buf_file]=true
  end
 end
 return opened
end
local function get_ws_files()
 local workspace_folders=get_ws_folders()
 local opened=get_opened_files()
 local files={}
 for _,folder in ipairs(workspace_folders) do
  Util.scan(folder,function(_,type,path)
   if type=="file" and not opened[path] then
    table.insert(files,path)
   end
  end)
 end
 files=Util.list_unique(files)
 return files
end
local function disgnostic_workspace()
 local clients=vim.lsp.get_clients()
 local files=get_ws_files()
 local records={}
 for _,client in pairs(clients) do
  local filetypes=client.config.filetypes
  if filetypes then
   for _,path in ipairs(files) do
    local filetype=vim.filetype.match({filename=path})
    if filetype and vim.tbl_contains(filetypes,filetype) then
     table.insert(records,{client=client,path=path})
     vim.schedule(function()
      client:notify("textDocument/didOpen",{
       textDocument={
        uri=vim.uri_from_fname(path),
        version=0,
        text=vim.fn.join(vim.fn.readfile(path),"\n"),
        languageId=filetype,
       },
      })
     end)
    end
   end
  end
 end
end

return disgnostic_workspace

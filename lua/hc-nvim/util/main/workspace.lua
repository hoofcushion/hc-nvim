---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
function Util.get_ws_folders()
 local workspace_folders=vim.lsp.buf.list_workspace_folders()
 workspace_folders=Util.list_unique(workspace_folders)
 return workspace_folders
end
function Util.get_opened_files()
 local opened={}
 for _,buf in ipairs(vim.api.nvim_list_bufs()) do
  local bufname=vim.api.nvim_buf_get_name(buf)
  if bufname and vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) then
   opened[bufname]=true
  end
 end
 return opened
end
function Util.get_ws_files()
 local workspace_folders=Util.get_ws_folders()
 local opened=Util.get_opened_files()
 local seen={}
 local files={}
 for _,folder in ipairs(workspace_folders) do
  Util.scan(folder,function(_,type,path)
   if type=="file" and not opened[path] then
    if not seen[path] then
     seen[path]=true
     table.insert(files,path)
    end
   end
  end)
 end
 return files
end
function Util.get_git_files(git_root)
 if git_root==nil then
  git_root=vim.fs.root(vim.fn.getcwd(0),".git")
 end
 local result=vim.system(
  {"git","ls-files","--cached","--others","--exclude-standard"},
  {cwd=git_root}
 ):wait()
 if result.code==0 then
  local files=vim.split(result.stdout,"\n",{plain=true})
  for i,v in ipairs(files) do
   files[i]=vim.fs.joinpath(git_root,v)
  end
  return files
 end
 return {}
end
function Util.get_ws_git_files()
 local workspace_folders=Util.get_ws_folders()
 local seen={}
 local files={}
 for _,folder in ipairs(workspace_folders) do
  local git_root=vim.fs.root(folder,".git")
  if git_root then
   local git_files=Util.get_git_files(git_root)
   for _,file in ipairs(git_files) do
    if not seen[file] then
     seen[file]=true
     table.insert(files,file)
    end
   end
  end
 end
 return files
end

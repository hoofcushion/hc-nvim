---@class HC-Nvim.Util
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
function Util.get_ws_files(base_dir)
 local workspace_folders
 if base_dir then
  workspace_folders={base_dir}
 else
  workspace_folders=Util.get_ws_folders()
 end
 local opened=Util.get_opened_files()
 local seen={}
 local files={}
 for _,folder in ipairs(workspace_folders) do
  -- 使用 list_files 获取所有文件，然后过滤
  local all_files=Util.list_files(folder)
  for _,file in ipairs(all_files) do
   if not opened[file] and not seen[file] then
    seen[file]=true
    table.insert(files,file)
   end
  end
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
function Util.get_ws_git_files(base_dir)
 local workspace_folders
 if base_dir then
  workspace_folders={base_dir}
 else
  workspace_folders=Util.get_ws_folders()
 end
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

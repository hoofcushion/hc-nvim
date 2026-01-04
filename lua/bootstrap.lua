local luv=vim.uv
local function check_path(path)
 return luv.fs_stat(path)~=nil
end
local function check_dir(path)
 if not check_path(path) then
  vim.fn.mkdir(path,"p")
 end
end
local datapath=vim.fn.stdpath("data")
check_dir(datapath)
local lazypath=vim.fs.joinpath(datapath,"lazy")
check_dir(lazypath)
local bootstrappath=vim.fs.joinpath(lazypath,"bootstrap.lua")
if not check_path(bootstrappath) then
 local output=vim.fn.system({
  "curl",
  "-o",
  bootstrappath,
  "https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua",
 })
 if vim.v.shell_error~=0 then
  error(output)
 end
end
loadfile(bootstrappath)()
---@return boolean
local function is_same_file(filename1,filename2)
 local f1=luv.fs_stat(filename1)
 local f2=luv.fs_stat(filename2)
 return f1~=nil and f2~=nil and f1.size==f2.size and f1.type==f2.type and vim.deep_equal(f1.atime,f2.atime)
end

--- Auto update bootstrap.lua
vim.api.nvim_create_autocmd("User",{
 pattern="LazyUpdate",
 callback=function()
  local new_bootstrappath=vim.fs.joinpath(lazypath,"lazy.nvim","bootstrap.lua")
  if is_same_file(new_bootstrappath,bootstrappath) then
   return
  end
  vim.fn.delete(bootstrappath)
  vim.fn.filecopy(new_bootstrappath,bootstrappath)
 end,
})

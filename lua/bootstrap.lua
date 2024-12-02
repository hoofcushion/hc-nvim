local luv=vim.uv
local function checkpath(path)
 return luv.fs_stat(path)~=nil
end
local function checkdir(path)
 if not checkpath(path) then
  vim.fn.system({"mkdir",path})
 end
end
local datapath=vim.fn.stdpath("data") --[[@as string]]
checkdir(datapath)
local lazypath=vim.fs.joinpath(datapath,"lazy") --[[@as string]]
checkdir(lazypath)
local bootstrappath=vim.fs.joinpath(lazypath,"bootstrap.lua") --[[@as string]]
checkdir(bootstrappath)
if not checkpath(bootstrappath) then
 local output=vim.fn.system({
  "curl",
  "-o",bootstrappath,
  "https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua",
 })
 if vim.v.shell_error ~= 0 then
  error(output)
 end
end

loadfile(bootstrappath)()
---@return boolean
local function is_samefile(filename1,filename2)
 local f1=luv.fs_stat(filename1)
 local f2=luv.fs_stat(filename2)
 return f1~=nil and f2~=nil
  and f1.size==f2.size
  and f1.type==f2.type
  and vim.deep_equal(f1.atime,f2.atime)
end

--- Auto update bootstrap.lua
vim.api.nvim_create_autocmd("User",{
 pattern="LazyUpdate",
 callback=function()
  local new_bootstrappath=vim.fs.joinpath(lazypath,"lazy.nvim","bootstrap.lua")
  if is_samefile(new_bootstrappath,bootstrappath) then
   return
  end
  luv.fs_unlink(bootstrappath)
  luv.fs_copyfile(new_bootstrappath,bootstrappath)
 end,
})

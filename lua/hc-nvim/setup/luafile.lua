local Luafile={}
local ignored_jobs={}
local env={
 LUAFILE=true,
 LUAFILEDO=function(fn)
  local cursor_pos=vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())
  local info=debug.getinfo(2)
  local line=info.currentline
  if cursor_pos[1]==line then
   vim.schedule(function()
    for _,v in ipairs(ignored_jobs) do
     print("pass LUAFILEDO at "..v.currentline)
    end
    fn()
   end)
  else
   table.insert(ignored_jobs,info)
  end
 end,
}
function Luafile.luafile(path)
 if false then LUAFILE=true end
 path=path or vim.fn.expand("%")
 ignored_jobs={}
 local fn=assert(loadfile(path))
 setfenv(fn,setmetatable(env,{__index=_G}))
 fn()
end
function Luafile.setup()
 if LUAFILE==nil then
  LUAFILE=false
  LUAFILEDO=function(fn) end
 end
end
return Luafile

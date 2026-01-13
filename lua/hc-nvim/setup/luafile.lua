local Luafile={}
local env={
 LUAFILE=true,
 LUAFILEDO=function(fn) fn() end,
}
function Luafile.luafile(path)
 if false then LUAFILE=true end
 path=path or vim.fn.expand("%")
 local fn=assert(loadfile(path))
 setfenv(fn,setmetatable(env,{__index=_G}))
 fn()
end
function Luafile.setup()
 if LUAFILE==nil then
  LUAFILE=false
  LUAFILEDO=function() end
 end
end
return Luafile

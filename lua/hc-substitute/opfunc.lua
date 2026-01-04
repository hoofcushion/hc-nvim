local M=require("hc-substitute.init_space")
--- ---
--- OpFunc imp.
--- ---
local OpFunc={}
function OpFunc.set(opfunc,args)
 if args~=nil then
  local _=opfunc
  opfunc=function(vmode)
   _(vmode,unpack(args))
  end
 end
 _G.opfunc=opfunc
 vim.o.opfunc=[[v:lua.opfunc]]
end
--- Set opfunc then start operator mode with a initial motion
function OpFunc.start(opfunc,motion,...)
 OpFunc.set(opfunc,{...})
 M.Util.feedkeys("g@"..(motion or ""),"n")
end
return OpFunc

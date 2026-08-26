local HCSubstitute=require("hc-substitute.init_space")
--- ---
--- OpFunc imp.
--- ---
local OpFunc={}
function OpFunc.set(opfunc,args)
 local opfunc_with_args=function()
  opfunc(unpack(args))
 end
 vim.o.opfunc=opfunc_with_args
end
--- Set opfunc then start operator mode with a initial motion
function OpFunc.start(opfunc,motion,...)
 OpFunc.set(opfunc,{...})
 HCSubstitute.Util.feedkeys("g@"..(motion or ""),"n")
end
return OpFunc

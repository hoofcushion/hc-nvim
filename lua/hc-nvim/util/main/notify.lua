---@class HC-Nvim.Util
local Util=require("hc-nvim.util.init_space")
Util.levels={
 TRACE=function() return vim.log.levels.TRACE end,
 DEBUG=function() return vim.log.levels.DEBUG end,
 INFO=function() return vim.log.levels.INFO end,
 WARN=function() return vim.log.levels.WARN end,
 ERROR=function() return vim.log.levels.ERROR end,
 OFF=function() return vim.log.levels.OFF end,
}
function Util.TRACE(msg) vim.notify(msg,Util.levels.TRACE()) end
function Util.DEBUG(msg) vim.notify(msg,Util.levels.DEBUG()) end
function Util.INFO(msg) vim.notify(msg,Util.levels.INFO()) end
function Util.WARN(msg) vim.notify(msg,Util.levels.WARN()) end
function Util.ERROR(msg) vim.notify(msg,Util.levels.ERROR()) end
function Util.OFF(msg) vim.notify(msg,Util.levels.OFF()) end
---@generic P1, P2, P3, P4, P5, P6, P7, P8, P9, P10
---@param fn fun(P1:P1?, P2:P2?, P3:P3?, P4:P4?, P5:P5?, P6:P6?, P7:P7?, P8:P8?, P9:P9?, P10:P10?)
---@param catch function?
---@return P1, P2, P3, P4, P5, P6, P7, P8, P9, P10
function Util.try(fn,catch,...)
 local pack=Util.packlen(pcall(fn,...))
 if not pack[1] then
  return (catch or error)(pack[2])
 end
 return Util.unpacklen(pack,2)
end
Util.TryCall={
 ---@generic A,B,C,D,E,F,G,H,I,J
 ---@param fn (fun(...):A?,B?,C?,D?,E?,F?,G?,H?,I?,J?)
 ---@param ... any
 ---@return A,B,C,D,E,F,G,H,I,J
 TRACE=function(fn,...) return Util.try(fn,Util.TRACE,...) end,
 ---@generic A,B,C,D,E,F,G,H,I,J
 ---@param fn (fun(...):A?,B?,C?,D?,E?,F?,G?,H?,I?,J?)
 ---@param ... any
 ---@return A,B,C,D,E,F,G,H,I,J
 DEBUG=function(fn,...) return Util.try(fn,Util.DEBUG,...) end,
 ---@generic A,B,C,D,E,F,G,H,I,J
 ---@param fn (fun(...):A?,B?,C?,D?,E?,F?,G?,H?,I?,J?)
 ---@param ... any
 ---@return A,B,C,D,E,F,G,H,I,J
 INFO=function(fn,...) return Util.try(fn,Util.INFO,...) end,
 ---@generic A,B,C,D,E,F,G,H,I,J
 ---@param fn (fun(...):A?,B?,C?,D?,E?,F?,G?,H?,I?,J?)
 ---@param ... any
 ---@return A,B,C,D,E,F,G,H,I,J
 WARN=function(fn,...) return Util.try(fn,Util.WARN,...) end,
 ---@generic A,B,C,D,E,F,G,H,I,J
 ---@param fn (fun(...):A?,B?,C?,D?,E?,F?,G?,H?,I?,J?)
 ---@param ... any
 ---@return A,B,C,D,E,F,G,H,I,J
 ERROR=function(fn,...) return Util.try(fn,Util.ERROR,...) end,
 ---@generic A,B,C,D,E,F,G,H,I,J
 ---@param fn (fun(...):A?,B?,C?,D?,E?,F?,G?,H?,I?,J?)
 ---@param ... any
 ---@return A,B,C,D,E,F,G,H,I,J
 OFF=function(fn,...) return Util.try(fn,Util.OFF,...) end,
}
---@generic T:function
---@param fn T
---@return T
function Util.try_wrap(fn,catch)
 return function(...) return Util.try(fn,catch,...) end
end
Util.TryWrapper={
 ---@generic T:function
 ---@param fn T
 ---@return T
 TRACE=function(fn) return Util.try_wrap(fn,Util.TRACE) end,
 ---@generic T:function
 ---@param fn T
 ---@return T
 DEBUG=function(fn) return Util.try_wrap(fn,Util.DEBUG) end,
 ---@generic T:function
 ---@param fn T
 ---@return T
 INFO=function(fn) return Util.try_wrap(fn,Util.INFO) end,
 ---@generic T:function
 ---@param fn T
 ---@return T
 WARN=function(fn) return Util.try_wrap(fn,Util.WARN) end,
 ---@generic T:function
 ---@param fn T
 ---@return T
 ERROR=function(fn) return Util.try_wrap(fn,Util.ERROR) end,
 ---@generic T:function
 ---@param fn T
 ---@return T
 OFF=function(fn) return Util.try_wrap(fn,Util.OFF) end,
}

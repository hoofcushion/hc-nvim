---@class hc_nvim.util
local Util=require("hc-nvim.util.init_space")
function Util.TRACE(msg) vim.notify(msg,vim.log.levels.TRACE) end
function Util.DEBUG(msg) vim.notify(msg,vim.log.levels.DEBUG) end
function Util.INFO(msg) vim.notify(msg,vim.log.levels.INFO) end
function Util.WARN(msg) vim.notify(msg,vim.log.levels.WARN) end
function Util.ERROR(msg) vim.notify(msg,vim.log.levels.ERROR) end
function Util.OFF(msg) vim.notify(msg,vim.log.levels.OFF) end
---@param fn function
---@param catch function?
function Util.try(fn,catch)
 local pack=Util.packlen(pcall(fn))
 if not pack[1] then
  return (catch or error)(pack[2])
 end
 return Util.unpacklen(pack,2)
end

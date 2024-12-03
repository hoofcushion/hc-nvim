local Config=require("hc-nvim.config")
if Config.platform.is_vscode then
 return
end
if Config.server.auto_setup then
 vim.api.nvim_create_autocmd("BufEnter",{
  callback=function(ev)
   if ev.file=="" then
    return
   end
   local Util=require("hc-nvim.util")
   Util.track("server")
   local Handler=require("hc-nvim.setup.server.handler")
   local specs=Config.server.list
   for _,spec in ipairs(specs) do
    Handler.load(spec)
   end
   Util.track()
   return true
  end,
 })
end

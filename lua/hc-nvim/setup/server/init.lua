local Config=require("hc-nvim.config")
if Config.platform.is_vscode then
 return
end
if Config.server.auto_setup then
 vim.api.nvim_create_autocmd("BufReadPost",{
  once=true,
  callback=function()
   local Handler=require("hc-nvim.setup.server.handler")
   local specs=Config.server.list
   for _,spec in ipairs(specs) do
    Handler.load(spec)
   end
  end,
 })
end

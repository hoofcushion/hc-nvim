local Config=require("hc-nvim.config")
return {
 ensure_installed=(function()
  if not Config.server.ensure_installed then
   return nil
  end
  local ret={}
  for _,v in pairs(Config.server.list) do
   table.insert(ret,v.name)
  end
  return ret
 end)(),
 auto_update=Config.server.auto_update,
}

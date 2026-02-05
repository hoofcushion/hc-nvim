local HCNvim=require("hc-nvim.init_space")
local function has_client(name)
 return function()
  local client=vim.lsp.get_clients({name=name})[1]
  return client~=nil
 end
end
local function toggle_hint()
 local client=vim.lsp.get_clients({name="lua_ls"})[1]
 local enabled=HCNvim.Util.tbl_get(client,{"config","settings","Lua","hint","enable"})
 local target=not enabled
 HCNvim.Util.tbl_set(client,{"config","settings","Lua","hint","enable"},target)
 local buf=vim.api.nvim_get_current_buf()
 if vim.lsp.buf_is_attached(buf,client.id) then
  vim.lsp.buf_detach_client(buf,client.id)
  vim.lsp.buf_attach_client(buf,client.id)
 end
 if target==true then
  vim.defer_fn(function()
   vim.lsp.inlay_hint.enable(true)
  end,1000)
 end
end
return HCNvim.Util.parse_override({
 override={tags={"lua"},pattern="lua"},
 {lhs="<leader>luf",rhs=function() require("hc-nvim.setup.luafile").luafile() end,                desc="Execute current lua script in Neovim runtime"},
 {lhs="<leader>lun",cmd="!nvim -l %",                                                             desc="!nvim -l %"},
 {lhs="<leader>lua",cmd="!lua %",                                                                 desc="!lua %"},
 {lhs="<leader>luj",cmd="!luajit %",                                                              desc="!luajit %"},
 {lhs="<leader>lut",rhs=function() require("hc-nvim.util.function.switch_fundef").switch(0,0) end,desc="swap field to function"},
 {lhs="<leader>luo",rhs=function() require("hc-nvim.util.function.switch_oop").switch(0,0) end,   desc="swap method to dot"},
 {lhs="<leader>olL",rhs=toggle_hint,                                                              cond=has_client("lua_ls"),                         name=NS.lsp_lua_ls_toggle_hint},
})

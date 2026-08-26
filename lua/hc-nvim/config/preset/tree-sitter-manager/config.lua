return function(plugin,opts)
 local mod=require("tree-sitter-manager")
 local setup=(mod or {}).setup or function(_) end
 setup(opts)
 vim.api.nvim_create_user_command("TSManagerInstallAll",function()
  local _=require("tree-sitter-manager")
  local repos=require("tree-sitter-manager.repos")
  local installer=require("tree-sitter-manager.installer")
  for lang in pairs(repos) do
   installer.install(lang)
  end
 end,{})
 vim.api.nvim_create_user_command("TSManagerRemoveAll",function()
  local _=require("tree-sitter-manager")
  local repos=require("tree-sitter-manager.repos")
  local installer=require("tree-sitter-manager.installer")
  for lang in pairs(repos) do
   installer.remove(lang)
  end
 end,{})
 vim.api.nvim_create_user_command("TSManagerReinstalllAll",function()
  local _=require("tree-sitter-manager")
  local repos=require("tree-sitter-manager.repos")
  local installer=require("tree-sitter-manager.installer")
  for lang in pairs(repos) do
   installer.remove(lang)
  end
  for lang in pairs(repos) do
   installer.install(lang)
  end
 end,{})
end

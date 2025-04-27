local NULLLS_CONFIG_MODFORMAT="null-ls.builtins.%s.%s"
local NVIMDAP_CONFIG_MODFORMAT="mason-nvim-dap.mappings.%s"
local Util=require("hc-nvim.util")
local Presets={}
function Presets.lsp(name)
 local ret=vim.lsp.config[name]
 if ret~=nil then
  return ret
 end
end
local all_methods={"diagnostics","formatting","code_actions","completion","hover"}
---@param name string # e.g, formatting.stylua or stylua.
function Presets.null_ls(name)
 local methods={}
 if name:find(".",1,true) then
  local method
  method,name=name:match("^(.-)%.(.+)$")
  table.insert(methods,method)
 else
  methods=all_methods
 end
 local ret={}
 for _,method in ipairs(methods) do
  local builtin=Util.prequire(NULLLS_CONFIG_MODFORMAT:format(method,name))
  ret[method]=builtin
 end
 if next(ret)==nil then
  return
 end
 ret.filetypes={}
 for _,builtin in pairs(ret) do
  if builtin.filetypes~=nil then
   vim.list_extend(ret.filetypes,builtin.filetypes)
  end
 end
 return ret
end
function Presets.dap(name)
 local ret=Util.prequire(NVIMDAP_CONFIG_MODFORMAT:format(name))
 return ret
end
for k,v in pairs(Presets) do
 Presets[k]=Util.Cache.create(v)
end
local Clients=Util.Cache.table(function(name)
 return name=="lsp" and vim.lsp
  or name=="null_ls" and require("null-ls")
  or name=="dap" and require("dap")
end)
if false then
 Clients={
  lsp=vim.lsp,
  null_ls=require("null-ls"),
  dap=require("dap"),
 }
end
local SetupMaker={}
function SetupMaker.lsp(name)
 return function(config)
  if config then
   vim.lsp.config(name,config)
  end
  Clients.lsp.enable(name)
 end
end
--- setup server_configuration when filetype matches
---@param name string client name
---@return function
function SetupMaker.null_ls(name)
 return function(config)
  local opts=Presets.null_ls(name)
  if opts==nil then
   return
  end
  for method,builtin in Util.rpairs(opts,all_methods) do
   if config~=nil and config[method]~=nil then
    builtin=builtin.with(config[method])
   end
   Clients.null_ls.register(builtin)
  end
 end
end
function SetupMaker.dap(name)
 return function(config)
  local opts=Presets.dap(name)
  if opts==nil then
   return
  end
  if config then
   opts=Util.tbl_deep_extend({},opts,config)
  end
  if opts.adapters~=nil then
   Clients.dap.adapters[opts.name]=opts.adapters
  end
  if opts.configurations~=nil then
   local dap_cfgs=Clients.dap.configurations
   for _,filetype in ipairs(opts.filetypes) do
    Util.list_extend(Util.tbl_check(dap_cfgs,filetype),opts.configurations)
   end
  end
 end
end
local ConfigTab=Util.Cache.table(function(modname)
 local info=Util.find_mod(
  ("hc-nvim.user.server.%s"):format(modname),
  ("hc-nvim.builtin.server.%s"):format(modname)
 )
 if info then
  return require(info.modname)
 end
end)
local TypeTab=Util.Cache.table(function(name)
 return Presets.lsp(name) and "lsp" or Presets.null_ls(name) and "null_ls" or Presets.dap(name) and "dap" or nil
end)
local Handler={}
local setuped={}
function Handler.load(spec)
 local setup_name=spec.setup or spec.name
 if setuped[setup_name] then
  return
 end
 setuped[setup_name]=true
 local ls_type=TypeTab[setup_name]
 if ls_type then
  SetupMaker[ls_type](setup_name)(ConfigTab[spec.name])
 end
end
return Handler

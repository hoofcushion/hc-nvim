local Util=require("hc-nvim.util")
local Presets={}
function Presets.lsp(name)
 local ret=vim.lsp.config[name]
 if ret~=nil then
  return ret
 end
end
local all_methods={"diagnostics","formatting","code_actions","completion","hover"}
local builtin_map; builtin_map=Util.lazy(function()
 builtin_map=Util.create_modmap("null-ls.builtins")
 return builtin_map
end)

---@param method string
---@param name string
---@return table?
local function get_builtin(method,name)
 if not builtin_map[method] or not builtin_map[method][name] then
  return nil
 end
 local ok,builtin=pcall(function()
  return require(("null-ls.builtins.%s.%s"):format(method,name))
 end)
 return ok and builtin or nil
end
function Presets.null_ls(name)
 local methods
 local _method,_name=name:match("^(.-)%.(.+)$")
 if _method then
  methods={_method}
  name=_name
 else
  methods=all_methods
 end
 local ret={}
 for _,method in ipairs(methods) do
  local builtin=get_builtin(method,name)
  if builtin then
   ret[method]=builtin
  end
 end
 if next(ret)==nil then
  return nil
 end
 ret.filetypes={}
 for _,builtin in pairs(ret) do
  if builtin.filetypes then
   vim.list_extend(ret.filetypes,builtin.filetypes)
  end
 end
 return ret
end
local dap_config_names={"adapters","configurations","filetypes"}
local dap_map; dap_map=Util.lazy(function()
 dap_map=Util.create_modmap("mason-nvim-dap.mappings")
 return dap_map
end)
---@param config_name string
---@param name string
---@return table?
local function get_dap_config(config_name,name)
 if not dap_map[config_name] or not dap_map[config_name][name] then
  return nil
 end
 local ok,config=pcall(function()
  return require(("mason-nvim-dap.mappings.%s.%s"):format(config_name,name))
 end)
 return ok and config or nil
end
function Presets.dap(name)
 local ret={}
 for _,config_name in ipairs(dap_config_names) do
  local config=get_dap_config(config_name,name)
  if config then
   ret[config_name]=config
  end
 end
 if next(ret)==nil then
  return nil
 end
 ret.name=name
 ret.filetypes=ret.filetypes or {}
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
   Clients.lsp.config(name,config)
  end
  Clients.lsp.enable(name)
  config=Clients.lsp.config[name]
  if  not Clients.lsp.is_enabled(name)
  and vim.list_contains(config.filetypes,vim.bo.filetype)
  then
   Clients.lsp.start(config)
  end
 end
end
local setuped_null_ls=false
--- setup server_configuration when filetype matches
---@param name string client name
---@return function
function SetupMaker.null_ls(name)
 return function(config)
  local opts=Presets.null_ls(name)
  if opts==nil then
   return
  end
  if not setuped_null_ls then
   Clients.null_ls.setup()
   setuped_null_ls=true
  end
  for _,method in ipairs(all_methods) do
   local builtin=opts[method]
   if builtin~=nil then
    if config~=nil and config[method]~=nil then
     builtin=builtin.with(config[method])
    end
    Clients.null_ls.register(builtin)
   end
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
    dap_cfgs[filetype]=dap_cfgs[filetype] or {}
    Util.list_extend(dap_cfgs[filetype],opts.configurations)
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
---@type table<string,"lsp"|"null_ls"|"dap">
local TypeTab=Util.Cache.table(function(name)
 return Presets.lsp(name)~=nil and "lsp"
  or Presets.null_ls(name)~=nil and "null_ls"
  or Presets.dap(name)~=nil and "dap"
  or nil
end)
local Handler={}
local setuped={}
function Handler.load(spec)
 local main=spec.main or spec.name
 local name=spec.name
 if setuped[main] then
  return
 end
 setuped[main]=true
 local ls_type=TypeTab[main]
 if ls_type then
  local setup_maker=SetupMaker[ls_type]
  local config=ConfigTab[name]
  local setup=setup_maker(main)
  setup(config)
 end
end
return Handler

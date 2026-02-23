-- handler/dap.lua
local HCNvim=require("hc-nvim.init_space")
---@type server.handler
local M={}
local dap_config_names={"adapters","configurations","filetypes"}
local dap_map; dap_map=HCNvim.lazy(function()
 return HCNvim.Util.create_modmap("mason-nvim-dap.mappings")
end,function(t)
 dap_map=t
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

function M.get_preset(name)
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
function M.setup(name,config)
 local opts=M.get_preset(name)
 if opts==nil then
  return
 end
 if config then
  opts=HCNvim.Util.tbl_deep_extend({},opts,config)
 end
 if opts.adapters~=nil then
  require("dap").adapters[opts.name]=opts.adapters
 end
 if opts.configurations~=nil then
  local dap_cfgs=require("dap").configurations
  for _,filetype in ipairs(opts.filetypes) do
   dap_cfgs[filetype]=dap_cfgs[filetype] or {}
   HCNvim.Util.list_extend(dap_cfgs[filetype],opts.configurations)
  end
 end
end
return M

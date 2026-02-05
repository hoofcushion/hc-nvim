local HCNvim=require("hc-nvim.init_space")
---@type server.handler
local M={}
local all_methods={"diagnostics","formatting","code_actions","completion","hover"}
local function get_path(method,name)
 local files=vim.api.nvim_get_runtime_file(("lua/null-ls/builtins/%s/%s.lua"):format(method,name),false)
 local path=files[1]
 if path then
  return path
 end
end
; (LUAFILEDO or type)(not LUAFILE or function()
 print(HCNvim.Util.serialize(get_path("formatting","stylu")))  -- nil
 print(HCNvim.Util.serialize(get_path("formatting","stylua"))) -- path
 local name="codespell"
 for _,method in ipairs(all_methods) do
  local path=get_path(method,name)
  print(method,path)
  if path then
   local modname=("null-ls.builtins.%s.%s"):format(method,name)
   local mod=HCNvim.Util.path_require(modname,path)
   print(modname,name)
  end
 end
end)
---@param method string
---@param name string
---@return table?
local function get_builtin(method,name)
 local path=get_path(method,name)
 if path==nil then
  return nil
 end
 local modname=("null-ls.builtins.%s.%s"):format(method,name)
 local ok,builtin=pcall(function()
  return HCNvim.Util.path_require(modname,path)
 end)
 if ok then
  return builtin
 end
end

function M.get_preset(name)
 local methods
 local sep=string.find(name,".",1,true)
 if sep then
  methods={string.sub(name,1,sep-1)}
  name=string.sub(name,sep+1)
 else
  methods=all_methods
 end
 local ret={}
 for _,method in ipairs(methods) do
  local builtin=get_builtin(method,name)
  if builtin~=nil then
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
function M.setup(name,config)
 local opts=M.get_preset(name)
 if opts==nil then
  return
 end
 for _,method in ipairs(all_methods) do
  local builtin=opts[method]
  if builtin~=nil then
   if config~=nil and config[method]~=nil then
    builtin=builtin.with(config[method])
   end
   require("null-ls").register(builtin)
  end
 end
end
return M

local HCNvim=require("hc-nvim.init_space")
local function diagnostic_workspace()
 HCNvim.Util.async(function()
  local function get_ft(path)
   return vim.filetype.match({filename=path})
  end
  local cached_get_ft=HCNvim.Util.Cache.create(get_ft)
  local function get_params(path)
   local filetype=cached_get_ft(path)
   return {
    textDocument={
     uri=vim.uri_from_fname(path),
     version=0,
     text=HCNvim.Util.work_readfile(path),
     languageId=filetype,
    },
   }
  end
  local cached_get_params=HCNvim.Util.Cache.create(get_params)
  local clients=vim.lsp.get_clients()
  local files=HCNvim.Util.get_ws_files()
  for _,client in ipairs(clients) do
   local filetype_set=HCNvim.Util.tbl_to_set(client.config.filetypes or {})
   for _,file in ipairs(files) do
    HCNvim.Util.await_schedule()
    local filetype=cached_get_ft(file)
    if filetype and filetype_set[filetype] then
     client:notify("textDocument/didOpen",cached_get_params(file))
    end
   end
  end
 end)
end
return diagnostic_workspace

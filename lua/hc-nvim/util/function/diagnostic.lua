local Util=require("hc-nvim.util")
local function diagnostic_workspace()
 Util.async(function()
  local function get_ft(path)
   return vim.filetype.match({filename=path})
  end
  local cached_get_ft=Util.Cache.create(get_ft)
  local function get_params(path)
   local filetype=cached_get_ft(path)
   return {
    textDocument={
     uri=vim.uri_from_fname(path),
     version=0,
     text=Util.work_readfile(path),
     languageId=filetype,
    },
   }
  end
  local cached_get_params=Util.Cache.create(get_params)
  local clients=vim.lsp.get_clients()
  local files=Util.get_ws_files()
  for _,client in ipairs(clients) do
   local filetype_set=Util.tbl_to_set(client.config.filetypes or {})
   for _,file in ipairs(files) do
    Util.await_schedule()
    local filetype=cached_get_ft(file)
    if filetype and filetype_set[filetype] then
     client:notify("textDocument/didOpen",cached_get_params(file))
    end
   end
  end
 end)
end
return diagnostic_workspace

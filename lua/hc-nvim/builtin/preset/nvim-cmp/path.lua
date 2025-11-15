local cmp=require("cmp")
local name_regex='\\%([^/\\\\:\\*?<>\'"`\\|]\\)'
local path_regex=assert(vim.regex(([[\%(\%(/PAT*[^/\\\\:\\*?<>\'"`\\| .~]\)\|\%(/\.\.\)\)*/\zePAT*$]]):gsub("PAT",name_regex)))
local function async(func)
 local co=coroutine.create(func)
 coroutine.resume(co)
end

local function await(func)
 local co=coroutine.running()
 if not co then
  error()
 end
 local function resume(...)
  coroutine.resume(co,...)
 end
 func(resume)
 return coroutine.yield()
end
local function await_work(env,job)
 return await(function(resume)
  vim.uv.new_work(job,resume):queue(env)
 end)
end
local source={}
function source.new() return setmetatable({},{__index=source}) end
---@return string[]
function source:get_trigger_characters() return {"/","."} end
---@return string
function source:get_keyword_pattern() return name_regex.."*" end
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params,callback)
 local s=path_regex:match_str(params.context.cursor_before_line)
 if not s then
  return callback()
 end
 local dirname=string.gsub(string.sub(params.context.cursor_before_line,s+2),"%a*$","")
 local prefix=string.sub(params.context.cursor_before_line,1,s+1)
 local buf_dirname=vim.fn.fnamemodify(vim.api.nvim_buf_get_name(params.context.bufnr),":h")
 local resolved_dir
 if prefix:match("%.%/%./$") then
  resolved_dir=vim.fn.resolve(buf_dirname.."/../"..dirname)
 elseif prefix:match("%./$") or prefix:match('"$') or prefix:match("'$") then
  resolved_dir=vim.fn.resolve(buf_dirname.."/"..dirname)
 elseif prefix:match("~/$") then
  resolved_dir=vim.fn.resolve(vim.fn.expand("~").."/"..dirname)
 elseif prefix:match("/$") and not (prefix:match("%a/$") or prefix:match("%a+:/$") or prefix:match("%a+://$") or prefix:match("</$") or prefix:match("[%d%)]%s*/$")) then
  resolved_dir=vim.fn.resolve("/"..dirname)
 else
  return callback()
 end
 async(function()
  local files=await_work(resolved_dir,function(resolved_dir)
   local entries=vim.uv.fs_scandir(resolved_dir)
   if not entries then
    return
   end
   local files={}
   while true do
    local name,fs_type=vim.uv.fs_scandir_next(entries)
    if not name then break end
    table.insert(files,{name=name,fs_type=fs_type})
   end
   return vim.json.encode(files)
  end)
  if not files then
   return callback()
  end
  local ok,data=pcall(vim.json.decode,files)
  if not ok then
   return callback()
  end
  local items={}
  for _,file in ipairs(data) do
   local is_dir=file.fs_type=="directory"
   local path=resolved_dir.."/"..file.name
   table.insert(items,{
    data={path=path,type=file.fs_type},
    filterText=file.name,
    insertText=file.name..(is_dir and "/" or ""),
    kind=is_dir and cmp.lsp.CompletionItemKind.Folder or cmp.lsp.CompletionItemKind.File,
    label=file.name..(is_dir and "/" or ""),
   })
  end
  table.sort(items,function(a,b)
   return a.label>b.label
  end)
  callback(items)
 end)
end
local function get_documentation(filename,count)
 local binary=assert(io.open(filename,"rb"))
 local first_kb=binary:read(1024)
 if first_kb:find("\0") then
  return {kind=cmp.lsp.MarkupKind.PlainText,value="maybe binary file"}
 end
 local contents={}
 for content in first_kb:gmatch("[^\r\n]+") do
  table.insert(contents,content)
  if #contents>=count then
   break
  end
 end
 local filetype=vim.filetype.match({filename=filename}) or "txt"
 table.insert(contents,1,    "```"..filetype)
 table.insert(contents,"```")
 return {
  kind=cmp.lsp.MarkupKind.Markdown,
  value=table.concat(contents,"\n"),
 }
end
function source:resolve(item,callback)
 pcall(function()
  local data=item.data
  if data.path and data.type=="file" then
   item.documentation=get_documentation(data.path,20)
  end
 end)
 callback(item)
end
cmp.register_source("path",source.new())
return source

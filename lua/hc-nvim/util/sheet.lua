local Sheet={}
Sheet.chars={
 none={h=" ",v=" ",tl=" ",tr=" ",bl=" ",br=" ",t=" ",b=" ",l=" ",r=" ",c=" "},
 single={h="─",v="│",tl="┌",tr="┐",bl="└",br="┘",t="┬",b="┴",l="├",r="┤",c="┼"},
 double={h="═",v="║",tl="╔",tr="╗",bl="╚",br="╝",t="╦",b="╩",l="╠",r="╣",c="╬"},
 bold={h="━",v="┃",tl="┏",tr="┓",bl="┗",br="┛",t="┳",b="┻",l="┣",r="┫",c="╋"},
 rounded={h="─",v="│",tl="╭",tr="╮",bl="╰",br="╯",t="┬",b="┴",l="├",r="┤",c="┼"},
}
---@alias AlignmentFn fun(value:string,width:integer):string
---@type table<string,AlignmentFn>
local Alignments={
 ---@param value string
 ---@param width integer
 ---@return string
 left=function(value,width)
  return value..string.rep(" ",width-vim.fn.strdisplaywidth(value))
 end,
 ---@param value string
 ---@param width integer
 ---@return string
 right=function(value,width)
  return string.rep(" ",width-vim.fn.strdisplaywidth(value))..value
 end,
 ---@param value string
 ---@param width integer
 ---@return string
 center=function(value,width)
  local str_width=vim.fn.strdisplaywidth(value)
  local left_pad=math.floor((width-str_width)/2)
  local right_pad=width-str_width-left_pad
  return string.rep(" ",left_pad)..value..string.rep(" ",right_pad)
 end,
}
---@param tbl table
---@param opts? {headers?:string[],padding?:integer,style?:string,alignments?:string|string[]}
function Sheet.print(tbl,opts)
 opts=opts or {}
 local headers=opts.headers
 local padding=opts.padding or 1
 local style=opts.style or "single"
 local chars=Sheet.chars[style] or Sheet.chars.single
 local alignments=opts.alignments
 local is_matrix=type(tbl[1])=="table"
 local col_count=headers and #headers or (is_matrix and #tbl[1] or 1)
 local rows=is_matrix and tbl or {tbl}
 if #rows==0 then
  print("Table is empty")
  return
 end
 ---@type string[]
 local alignment_list={}
 if type(alignments)=="string" then
  for i=1,col_count do alignment_list[i]=alignments end
 elseif type(alignments)=="table" then
  alignment_list=alignments
 else
  for i=1,col_count do
   alignment_list[i]="left"
  end
 end
 local max_widths={}
 local width_cache={} -- 缓存字符串宽度
 local function get_width(str)
  if width_cache[str] then return width_cache[str] end
  local w=vim.fn.strdisplaywidth(str)
  width_cache[str]=w
  return w
 end
 for i=1,col_count do
  max_widths[i]=headers and headers[i] and get_width(headers[i]) or 0
 end
 for _,row in ipairs(rows) do
  for i=1,col_count do
   local cell=tostring(row[i] or "")
   max_widths[i]=math.max(max_widths[i],get_width(cell))
  end
 end
 local separator_parts={}
 for i=1,col_count do
  separator_parts[i]=string.rep(chars.h,max_widths[i]+padding*2)
 end
 local buffer={"Print table:"}
 ---@param left_char string
 ---@param cross_char string
 ---@param right_char string
 local function print_separator(left_char,cross_char,right_char)
  table.insert(buffer,left_char..table.concat(separator_parts,cross_char)..right_char)
 end
 ---@param values string[]
 local function print_row(values)
  local cells={}
  for i=1,col_count do
   local value=tostring(values[i] or "")
   local align=alignment_list[i]
   local align_func=Alignments[align] or Alignments.left
   local aligned_value=align_func(value,max_widths[i])
   cells[i]=string.rep(" ",padding)..aligned_value..string.rep(" ",padding)
  end
  table.insert(buffer,chars.v..table.concat(cells,chars.v)..chars.v)
 end
 print_separator(chars.tl,chars.t,chars.tr)
 if headers then
  print_row(headers)
  print_separator(chars.l,chars.c,chars.r)
 end
 for _,row in ipairs(rows) do print_row(row) end
 print_separator(chars.bl,chars.b,chars.br)
 print(table.concat(buffer,"\n"))
end
-- -- 示例用法
-- local data={
--  {"Alice",  25,"Engineer"},
--  {"Bob",    30,"Designer"},
--  {"Charlie",28,"Manager"},
-- }
-- -- 左对齐所有列（默认）
-- Sheet.print(data,{headers={"Name","Age","Job"}})
-- -- 指定对齐方式
-- Sheet.print(data,{
--  headers={"Name","Age","Job"},
--  alignments={"left","center","right"},
-- })
-- -- 不同样式和对齐组合
-- Sheet.print(data,{
--  headers={"Name","Age","Job"},
--  style="double",
--  alignments={"center","right","left"},
-- })
-- Sheet.print(data,{headers={"Name","Age","Job"},style="bold"})
-- Sheet.print(data,{headers={"Name","Age","Job"},style="rounded"})
return Sheet

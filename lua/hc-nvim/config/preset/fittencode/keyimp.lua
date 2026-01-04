local fittencode_api=require("fittencode.api").api
return {
 {name=NS.fittencode_accept_all_suggestions,rhs=fittencode_api.accept_all_suggestions},
 {name=NS.fittencode_accept_line,           rhs=fittencode_api.accept_line},
 {name=NS.fittencode_accept_word,           rhs=fittencode_api.accept_word},
 {name=NS.fittencode_revoke_word,           rhs=fittencode_api.revoke_line},
 {name=NS.fittencode_revoke_line,           rhs=fittencode_api.revoke_word},
 {
  name=NS.fittencode_api_panel,
  rhs=(function()
   local unused_api={
    accept_all_suggestions=true,
    accept_line=true,
    accept_word=true,
    accept_char=true,
    revoke_line=true,
    revoke_word=true,
    revoke_char=true,
    triggering_completion=true,
    dismiss_suggestions=true,
   }
   local interactive={
    login={
     prompt="Enter username and password",
     format=function(input)
      local ret=vim.split(input," ")
      if #ret~=2 then
       return false,"Invalid input format"
      end
      return true,ret
     end,
    },
    set_log_level={
     prompt="Enter log level (value in vim.log.levels)",
     format=function(input)
      local ret=tonumber(input)
      if vim.log.levels[ret]==nil then
       return false,"Invalid log level"
      end
      return true,{ret}
     end,
    },
   }
   local function notify(choice,output)
    vim.notify(
     ("%s: %s"):format(choice,output),
     vim.log.levels.INFO,
     {title="FittenCode"}
    )
   end
   local reverse={}
   local choices={}
   for _,choice in ipairs(vim.tbl_keys(fittencode_api)) do
    if unused_api[choice] then
     goto continue
    end
    local value=choice:gsub("_"," "):gsub("^%a",string.upper)
    table.insert(choices,value)
    reverse[value]=choice
    ::continue::
   end
   table.sort(choices)
   return function()
    local vmode={v=true,V=true,[""]=true}
    local mode=vim.fn.mode()
    local is_visual=vmode[mode]
    if is_visual then
     vim.api.nvim_feedkeys("","nx",false)
    end
    vim.ui.select(
     choices,
     {prompt="Select a command to run: "},
     function(choice)
      if choice==nil then return end
      if is_visual then
       vim.api.nvim_feedkeys("gv","nx",false)
      end
      local name=reverse[choice]
      local func=fittencode_api[name]
      if interactive[name]==nil then
       notify(choice,func({}))
      else
       local opts=interactive[name]
       vim.ui.input(
        {prompt=opts.prompt},
        function(input)
         if input==nil then
          return
         end
         local ok,res=opts.format(input)
         local output
         if ok then
          output=func(unpack(res))
         else
          output=res
         end
         notify(choice,output)
        end
       )
      end
      if is_visual then
       vim.api.nvim_feedkeys("","nx",false)
      end
     end
    )
   end
  end)(),
 },
}

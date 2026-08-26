local HCNvim=require("hc-nvim.init_space")
return {
 {
  {name=NS.global_buffer_delete,  cmd="bdelete"},
  {name=NS.global_buffer_wipeout, cmd="bwipeout"},
  {name=NS.global_buffer_next,    cmd="bnext"},
  {name=NS.global_buffer_previous,cmd="bprevious"},
  {
   name=NS.global_buffer_close_left,
   rhs=function()
    local current=vim.api.nvim_get_current_buf()
    vim.iter(vim.api.nvim_list_bufs())
     :filter(function(x) return vim.fn.buflisted(x)==1 end)
     :filter(function(x) return x<current end)
     :map(function(x) return vim.api.nvim_command("confirm bdelete "..x) end)
   end,
  },
  {
   name=NS.global_buffer_close_right,
   rhs=function()
    local current=vim.api.nvim_get_current_buf()
    vim.iter(vim.api.nvim_list_bufs())
     :filter(function(x) return vim.fn.buflisted(x)==1 end)
     :filter(function(x) return x>current end)
     :map(function(x) return vim.api.nvim_command("confirm bdelete "..x) end)
   end,
  },
  {
   name=NS.global_buffer_close_other,
   rhs=function()
    local current=vim.api.nvim_get_current_buf()
    vim.iter(vim.api.nvim_list_bufs())
     :filter(function(x) return vim.fn.buflisted(x)==1 end)
     :filter(function(x) return x~=current end)
     :map(function(x) return vim.api.nvim_command("confirm bdelete "..x) end)
   end,
  },
  {
   name=NS.global_buffer_selecte_delete,
   rhs=function()
    vim.ui.select(
     vim.iter(vim.api.nvim_list_bufs())
     :filter(function(x) return vim.fn.buflisted(x)==1 end)
     :totable(),
     {
      prompt="Select a buffer",
      format_item=function(x)
       return ("[%s]:%s"):format(x,vim.api.nvim_buf_get_name(x))
      end,
     },
     function(choice)
      if choice~=nil and vim.api.nvim_buf_is_valid(choice) then
       vim.api.nvim_command("confirm bdelete "..choice)
      end
     end
    )
   end,
  },
  {
   name=NS.global_buffer_selecte_goto,
   rhs=function()
    vim.ui.select(
     vim.iter(vim.api.nvim_list_bufs())
     :filter(function(x) return vim.fn.buflisted(x)==1 end)
     :totable(),
     {
      prompt="Select a buffer",
      format_item=function(x)
       return ("[%s]: %s"):format(x,vim.api.nvim_buf_get_name(x))
      end,
     },
     function(choice)
      if choice~=nil and vim.api.nvim_buf_is_valid(choice) then
       vim.api.nvim_set_current_buf(choice)
      end
     end
    )
   end,
  },
 },
 {
  {name=NS.global_tab_new,     cmd="tabnew"},
  {name=NS.global_tab_close,   cmd="tabclose"},
  {name=NS.global_tab_previous,cmd="tabprevious"},
  {name=NS.global_tab_first,   cmd="tabfirst"},
  {name=NS.global_tab_next,    cmd="tabnext"},
  {name=NS.global_tab_last,    cmd="tablast"},
 },
 {
  {name=NS.global_window_left, cmd="wincmd h"},
  {name=NS.global_window_down, cmd="wincmd j"},
  {name=NS.global_window_up,   cmd="wincmd k"},
  {name=NS.global_window_right,cmd="wincmd l"},
 },
 {
  {name=NS.global_option_wrap,          rhs=HCNvim.Util.Wrapper.toggle_option("wrap")},
  {name=NS.global_option_cursorline,    rhs=HCNvim.Util.Wrapper.toggle_option("cursorline")},
  {name=NS.global_option_cursorcolumn,  rhs=HCNvim.Util.Wrapper.toggle_option("cursorcolumn")},
  {name=NS.global_option_signcolum,     rhs=HCNvim.Util.Wrapper.toggle_option("signcolumn",{"yes","no"})},
  {name=NS.global_option_number,        rhs=HCNvim.Util.Wrapper.toggle_option("number")},
  {name=NS.global_option_relativenumber,rhs=HCNvim.Util.Wrapper.toggle_option("relativenumber")},
  {name=NS.global_option_foldenable,    rhs=HCNvim.Util.Wrapper.toggle_option("foldenable")},
  {name=NS.global_option_syntax,        rhs=HCNvim.Util.Wrapper.toggle_option("syntax",{"on","off"})},
  {
   name=NS.global_option_treesitter,
   rhs=function()
    local buf=vim.api.nvim_get_current_buf()
    if vim.treesitter.highlighter.active[buf] then
     vim.treesitter.stop(buf)
    else
     vim.treesitter.start(buf)
    end
   end,
  },
 },
 -- {
 --  {
 --   name=NS.global_paste_next_line,
 --   lhs="]p",
 --   rhs=function()
 --    if vim.fn.getregtype(vim.v.register)=="V" then
 --     return "p"
 --    end
 --    return "o<esc>P"
 --   end,
 --   opts={expr=true},
 --  },
 --  {
 --   name=NS.global_paste_prev_line,
 --   lhs="[p",
 --   rhs=function()
 --    if vim.fn.getregtype(vim.v.register)=="V" then
 --     return "P"
 --    end
 --    return "O<esc>p"
 --   end,
 --  },
 -- },
 {
  {
   name=NS.global_sketch_open,
   lhs="<leader>bs",
   rhs=function()
    local int=math.floor
    local buf=vim.api.nvim_create_buf(false,true)
    local columns=vim.o.columns
    local lines=vim.o.lines
    local size=(columns*lines)^0.5
    local width=int(size*0.8)
    local height=int(size/2*0.8)
    local win=vim.api.nvim_open_win(buf,true,{
     relative="editor",
     col=int(columns-width)/2,
     row=int(lines-height)/2,
     width=width,
     height=height,
     style="minimal",
     border="single",
     title="[sketch buffer]",
    })
    local wo=vim.wo[win]
    wo.number=false
    wo.relativenumber=false
    wo.signcolumn="no"
    wo.foldcolumn="0"
    local bo=vim.bo[buf]
    bo.bufhidden="wipe"
    for _,lhs in ipairs({"q","<esc>"}) do
     vim.api.nvim_buf_set_keymap(buf,"n",lhs,"<ignore>",{
      callback=function()
       vim.api.nvim_buf_delete(buf,{force=true})
      end,
     })
    end
   end,
  },
 },
 {
  {name=NS.global_cmd_nohlsearch, cmd="nohlsearch"},
  {name=NS.global_cmd_write,      cmd="write",     mode={"i","n","x","s"}},
  {name=NS.global_escape_terminal,rhs="<c-\\><c-n>"},
  {name=NS.global_delete_left,    rhs="<Del>"},
  {name=NS.global_normal_q,       rhs="q"},
  {name=NS.global_normal_Q,       rhs="Q"},
  {
   name=NS.global_change_c,
   lhs="c",
   rhs=function() return vim.v.count==0 and "c" or "s" end,
   opts={expr=true},
  },
  {name=NS.global_change_r,rhs="r"},
  {name=NS.global_change_R,rhs="R"},
 },
 {name=NS.global_edit_break_points,rhs=function(lhs) return lhs.."<c-g>u" end,opts={expr=true}},
 {name=NS.global_visual_indent,    rhs=function(lhs) return lhs.."gv" end,    opts={expr=true}},
 {name=NS.operator_entire_buffer,  rhs=":<c-u>normal! ggVG<cr>"},
 {
  name=NS.operator_straght_down,
  rhs=function()
   local current_line=vim.fn.line(".")
   local display_col=vim.fn.virtcol(".")
   local line_count=vim.api.nvim_buf_line_count(0)
   for line=current_line+1,line_count do
    local line_content=vim.api.nvim_buf_get_lines(0,line-1,line,false)[1]
    local line_len=vim.fn.strdisplaywidth(line_content)
    if line_len<display_col then
     local distance=line-current_line-1
     if distance>0 then
      return tostring(distance).."j"
     else
      break
     end
    end
   end
   return tostring(line_count-current_line).."j"
  end,
  opts={expr=true},
 },
 {
  name=NS.operator_straght_up,
  rhs=function()
   local current_line=vim.fn.line(".")
   local display_col=vim.fn.virtcol(".")
   for line=current_line-1,1,-1 do
    local line_content=vim.api.nvim_buf_get_lines(0,line-1,line,false)[1]
    local line_len=vim.fn.strdisplaywidth(line_content)
    if line_len<display_col then
     local distance=current_line-line-1
     if distance>0 then
      return tostring(distance).."k"
     else
      break
     end
    end
   end
   return tostring(current_line-1).."k"
  end,
  opts={expr=true},
 },
 {
  {name=NS.global_motion_ge,    rhs="ge"},
  {name=NS.global_motion_gE,    rhs="gE"},
  {name=NS.global_motion_b,     rhs="b"},
  {name=NS.global_motion_B,     rhs="B"},
  {name=NS.global_motion_e,     rhs="e"},
  {name=NS.global_motion_E,     rhs="E"},
  {name=NS.global_motion_w,     rhs="w"},
  {name=NS.global_motion_W,     rhs="W"},
  {name=NS.global_motion_0,     rhs=HCNvim.Util.KeyRecorder.loop_keys("0",{"0","^"}),  desc="Line start or non-blank start",opts={expr=true}},
  {name=NS.global_motion_doller,rhs=HCNvim.Util.KeyRecorder.loop_keys("$",{"$","g_"}), desc="Line end or non-blank end",    opts={expr=true}},
  {name=NS.global_motion_caret, rhs=HCNvim.Util.KeyRecorder.loop_keys("^",{"^","0"}),  desc="Line start or non-blank start",opts={expr=true}},
  {name=NS.global_motion_g_,    rhs=HCNvim.Util.KeyRecorder.loop_keys("g_",{"g_","$"}),desc="Line end or non-blank end",    opts={expr=true}},
  {
   name=NS.global_motion_V,
   rhs=HCNvim.Util.KeyRecorder.loop_keys_with_mode("V",{n="V",V="<esc>^vg_",v="<esc>"},{n="V",V="<esc>V",v="<esc>V"}),
   desc="Line or Charwise Line (non-blank)",
   opts={expr=true},
  },
  {
   name=NS.global_motion_j,
   rhs=(function()
    local hold=HCNvim.Util.Keymod.Hold.create("j",function()
     local win_lineend=vim.fn.line("w$")-vim.fn.line("w0")
     local lineend=vim.fn.line("$")
     local line=math.min(lineend,win_lineend)-1
     local step=math.ceil(math.max(1,line/20))
     return tostring(step)
      .."j"
    end)
    local inblank=HCNvim.Util.Keymod.InBlank.create(nil,"^")
    return HCNvim.Util.Keymod.Base.create(
     hold,
     HCNvim.Util.Keymod.Base.concat(hold,inblank),
     function()
      return vim.fn.mode()~="\22"
     end
    )
   end)(),
   opts={expr=true},
  },
  {
   name=NS.global_motion_k,
   rhs=(function()
    local hold=HCNvim.Util.Keymod.Hold.create("k",function()
     local win_lineend=vim.fn.line("w$")-vim.fn.line("w0")
     local lineend=vim.fn.line("$")
     local line=math.min(lineend,win_lineend)-1
     local step=math.ceil(math.max(1,line/20))
     return tostring(step)
      .."k"
    end)
    local inblank=HCNvim.Util.Keymod.InBlank.create(nil,"^")
    return HCNvim.Util.Keymod.Base.create(
     hold,
     HCNvim.Util.Keymod.Base.concat(hold,inblank),
     function()
      return vim.fn.mode()~="\22"
     end
    )
   end)(),
   opts={expr=true},
  },
  {
   name=NS.global_motion_h,
   rhs=HCNvim.Util.Keymod.Hold.create("h",function()
    local win_width=vim.fn.getwininfo(vim.fn.win_getid())[1].width
    local col_len=vim.fn.col("$")
    local col=math.min(win_width,col_len)-1
    local step=math.ceil(math.min(math.max(1,math.min(col/10)),3))
    return tostring(step)
     .."h"
   end),
   opts={expr=true},
  },
  {
   name=NS.global_motion_l,
   rhs=HCNvim.Util.Keymod.Hold.create("l",function()
    local win_width=vim.fn.getwininfo(vim.fn.win_getid())[1].width
    local col_len=vim.fn.col("$")
    local col=math.min(win_width,col_len)-1
    local step=math.ceil(math.min(math.max(1,math.min(col/10)),3))
    return tostring(step)
     .."l"
   end),
   opts={expr=true},
  },
 },
 {
  {name=NS.insert_delete,rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Delete>",true,false,true),"m") end},
  {name=NS.insert_w,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<c-o>w",true,false,true),"n") end},  
  {name=NS.insert_b,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<c-o>b",true,false,true),"n") end},  
  {name=NS.insert_h,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Left>",true,false,true),"m") end},  
  {name=NS.insert_j,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Down>",true,false,true),"m") end},  
  {name=NS.insert_k,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Up>",true,false,true),"m") end},    
  {name=NS.insert_l,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Right>",true,false,true),"m") end}, 
 },
 {
  {name=NS.cmdline_delete,rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Delete>",true,false,true),"m") end},
  {name=NS.cmdline_h,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Left>",true,false,true),"m") end},
  {name=NS.cmdline_j,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Down>",true,false,true),"m") end},
  {name=NS.cmdline_k,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Up>",true,false,true),"m") end},
  {name=NS.cmdline_l,     rhs=function() vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Right>",true,false,true),"m") end},
 },
}

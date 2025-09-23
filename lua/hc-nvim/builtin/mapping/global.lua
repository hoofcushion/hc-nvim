local Util=require("hc-nvim.util.init_space")
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
  {name=NS.global_option_wrap,          rhs=Util.Wrapper.toggle_option("wrap")},
  {name=NS.global_option_cursorline,    rhs=Util.Wrapper.toggle_option("cursorline")},
  {name=NS.global_option_cursorcolumn,  rhs=Util.Wrapper.toggle_option("cursorcolumn")},
  {name=NS.global_option_signcolum,     rhs=Util.Wrapper.toggle_option("signcolumn",{"yes","no"})},
  {name=NS.global_option_number,        rhs=Util.Wrapper.toggle_option("number")},
  {name=NS.global_option_relativenumber,rhs=Util.Wrapper.toggle_option("relativenumber")},
  {name=NS.global_option_foldenable,    rhs=Util.Wrapper.toggle_option("foldenable")},
  {name=NS.global_option_syntax,        rhs=Util.Wrapper.toggle_option("syntax",{"on","off"})},
  {
   name=NS.global_option_treesitter,
   rhs=function()
    if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] then
     vim.treesitter.stop()
    else
     vim.treesitter.start()
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
  {name=NS.global_change_r,       rhs="r"},
  {name=NS.global_change_R,       rhs="R"},
  {
   name=NS.global_change_c,
   lhs="c",
   rhs=function() return vim.v.count==0 and "c" or "s" end,
   opts={expr=true},
  },
 },
 {name=NS.global_edit_break_points,rhs=function(lhs) return lhs.."<c-g>u" end,opts={expr=true}},
 {name=NS.global_visual_indent,    rhs=function(lhs) return lhs.."gv" end,    opts={expr=true}},
 {
  {name=NS.global_motion_ge,rhs="ge"},
  {name=NS.global_motion_gE,rhs="gE"},
  {name=NS.global_motion_b, rhs="b"},
  {name=NS.global_motion_B, rhs="B"},
  {name=NS.global_motion_e, rhs="e"},
  {name=NS.global_motion_E, rhs="E"},
  {name=NS.global_motion_w, rhs="w"},
  {name=NS.global_motion_W, rhs="W"},
  {
   override={opts={expr=true}},
   {name=NS.global_motion_0,     rhs=Util.KeyRecorder.loop_keys("0",{"0","^"}),  desc="Line start or non-blank start"},
   {name=NS.global_motion_doller,rhs=Util.KeyRecorder.loop_keys("$",{"$","g_"}), desc="Line end or non-blank end"},
   {name=NS.global_motion_caret, rhs=Util.KeyRecorder.loop_keys("^",{"^","0"}),  desc="Line start or non-blank start"},
   {name=NS.global_motion_g_,    rhs=Util.KeyRecorder.loop_keys("g_",{"g_","$"}),desc="Line end or non-blank end"},
   {
    name=NS.global_motion_V,
    rhs=Util.KeyRecorder.loop_keys_with_mode(
     "V",
     {n="V",V="<esc>^vg_",v="<esc>"},
     {n="V",V="<esc>V",v="<esc>V"}
    ),
    desc="Line or Charwise Line (non-blank)",
   },
   {
    name=NS.global_motion_j,
    rhs=(function()
     local hold=Util.Keymod.Hold.create("j",function()
      local win_lineend=vim.fn.line("w$")-vim.fn.line("w0")
      local lineend=vim.fn.line("$")
      local line=math.min(lineend,win_lineend)-1
      local step=math.max(1,math.floor(math.max(1,line/20)))
      return tostring(step)
       .."j"
     end)
     local inblank=Util.Keymod.InBlank.create(nil,"^")
     return Util.Keymod.Base.create(
      hold,
      Util.Keymod.Base.concat(hold,inblank),
      function()
       return vim.fn.mode()~=""
      end
     )
    end)(),
   },
   {
    name=NS.global_motion_k,
    rhs=(function()
     local hold=Util.Keymod.Hold.create("k",function()
      local win_lineend=vim.fn.line("w$")-vim.fn.line("w0")
      local lineend=vim.fn.line("$")
      local line=math.min(lineend,win_lineend)-1
      local step=math.max(1,math.floor(math.max(1,line/20)))
      return tostring(step)
       .."k"
     end)
     local inblank=Util.Keymod.InBlank.create(nil,"^")
     return Util.Keymod.Base.create(
      hold,
      Util.Keymod.Base.concat(hold,inblank),
      function()
       return vim.fn.mode()~=""
      end
     )
    end)(),
   },
   {
    name=NS.global_motion_h,
    rhs=Util.Keymod.Hold.create("h",function()
     local win_width=vim.fn.getwininfo(vim.fn.win_getid())[1].width
     local col_len=vim.fn.col("$")
     local col=math.min(win_width,col_len)-1
     local step=math.floor(math.max(1,math.min(col/30)))
     return tostring(step)
      .."h"
    end),
   },
   {
    name=NS.global_motion_l,
    rhs=Util.Keymod.Hold.create("l",function()
     local win_width=vim.fn.getwininfo(vim.fn.win_getid())[1].width
     local col_len=vim.fn.col("$")
     local col=math.min(win_width,col_len)-1
     local step=math.floor(math.max(1,math.min(col/30)))
     return tostring(step)
      .."l"
    end),
   },
  },
 },
}

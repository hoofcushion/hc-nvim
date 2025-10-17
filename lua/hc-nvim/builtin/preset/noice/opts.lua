local Config=require("hc-nvim.config")
local Rsc=require("hc-nvim.rsc")
---@module "noice"
---@type NoiceConfig|{}
return vim.tbl_deep_extend(
 "force",
 {
  cmdline={
   view="cmdline",
  },
  ---@type table<string, NoiceCommand|{}>
  commands={
   history={view="popup"},
   last={view="popup"},
   errors={view="popup"},
   all={view="popup"},
  },
  lsp={
   progress={
    enabled=true,
   },
   override={
    ["vim.lsp.util.convert_input_to_markdown_lines"]=true,
    ["vim.lsp.util.stylize_markdown"]=true,
    ["cmp.entry.get_documentation"]=true,
   },
  },
  redirect={
   view="popup",
  },
  -- set refresh limit
  throttle=Config.performance.throttle,
  presets={
   bottom_search=true,
   command_palette=true,
   long_message_to_split=true,
   inc_rename=true,
   lsp_doc_border=false,
  },
  ---@type NoiceConfigViews|{}
  views=vim.tbl_deep_extend(
   "force",
   -- set all border style
   (function()
    local ret={}
    for _,key in ipairs({
     "cmdline",
     "cmdline_input",
     "cmdline_output",
     "cmdline_popup",
     "cmdline_popupmenu",
     "confirm",
     "hover",
     "messages",
     "mini",
     "notify",
     "popup",
     "popupmenu",
     "split",
     "virtualtext",
     "vsplit",
    }) do
     ret[key]={
      border={
       style=Rsc.border[Config.ui.border],
      },
      win_options={
       winblend=Config.ui.blend,
      },
     }
    end
    return ret
   end)(),
   {
    hover={
     position={row=0,col=4},
    },
   },

   -- set window size
   {
    popup={size={height=Config.ui.size.percentage.height,width=Config.ui.size.percentage.width}},
    split={size=Config.ui.size.percentage.vertical},
    vsplit={size=Config.ui.size.percentage.horizontal},
   },
   -- fix cmdline border
   {
    cmdline={
     border={
      padding={0,-1},
     },
    },
   }

  ),
 },
 {
  messages={
   view="notify",
   view_error="notify",
   view_warn="notify",
  },
  lsp={
   message={
    view="notify",
   },
   progress={
    view="notify",
   },
  },
 }
)

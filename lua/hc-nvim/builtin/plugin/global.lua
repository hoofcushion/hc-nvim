---@module "lazy"

local Events=require("hc-nvim.setup.events")
local Enter={Events.LeaveDashBoard,"BufReadPre","BufNewFile","BufWritePre"}
---@type LazySpec|{
--- auto: boolean?,
---}
return {
 -- {"goolord/alpha-nvim",               lazy=false,          cond=vim.fn.argv(0)==""},
 {"folke/tokyonight.nvim",            lazy=false},
 {"nvimdev/dashboard-nvim",           lazy=false,cond=vim.fn.argc()==0},
 {"folke/noice.nvim",                 lazy=false},
 {"rcarriga/nvim-notify"},
 {"stevearc/dressing.nvim"},

 {"folke/which-key.nvim",             event="SafeState"},

 --- Information
 {"nvim-lualine/lualine.nvim",        event=Enter},
 {"Bekaboo/dropbar.nvim",             event=Enter},
 {"nvim-ufo",                         event=Enter},
 {"ldelossa/buffertag",               event=Enter},
 {"chentoast/marks.nvim",             event=Enter},
 {"rainbowhxch/beacon.nvim",          event=Enter},

 {"smjonas/live-command.nvim",        event="CmdlineEnter"},
 {"nacro90/numb.nvim",                event="CmdlineEnter"},

 --- Searchers
 {"ibhagwan/fzf-lua"},
 {"nvim-telescope/telescope.nvim"},

 --- Motions
 {"chrisgrieser/nvim-spider"},
 {"echasnovski/mini.ai"},
 {"echasnovski/mini.operators"},
 {"folke/flash.nvim"},

 --- Edit
 {"hc-substitute",                    main="hc-substitute",                      virtual=true},
 {"echasnovski/mini.align"},
 {"echasnovski/mini.surround"},
 {"numToStr/Comment.nvim"},
 {"gbprod/yanky.nvim"},

 --- Tools
 {"hc-func",                          main="hc-func",                            virtual=true,        event=Enter},
 {"RaafatTurki/hex.nvim"},
 {"akinsho/toggleterm.nvim"},
 {"chrisgrieser/nvim-various-textobjs"},
 {"dstein64/vim-startuptime"},
 {"folke/zen-mode.nvim"},
 {"glepnir/dbsession.nvim"},
 {"nvim-neo-tree/neo-tree.nvim",      lazy=vim.fn.isdirectory(vim.fn.argv(0))==0,event=Events.DirEnter},
 -- {"nvim-telescope/telescope-file-browser.nvim", lazy=vim.fn.isdirectory(vim.fn.argv(0))==0,event=Events.DirEnter},
 -- {"nvim-tree/nvim-tree.lua",                    event=Events.DirEnter},
 {"nvim-pack/nvim-spectre"},
 {"s1n7ax/nvim-window-picker"},
 {"smoka7/multicursors.nvim"},

 --- Completions
 {"L3MON4D3/LuaSnip",                 event="InsertEnter"},
 {"rafamadriz/friendly-snippets",     event=Events.LazyLoad("LuaSnip")},
 -- {"hrsh7th/nvim-cmp",                           event={"InsertEnter","CmdlineEnter"}},
 {
  "iguanacucumber/magazine.nvim",
  name="nvim-cmp",
  event={"InsertEnter","CmdlineEnter"},
  dependencies={
   "dmitmel/cmp-cmdline-history",
   "FelipeLema/cmp-async-path",
   "hrsh7th/cmp-buffer",
   "hrsh7th/cmp-cmdline",
   "hrsh7th/cmp-nvim-lsp",
   "petertriho/cmp-git",
   "saadparwaiz1/cmp_luasnip",
  },
 },
 -- {"Saghen/blink.cmp",                           lazy=false},



 --- Highlighter
 {"NvChad/nvim-colorizer.lua",                  event=Enter},
 {"echasnovski/mini.trailspace",                event=Enter},
 {"folke/todo-comments.nvim",                   event=Enter},
 {"nfrid/due.nvim",                             event=Enter},
 {"lukas-reineke/indent-blankline.nvim",        event=Enter},
 {"hiphish/rainbow-delimiters.nvim",            event=Enter,                           auto=true},

 --- AI
 -- {"zbirenbaum/copilot.lua"},
 {"luozhiya/fittencode.nvim",                   event="InsertEnter"},

 --- Git
 {"sindrets/diffview.nvim"},
 {"lewis6991/gitsigns.nvim",                    event=Events.RootPattern(".git")},
 {"NeogitOrg/neogit"},
 {"kdheepak/lazygit.nvim"},

 --- Manager, LSP, Formatter, DAP, Linter
 {"williamboman/mason.nvim"},
 {"WhoIsSethDaniel/mason-tool-installer.nvim"},
 {"mfussenegger/nvim-dap"},
 {"neovim/nvim-lspconfig"},
 {"nvimtools/none-ls.nvim"},

 --- LSP tools
 {"Wansmer/symbol-usage.nvim",                  event="LspAttach"},
 {"folke/lazydev.nvim",                         event=Events.NeoConfig},

 --- Treesitter
 {"nvim-treesitter/nvim-treesitter",            event=Enter},
 {"nvim-treesitter/nvim-treesitter-context",    event=Enter},
 {"andymass/vim-matchup",                       event=Enter},
 {"JoosepAlviste/nvim-ts-context-commentstring",event=Events.LazyLoad("Comment.nvim")},
 {"folke/ts-comments.nvim",                     event=Events.LazyLoad("Comment.nvim")},
 {"RRethy/nvim-treesitter-endwise",             event="InsertEnter"},
 {"Wansmer/binary-swap.nvim"},
 {"mizlan/iswap.nvim"},
 {"nvim-treesitter/nvim-treesitter-textobjects"},
 {"altermo/ultimate-autopair.nvim",             event={"InsertEnter","CmdlineEnter"}},

 {"windwp/nvim-ts-autotag"},
 {"abecodes/tabout.nvim"},
 {"Wansmer/treesj"},
 {"sustech-data/wildfire.nvim"},

 --- Notebook
 {"zk-org/zk-nvim",                             event=Events.RootPattern(".zk")},
 {"MeanderingProgrammer/markdown.nvim",         ft="markdown"},

 --- Libraries
 {"nvim-tree/nvim-web-devicons"},
}

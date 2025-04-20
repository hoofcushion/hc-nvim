---@module "lazy"

local Events=require("hc-nvim.setup.events")
---@type LazySpec|{
--- auto: boolean?,
---}
return {
 -- {"goolord/alpha-nvim",               lazy=false,          cond=vim.fn.argv(0)==""},
 {"folke/tokyonight.nvim",            lazy=false},
 {"nvimdev/dashboard-nvim",           event="VimEnter",               cond=vim.fn.argc()==0},
 {"folke/noice.nvim",                 event="VimEnter"},
 {"nvim-lualine/lualine.nvim",        event="VimEnter"},

 {"rcarriga/nvim-notify"},
 {"stevearc/dressing.nvim"},

 {"echasnovski/mini.nvim"},

 {"folke/which-key.nvim",             event="SafeState"},

 --- Information
 {"Bekaboo/dropbar.nvim",             event="VimEnter"},
 {"kevinhwang91/nvim-ufo",            event="VimEnter"},
 {"ldelossa/buffertag",               event="VimEnter"},
 {"chentoast/marks.nvim",             event="VimEnter"},
 {"rainbowhxch/beacon.nvim",          event="VimEnter"},

 {"smjonas/live-command.nvim",        event="CmdlineEnter"},
 {"nacro90/numb.nvim",                event="CmdlineEnter"},

 --- Searchers
 {"ibhagwan/fzf-lua"},
 {"nvim-telescope/telescope.nvim"},

 --- Motions
 {"chrisgrieser/nvim-spider"},
 {"echasnovski/mini.ai",              virtual=true},
 {"echasnovski/mini.operators",       virtual=true},
 {"folke/flash.nvim"},

 --- Edit
 {"hoofcushion/hc-substitute",        virtual=true},
 {"echasnovski/mini.align",           virtual=true},
 {"echasnovski/mini.surround",        virtual=true},
 {"numToStr/Comment.nvim"},
 {"gbprod/yanky.nvim"},

 --- Tools
 {"hoofcushion/hc-func",              event="VimEnter",               main="hc-func",      virtual=true},
 {"RaafatTurki/hex.nvim"},
 {"akinsho/toggleterm.nvim"},
 {"chrisgrieser/nvim-various-textobjs"},
 {"folke/zen-mode.nvim"},
 {"glepnir/dbsession.nvim"},
 {"nvim-neo-tree/neo-tree.nvim",      ft="directory"},
 -- {"nvim-telescope/telescope-file-browser.nvim", lazy=vim.fn.isdirectory(vim.fn.argv(0))==0,event=Events.DirEnter},
 -- {"nvim-tree/nvim-tree.lua",                    event=Events.DirEnter},
 {"nvim-pack/nvim-spectre"},
 {"s1n7ax/nvim-window-picker"},
 {"smoka7/multicursors.nvim"},
 --- Profiller
 {"dstein64/vim-startuptime"},
 {"stevearc/profile.nvim"},


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
 {"NvChad/nvim-colorizer.lua",                  event="VimEnter"},
 {"echasnovski/mini.trailspace",                event="VimEnter",                    virtual=true},
 {"folke/todo-comments.nvim",                   event="VimEnter"},
 {"nfrid/due.nvim",                             event="VimEnter"},
 {"lukas-reineke/indent-blankline.nvim",        event="VimEnter"},
 -- This werid plugin can't load at "BufEnter"
 {"hiphish/rainbow-delimiters.nvim",            event=Events.FileAdd},

 --- AI
 -- {"zbirenbaum/copilot.lua"},
 {"luozhiya/fittencode.nvim",                   event="InsertEnter"},
 -- {"huggingface/llm.nvim",                       event="InsertEnter"},

 --- Git
 {"sindrets/diffview.nvim"},
 {"lewis6991/gitsigns.nvim",                    event=Events.RootPattern(".git")},
 {"NeogitOrg/neogit"},
 {"kdheepak/lazygit.nvim"},

 --- LSP etc.
 {"williamboman/mason.nvim"},
 {"WhoIsSethDaniel/mason-tool-installer.nvim"},
 {"mfussenegger/nvim-dap"},
 {"neovim/nvim-lspconfig"},
 {"nvimtools/none-ls.nvim"},

 --- LSP tools
 {"Wansmer/symbol-usage.nvim",                  event="LspAttach"},
 {"SmiteshP/nvim-navbuddy",                     event="LspAttach"},

 -- Neovim develop
 {"folke/lazydev.nvim",                         event=Events.NeoConfig},

 --- Treesitter
 {"nvim-treesitter/nvim-treesitter",            event="FileType"},
 {"nvim-treesitter/nvim-treesitter-context",    event="FileType"},
 {"andymass/vim-matchup",                       event="FileType"},
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

---@module "lazy"

local Events=require("hc-nvim.setup.events")
---@type LazySpec|{
--- auto: boolean?,
---}
return {
 -- {"goolord/alpha-nvim",               lazy=false,          cond=vim.fn.argv(0)==""},
 {"folke/tokyonight.nvim",                      lazy=false},
 -- {"nvimdev/dashboard-nvim",           event="VimEnter",               cond=vim.fn.argc()==0},  -- replaced by snacks.nvim
 {"folke/noice.nvim",                           event=Events.File},
 {"nvim-lualine/lualine.nvim",                  event=Events.File},

 -- {"rcarriga/nvim-notify"}, -- replaced by snacks.nvim
 {"stevearc/dressing.nvim"},

 {"echasnovski/mini.nvim"},

 {"folke/which-key.nvim",                       event="SafeState"},

 --- Information
 {"Bekaboo/dropbar.nvim",                       event=Events.File},
 {"kevinhwang91/nvim-ufo",                      event=Events.File},
 {"ldelossa/buffertag",                         event=Events.File},
 {"chentoast/marks.nvim",                       event=Events.File},
 {"rainbowhxch/beacon.nvim",                    event=Events.File},

 {"smjonas/live-command.nvim",                  event="CmdlineEnter"},
 {"nacro90/numb.nvim",                          event="CmdlineEnter"},

 --- Searchers
 {"ibhagwan/fzf-lua"},
 {"nvim-telescope/telescope.nvim"},

 --- Motions
 {"chrisgrieser/nvim-spider"},
 {"echasnovski/mini.ai",                        virtual=true},
 {"echasnovski/mini.operators",                 virtual=true},
 {"folke/flash.nvim"},
 {"folke/snacks.nvim",                          lazy=false,                                          version="*"},

 --- Edit
 {"hoofcushion/hc-substitute",                  virtual=true},
 {"echasnovski/mini.align",                     virtual=true},
 {"echasnovski/mini.surround",                  virtual=true},
 {"numToStr/Comment.nvim"},
 {"gbprod/yanky.nvim"},
 {"monaqa/dial.nvim"},

 --- Tools
 {"hoofcushion/hc-func",                        event=Events.File,                                   main="hc-func",virtual=true},
 {"RaafatTurki/hex.nvim"},
 {"akinsho/toggleterm.nvim"},
 {"chrisgrieser/nvim-various-textobjs"},
 {"glepnir/dbsession.nvim"},
 {"nvim-neo-tree/neo-tree.nvim",                ft="directory"},
 -- {"nvim-telescope/telescope-file-browser.nvim", lazy=vim.fn.isdirectory(vim.fn.argv(0))==0,event=Events.DirEnter},
 -- {"nvim-tree/nvim-tree.lua",                    event=Events.DirEnter},
 {"nvim-pack/nvim-spectre"},
 {"s1n7ax/nvim-window-picker"},
 {"smoka7/multicursors.nvim"},
 --- Profiller
 {"dstein64/vim-startuptime"},
 -- {"stevearc/profile.nvim"}, -- replaced by snacks.nvim


 --- Completions
 {"L3MON4D3/LuaSnip",                           event="InsertEnter"},
 {"rafamadriz/friendly-snippets",               event=Events.LazyLoad("LuaSnip")},
 -- {"hrsh7th/nvim-cmp",                           event={"InsertEnter","CmdlineEnter"}},
 {"iguanacucumber/magazine.nvim",               event={"InsertEnter","CmdlineEnter"},                name="nvim-cmp"},
 {"dmitmel/cmp-cmdline-history",                event={"CmdlineEnter"}},
 {"FelipeLema/cmp-async-path",                  event=Events.File},
 {"hrsh7th/cmp-buffer",                         event=Events.File},
 {"hrsh7th/cmp-cmdline",                        event="CmdlineEnter"},
 {"hrsh7th/cmp-nvim-lsp",                       event="LspAttach"},
 {"petertriho/cmp-git",                         ftfiletype={"gitcommit","octo","NeogitCommitMessage"}},
 {"saadparwaiz1/cmp_luasnip",                   event=Events.File},
 -- {"Saghen/blink.cmp",                           lazy=false},



 --- Highlighter
 {"NvChad/nvim-colorizer.lua",                  event=Events.File},
 {"echasnovski/mini.trailspace",                event=Events.File,                                   virtual=true},
 {"folke/todo-comments.nvim",                   event=Events.File},
 {"nfrid/due.nvim",                             event=Events.File},
 -- {"lukas-reineke/indent-blankline.nvim",        event=Events.File}, -- replaced by snacks.nvim
 -- This werid plugin can't load at "BufEnter"
 {"hiphish/rainbow-delimiters.nvim",            event=Events.File},

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
 {"neovim/nvim-lspconfig",                      lazy=false,                                          config=false},
 {"nvimtools/none-ls.nvim"},

 --- LSP tools
 {"Wansmer/symbol-usage.nvim",                  event="LspAttach"},
 {"SmiteshP/nvim-navbuddy",                     event="LspAttach"},

 -- Neovim develop
 {"folke/lazydev.nvim",                         event=Events.NeoConfig},

 --- Treesitter
 {"nvim-treesitter/nvim-treesitter",            event=Events.Treesitter},
 {"nvim-treesitter/nvim-treesitter-context",    event=Events.Treesitter},
 {"andymass/vim-matchup",                       event=Events.Treesitter},
 {"JoosepAlviste/nvim-ts-context-commentstring",event=Events.LazyLoad("Comment.nvim")},
 {"folke/ts-comments.nvim",                     event=Events.LazyLoad("Comment.nvim")},
 {"RRethy/nvim-treesitter-endwise",             event=Events.Treesitter},
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
 -- {"nvim-neorg/neorg",                           ft="norg",                           config=true},

 --- Libraries
 -- {"nvim-tree/nvim-web-devicons"},
 {"echasnovski/mini.icon",                        virtual=true},
}

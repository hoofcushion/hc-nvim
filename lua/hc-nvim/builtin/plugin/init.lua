local Events=require("hc-nvim.setup.events")
local Enter={
 "BufReadPost",
 "BufNewFile",
 "BufWritePre",
}
---@type LazySpec
local Specs={
 -- {"goolord/alpha-nvim",               lazy=false,          cond=vim.fn.argv(0)==""},
 {"folke/tokyonight.nvim",                      lazy=false},
 {"nvimdev/dashboard-nvim",                     lazy=false,                                cond=vim.fn.argv(0)==""},
 {"folke/noice.nvim",                           event="UIEnter"},
 {"nvim-lualine/lualine.nvim",                  event="UIEnter"},

 {"folke/which-key.nvim",                       event="UIEnter"},
 {"rcarriga/nvim-notify",                       event=Enter},
 {"stevearc/dressing.nvim",                     event=Enter},

 --- Information
 {"Bekaboo/dropbar.nvim",                       event=Enter},
 {"nvim-ufo",                                   event=Enter},
 {"ldelossa/buffertag",                         event=Enter},
 {"chentoast/marks.nvim",                       event=Enter},
 {"rainbowhxch/beacon.nvim",                    event=Enter},

 {"smjonas/live-command.nvim",                  event="CmdlineEnter"},
 {"nacro90/numb.nvim",                          event="CmdlineEnter"},

 --- Searchers
 {"ibhagwan/fzf-lua"},
 {"nvim-telescope/telescope.nvim"},

 --- Motions
 {"chrisgrieser/nvim-spider"},
 {"echasnovski/mini.ai"},
 {"echasnovski/mini.operators"},
 {"folke/flash.nvim"},
 {"hc-substitute",                              main="hc-substitute",                      virtual=true},
 {"hc-func",                                    main="hc-func",                            virtual=true,                       event=Enter},

 --- Edit
 {"echasnovski/mini.align"},
 {"echasnovski/mini.surround"},
 {"numToStr/Comment.nvim"},
 {"gbprod/yanky.nvim"},

 --- Tools
 {"RaafatTurki/hex.nvim"},
 {"akinsho/toggleterm.nvim"},
 {"chrisgrieser/nvim-various-textobjs"},
 {"dstein64/vim-startuptime"},
 {"folke/zen-mode.nvim"},
 {"glepnir/dbsession.nvim"},
 {"nvim-neo-tree/neo-tree.nvim",                lazy=vim.fn.isdirectory(vim.fn.argv(0))==0,event=Events.DirEnter},
 -- {"nvim-telescope/telescope-file-browser.nvim", lazy=vim.fn.isdirectory(vim.fn.argv(0))==0,event=Events.DirEnter},
 -- {"nvim-tree/nvim-tree.lua",                    event=Events.DirEnter},
 {"nvim-pack/nvim-spectre"},
 {"s1n7ax/nvim-window-picker"},
 {"smoka7/multicursors.nvim"},

 --- Completions
 {"L3MON4D3/LuaSnip",                           event="InsertEnter"},
 {"altermo/ultimate-autopair.nvim",             event={"InsertEnter","CmdlineEnter"}},
 -- {"hrsh7th/nvim-cmp",                           event={"InsertEnter","CmdlineEnter"}},
 {"iguanacucumber/magazine.nvim",               name="nvim-cmp",                           event={"InsertEnter","CmdlineEnter"}},
 --- Cmp sources
 {"dmitmel/cmp-cmdline-history",                event="CmdlineEnter"},
 {"FelipeLema/cmp-async-path",                  event={"CmdlineEnter","InsertEnter"}},
 {"hrsh7th/cmp-buffer",                         event={"CmdlineEnter","InsertEnter"}},
 {"hrsh7th/cmp-cmdline",                        event="CmdlineEnter"},
 {"hrsh7th/cmp-nvim-lsp",                       event="LspAttach"},
 {"petertriho/cmp-git",                         ft="gitcommit",                            dependencies="nvim-lua/plenary.nvim"},
 {"saadparwaiz1/cmp_luasnip",                   event=Events.LazyLoad("LuaSnip")},
 {"folke/lazydev.nvim",                         event=Events.NeoConfig},

 --- Highlighter
 {"NvChad/nvim-colorizer.lua",                  event=Enter},
 {"echasnovski/mini.trailspace",                event=Enter},
 {"folke/todo-comments.nvim",                   event=Enter},
 {"nfrid/due.nvim",                             event=Enter},
 -- {"lukas-reineke/indent-blankline.nvim",        event=Enter},
 -- {"hiphish/rainbow-delimiters.nvim",            event=Enter},

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
return Specs

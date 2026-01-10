return {
 main="nvim-treesitter.configs",
 version="*", -- Use stable version to prevent 神必 error
 build=":TSUpdate",
 cmd={
  "TSInstall",
  "TSInstallFromGrammar",
  "TSInstallSync",
  "TSUpdate",
  "TSUpdateSync",
  "TSUninstall",
  "TSInstallInfo",
  "TSModuleInfo",
  "TSBufEnable",
  "TSBufDisable",
  "TSBufToggle",
  "TSEnable",
  "TSDisable",
  "TSToggle",
  "TSConfigInfo",
  "TSEditQuery",
  "TSEditQueryUserAfter",
 },
 init=function(plugin)
  vim.opt.rtp:append(plugin.dir)
 end,
}

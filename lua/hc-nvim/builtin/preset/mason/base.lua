return {
 cmd={
  "Mason",
  "MasonUpdate",
  "MasonLog",
  "MasonInstall",
  "MasonInstallAll",
  "MasonUninstall",
  "MasonUninstallAll",
 },
 init=function()
  local sep=vim.fn.has("win32") and ";" or ":"
  vim.env.PATH=vim.env.PATH..sep..vim.fs.joinpath(vim.fn.stdpath("data"),"mason","bin")
 end,
}

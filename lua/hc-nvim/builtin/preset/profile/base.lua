return {
 init=function(plugin)
  local nvim_profile=os.getenv("NVIM_PROFILE")
  if nvim_profile==nil then
   return
  end
  local prof=require("profile")
  require("lazy.core.loader").add_to_rtp(plugin)
  prof.instrument_autocmds()
  if nvim_profile:lower():match("^start") then
   prof.start("*")
  else
   prof.instrument("*")
  end
  local function toggle_profile()
   if prof.is_recording() then
    prof.stop()
    prof.export("profile.json")
   else
    prof.start("*")
   end
  end
  vim.keymap.set("","<f1>",toggle_profile)
 end,
}

return {
 highlight=require("hc-nvim.misc.rainbow").create(7,200/3,200/3),
 strategy={
  [""]=function(buf)
   if require("hc-nvim.util").Performance.is_bigbuf(buf) then
    return nil
   end
   return require("rainbow-delimiters").strategy["global"]
  end,
 },
}

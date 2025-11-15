local ufo=require("ufo")
local Wrapper=require("hc-nvim.util.wrapper")
return {
 {name=NS.ufo_open_all_folds,        rhs=ufo.openAllFolds},
 {name=NS.ufo_open_folds,            rhs=ufo.openFoldsExceptKinds},
 {name=NS.ufo_close_all_folds,       rhs=ufo.closeAllFolds},
 {name=NS.ufo_peek_fold_under_cursor,rhs=ufo.peekFoldedLinesUnderCursor},
 {name=NS.ufo_goto_previous_fold,    rhs=Wrapper.combine(ufo.goPreviousClosedFold,ufo.peekFoldedLinesUnderCursor)},
 {name=NS.ufo_goto_next_fold,        rhs=Wrapper.combine(ufo.goNextClosedFold,ufo.peekFoldedLinesUnderCursor)},
 {
  name=NS.ufo_close_fold_to_depth,
  rhs=function()
   local amount=tonumber(vim.fn.input("Depth: "))
   if amount==nil then return end
   amount=math.floor(amount)
   if amount<0 then
    ufo.closeFoldsWith(math.huge)
   else
    ufo.closeFoldsWith(amount)
   end
  end,
 },
}

local Util=require("hc-nvim.util")
local cmp=require("cmp")
local mapping={}
-- switch behavior from insert to select if holding key
-- this increase performance
mapping.select_prev=Util.Keymod.Hold.create(
 Util.Wrapper.fn_cond(cmp.visible,Util.Wrapper.curring(cmp.select_prev_item,{behavior=cmp.SelectBehavior.Insert})),
 Util.Wrapper.fn_cond(cmp.visible,Util.Wrapper.curring(cmp.select_prev_item,{behavior=cmp.SelectBehavior.Select})),
 {speed=100,trigger=2}
)
mapping.select_next=Util.Keymod.Hold.create(
 Util.Wrapper.fn_cond(cmp.visible,Util.Wrapper.curring(cmp.select_next_item,{behavior=cmp.SelectBehavior.Insert})),
 Util.Wrapper.fn_cond(cmp.visible,Util.Wrapper.curring(cmp.select_next_item,{behavior=cmp.SelectBehavior.Select})),
 {speed=100,trigger=2}
)
mapping.abort=Util.Wrapper.fn_cond(cmp.visible,cmp.abort)
mapping.doc_up=Util.Wrapper.fn_cond(cmp.visible_docs,cmp.scroll_docs)
mapping.doc_down=Util.Wrapper.fn_cond(cmp.visible_docs,cmp.scroll_docs)
mapping.toggle_doc=Util.Wrapper.fn_cond(cmp.visible_docs,cmp.close_docs,cmp.open_docs)
mapping.confirm=Util.Wrapper.fn_cond(cmp.visible,Util.Wrapper.curring(cmp.confirm,{select=true}))
local oldenabled
mapping.toggle=function()
 if Util.eval(require("cmp.config").global.enabled) then
  oldenabled=require("cmp.config").global.enabled
  cmp.setup({enabled=false})
 else
  cmp.setup({enabled=oldenabled})
 end
end
return {
 {name=NS.cmp_select_prev,rhs=mapping.select_prev},
 {name=NS.cmp_select_next,rhs=mapping.select_next},
 {name=NS.cmp_abort,      rhs=mapping.abort},
 {name=NS.cmp_confirm,    rhs=mapping.confirm},
 {name=NS.cmp_toggle_doc, rhs=mapping.toggle_doc},
 {name=NS.cmp_doc_up,     rhs=mapping.doc_up},
 {name=NS.cmp_doc_down,   rhs=mapping.doc_down},
 {name=NS.cmp_toggle,     rhs=mapping.toggle},
}

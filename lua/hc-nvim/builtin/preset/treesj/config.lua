return function(_,opts)
 local langs_utils=require("treesj.langs.utils")
 local DEFAULT_PRESET=require("treesj.langs.default_preset")
 local function set_preset(preset)
  preset=preset or {}
  preset=langs_utils.merge_preset(DEFAULT_PRESET,preset)
  return function(override)
   override=override or {}
   return langs_utils.merge_preset(preset,override)
  end
 end
 langs_utils.set_default_preset=set_preset({
  join={
   space_in_brackets=false,
   space_separator=false,
  },
 })
 langs_utils.set_preset_for_list=set_preset({
  both={separator=","},
  split={last_separator=true},
  join={
   space_in_brackets=false,
   space_separator=false,
  },
 })
 langs_utils.set_preset_for_dict=set_preset({
  both={separator=","},
  split={last_separator=true},
  join={
   space_in_brackets=false,
   space_separator=false,
  },
 })
 langs_utils.set_preset_for_statement=set_preset({
  join={
   force_insert=";",
   space_in_brackets=false,
   space_separator=true,
  },
 })
 langs_utils.set_preset_for_args=set_preset({
  both={separator=",",last_separator=false},
  join={
   space_in_brackets=false,
   space_separator=false,
  },
 })
 langs_utils.set_preset_for_non_bracket=set_preset({
  both={non_bracket_node=true},
  join={
   space_in_brackets=true,
   space_separator=false,
  },
 })
 local treesj=require("treesj")
 treesj.setup(opts)
end

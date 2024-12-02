local binary_swap=require("binary-swap")
return {
 {name=NS.swap_operand,              rhs=binary_swap.swap_operands},
 {name=NS.swap_operand_with_operator,rhs=binary_swap.swap_operands_with_operator},
}

/// @function  constraint_flip(constraint_list)
/// @argument  constraint_list 

var _constraint_list = argument[0];

var _temp = _constraint_list[| 0];
_constraint_list[| 0] = _constraint_list[| 2];
_constraint_list[| 2] = _temp;
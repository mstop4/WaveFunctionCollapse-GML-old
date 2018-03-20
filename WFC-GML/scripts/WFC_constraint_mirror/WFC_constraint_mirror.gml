/// @function  WFC_constraint_mirror(constraint_list)
/// @argument  constraint_list 

var _constraint_list = argument[0];

var _temp = _constraint_list[| 1];
_constraint_list[| 1] = _constraint_list[| 3];
_constraint_list[| 3] = _temp;
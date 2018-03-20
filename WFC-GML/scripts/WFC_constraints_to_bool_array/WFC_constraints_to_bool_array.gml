/// @function  WFC_constraints_to_bool_array(list)
/// @param     list 

var _list = argument[0];

var _return_array = array_create(1);
var _list_len = ds_list_size(_list);

for (var i=0; i<_list_len; i++)
	_return_array[_list[| i]] = true;

return _return_array;
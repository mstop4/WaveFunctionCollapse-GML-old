/// @function  load_constraints_sym(sym_file, cons_file)
/// @argument  sym_file  
/// @argument  cons_file 

var _sym_file = argument[0];
var _cons_file = argument[1];

// Load symmetry data
var _file = file_text_open_read(_sym_file);

if (!_file)
{
	show_message_async("Error loading symmetries file");
	return false;
}

var _json = file_text_read_string(_file);
var _sym_map = json_decode(_json);
file_text_close(_file);

// Load base constraint data
_file = file_text_open_read(_cons_file);

if (!_file)
{
	show_message_async("Error loading constraints file");
	return false;
}

_json = file_text_read_string(_file);
var _json_map = json_decode(_json);
file_text_close(_file);

if (_json_map == -1)
{
	show_message_async("Error decoding JSON");
	return false;
}

var _base_tile_constraints = _json_map[? "default"];

// Generate constraint data with symmetries
var _num_base_tile_constraints = ds_list_size(_base_tile_constraints);
var _num_tile_constraints = 0;
tile_constraints = ds_list_create();

for (var i=0; i<_num_base_tile_constraints; i++)
{
	if (filter_mode == filterMode.include && ds_list_find_index(tile_filter, i) <> -1) ||
		(filter_mode == filterMode.exclude && ds_list_find_index(tile_filter, i) == -1)
	{
		var _cur_tile_data = _base_tile_constraints[| i];
		
		if (!ignore_symmetries)
		{
			// Get symmetry data
			var _cur_tile_sym_type = _cur_tile_data[| 4];
			var _sym_data = _sym_map[? _cur_tile_sym_type];
		
			// Create symmetric constraints
			var _num_sym_data = ds_list_size(_sym_data);
		
			for (var j=0; j<_num_sym_data; j++)
			{
				var _wrk_tile_data = ds_list_create();
				ds_list_copy(_wrk_tile_data, _cur_tile_data);
				ds_list_delete(_wrk_tile_data, 4);
				var _cur_sym = _sym_data[| j];
		
				if (_cur_sym & 1)
					constraint_mirror(_wrk_tile_data);
				if (_cur_sym & 2)
					constraint_flip(_wrk_tile_data);
				if (_cur_sym & 4)
					constraint_rotate(_wrk_tile_data);
			
				ds_list_add(tile_constraints,_wrk_tile_data);
				ds_list_mark_as_list(tile_constraints, _num_tile_constraints);
				base_tile_index[_num_tile_constraints] = i;
				base_tile_symmetry[_num_tile_constraints] = _cur_sym;
				_num_tile_constraints++;
			}
		}
		
		else
		{
			var _wrk_tile_data = ds_list_create();
			ds_list_copy(_wrk_tile_data, _cur_tile_data);
			ds_list_delete(_wrk_tile_data, 4);
			ds_list_add(tile_constraints,_wrk_tile_data);
			
			ds_list_mark_as_list(tile_constraints, _num_tile_constraints);
			base_tile_index[_num_tile_constraints] = i;
			base_tile_symmetry[_num_tile_constraints] = "X";
			_num_tile_constraints++;
		}
	}
}

num_tiles = ds_list_size(tile_constraints);
ds_map_destroy(_json_map);
return true;
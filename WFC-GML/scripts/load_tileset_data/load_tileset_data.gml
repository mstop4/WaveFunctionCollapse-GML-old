/// @function  load_tileset_data(sym_file, cons_file)
/// @argument  symmetries_file  
/// @argument  constraints_file 
/// @argument  weights_file 

var _symmetries_file = argument[0];
var _constraints_file = argument[1];
var _weights_file = argument[2];

// Load symmetry data
var _json = load_json_stringify(_symmetries_file);

if (_json == "")
{
	show_message_async("Error loading symmetries file");
	return false;
}

var _sym_map = json_decode(_json);

// Load base constraint data
_json = load_json_stringify(_constraints_file);

if (_json == "")
{
	show_message_async("Error loading constraints file");
	return false;
}

var _json_map = json_decode(_json);

if (_json_map == -1)
{
	show_message_async("Error decoding constraints JSON");
	return false;
}

var _base_tile_constraints = _json_map[? "default"];

// Load base weights data

_json = load_json_stringify(_weights_file);

if (_json == "")
{
	show_message_async("Error loading weights file");
	return false;
}

var _json_map = json_decode(_json);

if (_json_map == -1)
{
	show_message_async("Error decoding weights JSON");
	return false;
}

var _base_tile_weights = _json_map[? "default"];
var _base_tile_weights_len = ds_list_size(_base_tile_weights);

// Generate constraint data with symmetries
var _num_base_tile_constraints = ds_list_size(_base_tile_constraints);
var _num_tile_constraints = 0;
tile_constraints = ds_list_create();

var _num_tile_occurences;
_num_tile_occurences[0] = 0;

for (var i=0; i<_num_base_tile_constraints; i++)
{
	var _cur_tile_data = _base_tile_constraints[| i];
	var _cur_tile_index_list = _cur_tile_data[? "tileId"];
	var _cur_tile_index_list_length = ds_list_size(_cur_tile_index_list);
	
	for (var k=0; k<_cur_tile_index_list_length; k++)
	{
		var _cur_tile_index = _cur_tile_index_list[| k];
		
		if (filter_mode == filterMode.include && ds_list_find_index(tile_filter, _cur_tile_index) <> -1) ||
			(filter_mode == filterMode.exclude && ds_list_find_index(tile_filter, _cur_tile_index) == -1)
		{	
			if (!ignore_symmetries)
			{
				// Get symmetry data
				var _cur_tile_sym_type = _cur_tile_data[? "symmetry"];
				var _sym_data = _sym_map[? _cur_tile_sym_type];
		
				// Create symmetric constraints
				var _num_sym_data = ds_list_size(_sym_data);
		
				for (var j=0; j<_num_sym_data; j++)
				{
					var _wrk_tile_data = ds_list_create();
				
					ds_list_add(_wrk_tile_data,
						_cur_tile_data[? "upId"],
						_cur_tile_data[? "rightId"],
						_cur_tile_data[? "downId"],
						_cur_tile_data[? "leftId"]
					);
				
					var _cur_sym = _sym_data[| j];
		
					if (_cur_sym & 1)
						constraint_mirror(_wrk_tile_data);
					if (_cur_sym & 2)
						constraint_flip(_wrk_tile_data);
					if (_cur_sym & 4)
						constraint_rotate(_wrk_tile_data);
			
					ds_list_add(tile_constraints,_wrk_tile_data);
					ds_list_mark_as_list(tile_constraints, _num_tile_constraints);
					base_tile_index[_num_tile_constraints] = _cur_tile_index;
					base_tile_symmetry[_num_tile_constraints] = _cur_sym;
					
					if (array_length_1d(_num_tile_occurences) <= _cur_tile_index)
						_num_tile_occurences[_cur_tile_index] = 1;
					else
						_num_tile_occurences[_cur_tile_index]++;
						
					_num_tile_constraints++;
				}
			}
		
			else
			{
				var _wrk_tile_data = ds_list_create();
			
				ds_list_add(_wrk_tile_data,
					_cur_tile_data[? "upId"],
					_cur_tile_data[? "rightId"],
					_cur_tile_data[? "downId"],
					_cur_tile_data[? "leftId"]
				);
			
				ds_list_add(tile_constraints,_wrk_tile_data);
			
				ds_list_mark_as_list(tile_constraints, _num_tile_constraints);
				base_tile_index[_num_tile_constraints] = _cur_tile_index;
				base_tile_symmetry[_num_tile_constraints] = "X";
				_num_tile_constraints++;
			}
		}
	}
}

num_tiles = ds_list_size(tile_constraints);

// Calculate weights for each tile
for (var i=0; i<num_tiles; i++)
{
	base_tile_weight[i] = _base_tile_weights[| base_tile_index[i]] / _num_tile_occurences[base_tile_index[i]];
}

ds_map_destroy(_json_map);
return true;
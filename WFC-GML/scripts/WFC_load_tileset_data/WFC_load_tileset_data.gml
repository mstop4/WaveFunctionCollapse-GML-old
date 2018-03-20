/// @function  load_tileset_data(sym_file, cons_file)
/// @argument  symmetries_file  
/// @argument  constraints_file 
/// @argument  weights_file 

var _symmetries_file = argument[0];
var _constraints_file = argument[1];
var _weights_file = argument[2];

if (ds_exists(tile_constraints, ds_type_list))
	ds_list_destroy(tile_constraints);
	
if (ds_exists(tile_edge_ids, ds_type_list))
	ds_list_destroy(tile_edge_ids);
	
if (ds_exists(symmetries_json, ds_type_map))
	ds_map_destroy(symmetries_json);
	
if (ds_exists(constraints_json, ds_type_list))
	ds_map_destroy(constraints_json);
	
if (ds_exists(weights_json, ds_type_list))
	ds_map_destroy(weights_json);

// Load symmetry data
var _json = WFC_load_json_stringify(_symmetries_file);

if (_json == "")
{
	show_message_async("Error loading symmetries file");
	return false;
}

symmetries_json = json_decode(_json);

if (symmetries_json == -1)
{
	show_message_async("Error decoding constraints JSON");
	return false;
}

var _sym_map = symmetries_json;

// Load base constraint data
_json = WFC_load_json_stringify(_constraints_file);

if (_json == "")
{
	show_message_async("Error loading constraints file");
	return false;
}

constraints_json = json_decode(_json);

if (constraints_json == -1)
{
	show_message_async("Error decoding constraints JSON");
	return false;
}

var _base_tile_constraints = constraints_json[? "default"];

// Generate constraint data with symmetries
var _num_base_tile_constraints = ds_list_size(_base_tile_constraints);
var _num_tile_constraints = 0;
tile_constraints = ds_list_create();
tile_edge_ids = ds_list_create();

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
		
		if (filter_mode == filterMode.include && ds_list_find_index(tile_filter, _cur_tile_index) != -1) ||
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
					var _wrk_tile_edge_data = ds_list_create();
					var _wrk_tile_neighbour_data = ds_list_create();
				
					ds_list_add(_wrk_tile_edge_data,
						_cur_tile_data[? "upEdgeId"],
						_cur_tile_data[? "rightEdgeId"],
						_cur_tile_data[? "downEdgeId"],
						_cur_tile_data[? "leftEdgeId"]
					);
					
					ds_list_add(_wrk_tile_neighbour_data,
						_cur_tile_data[? "upNeighbours"],
						_cur_tile_data[? "rightNeighbours"],
						_cur_tile_data[? "downNeighbours"],
						_cur_tile_data[? "leftNeighbours"]
					);
					
					for (var m=0; m<4; m++)
						ds_list_mark_as_list(_wrk_tile_neighbour_data,m);
				
					var _cur_sym = _sym_data[| j];
		
					if (_cur_sym & 1)
					{
						WFC_constraint_mirror(_wrk_tile_edge_data);
						WFC_constraint_mirror(_wrk_tile_neighbour_data);
					}
					
					if (_cur_sym & 2)
					{
						WFC_constraint_flip(_wrk_tile_edge_data);
						WFC_constraint_flip(_wrk_tile_neighbour_data);
					}
					
					if (_cur_sym & 4)
					{
						WFC_constraint_rotate(_wrk_tile_edge_data);
						WFC_constraint_rotate(_wrk_tile_neighbour_data);
					}
			
					ds_list_add(tile_edge_ids,_wrk_tile_edge_data);
					ds_list_mark_as_list(tile_edge_ids, _num_tile_constraints);
					ds_list_add(tile_constraints,_wrk_tile_neighbour_data);
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
				var _wrk_tile_edge_data = ds_list_create();
				var _wrk_tile_neighbour_data = ds_list_create();
				
				ds_list_add(_wrk_tile_edge_data,
					_cur_tile_data[? "upEdgeId"],
					_cur_tile_data[? "rightEdgeId"],
					_cur_tile_data[? "downEdgeId"],
					_cur_tile_data[? "leftEdgeId"]
				);
					
				ds_list_add(_wrk_tile_neighbour_data,
					_cur_tile_data[? "upNeighbours"],
					_cur_tile_data[? "rightNeighbours"],
					_cur_tile_data[? "downNeighbours"],
					_cur_tile_data[? "leftNeighbours"]
				);
			
				ds_list_add(tile_edge_ids,_wrk_tile_edge_data);
				ds_list_mark_as_list(tile_edge_ids, _num_tile_constraints);
				ds_list_add(tile_constraints,_wrk_tile_neighbour_data);
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
	}
}

num_tiles = ds_list_size(tile_constraints);

if (!ignore_weights)
{
	// Load base weights data
	_json = WFC_load_json_stringify(_weights_file);

	if (_json == "")
	{
		show_message_async("Error loading weights file");
		return false;
	}

	weights_json = json_decode(_json);

	if (weights_json == -1)
	{
		show_message_async("Error decoding weights JSON");
		return false;
	}

	var _base_tile_weights = weights_json[? "default"];
	var _base_tile_weights_len = ds_list_size(_base_tile_weights);

	// Calculate weights for each tile
	for (var i=0; i<num_tiles; i++)
		base_tile_weight[i] = _base_tile_weights[| base_tile_index[i]] / _num_tile_occurences[base_tile_index[i]];
}

else
{
	// Calculate weights for each tile
	for (var i=0; i<num_tiles; i++)
	{
		if (_num_tile_occurences[base_tile_index[i]] != 0)
			base_tile_weight[i] = 1 / _num_tile_occurences[base_tile_index[i]];
		else
			base_tile_weight[i] = 1;
	}
}

return true;
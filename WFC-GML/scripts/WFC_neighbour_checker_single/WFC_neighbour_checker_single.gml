/// @function  WFC_neighbour_checker_single(cur_cell, index, cur_cell_x, cur_cell_y)
/// @param     cur_cell 
/// @param	   index
/// @param	   cur_cell_x
/// @param	   cur_cell_y

var _cur_cell = argument[0];
var _index = argument[1];
var _cur_cell_x = argument[2];
var _cur_cell_y = argument[3];

var _cur_tile = _cur_cell[| _index];
var _cur_constraints = tile_constraints[| _cur_tile];
var _ok;
			
var _cur_tile_constraint, _cur_tile_edge_ids, _cur_tile_edge,
	_neighbour_cell, _neighbour_tile, _neighbour_constraints,
	_neighbour_tile_constraint, _neighbour_tile_edge_ids, _neighbour_tile_edge;
							
var _cell_changed = false;
			
for (var d=0; d<4; d++)
{
	var _cur_x, _cur_y, _cur_tile_edge_id, _neighbour_tile_edge_id;
							
	switch (d)
	{
		// Up
		case 0:
			_cur_y = _cur_cell_y-1;
			if (_cur_y < 0)
				continue;
										
			_cur_x = _cur_cell_x;
			_cur_tile_edge_id = 0;
			_neighbour_tile_edge_id = 2;
			break;
								
		// Right
		case 1:

			_cur_x = _cur_cell_x+1;
			if (_cur_x >= tilemap_width)
				continue;
									
			_cur_y = _cur_cell_y;
			_cur_tile_edge_id = 1;
			_neighbour_tile_edge_id = 3;
			break;
									
		// Down
		case 2:
			_cur_y = _cur_cell_y+1;
			if (_cur_y >= tilemap_height)
				continue;
										
			_cur_x = _cur_cell_x;
			_cur_tile_edge_id = 2;
			_neighbour_tile_edge_id = 0;
			break;
								
		// Left
		case 3:
			_cur_x = _cur_cell_x-1;
			if (_cur_x < 0)
				continue;
										
			_cur_y = _cur_cell_y;
			_cur_tile_edge_id = 3;
			_neighbour_tile_edge_id = 1;
			break;
	}
							
	if (visited[_cur_x, _cur_y])
	{
		_cur_tile_constraint = _cur_constraints[| _cur_tile_edge_id];
		_cur_tile_edge_ids = tile_edge_ids[| _cur_tile];
		_cur_tile_edge = _cur_tile_edge_ids[| _cur_tile_edge_id];
		_neighbour_cell = tilemap_grid[# _cur_x, _cur_y];
		_ok = false;
				
		for (var k=0; k<ds_list_size(_neighbour_cell); k++)
		{
			_neighbour_tile = _neighbour_cell[| k];
			_neighbour_tile_edge_ids = tile_edge_ids[| _neighbour_tile]
			_neighbour_tile_edge = _neighbour_tile_edge_ids[| _neighbour_tile_edge_id];
			_neighbour_constraints = tile_constraints[| _neighbour_tile];
			_neighbour_tile_constraint = _neighbour_constraints[| _neighbour_tile_edge_id];
				
			if (ds_list_find_index(_cur_tile_constraint, _neighbour_tile_edge) <> -1 &&
				ds_list_find_index(_neighbour_tile_constraint, _cur_tile_edge) <> -1)
			{
				_ok = true;
				break;
			}
		}
					
		if (!_ok)
		{
			ds_list_delete(_cur_cell, _index);
			entropy--;			
			_cell_changed = true;
							
			if (async_mode && realtime_tiling && ds_list_size(_cur_cell) == 1)
				ds_queue_enqueue(finished_tiles_queue, [_cur_cell_x, _cur_cell_y]);

		} //end if !ok
	} // end if visited
} // end for d
							
return _cell_changed;
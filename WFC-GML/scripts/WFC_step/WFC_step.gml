if (my_state != genState.idle)
{
	var _time_up = false;
	var _step_start_time = 0;
	process_time = 0;
		
	while (!_time_up)
	{
		_step_start_time = current_time;
		
		if (my_state == genState.collapse)
		{
			// Add tiles that have been determined to the tilemap
			if (async_mode && realtime_tiling)
			{
				while (!ds_queue_empty(finished_tiles_queue))
				{
					var _cell_coords = ds_queue_dequeue(finished_tiles_queue);
					var _data = tilemap_get(tilemap_layer, _cell_coords[0], _cell_coords[1]);
					var _cell = tilemap_grid[# _cell_coords[0], _cell_coords[1]];
					var _base_tile = base_tile_index[_cell[| 0]];
					var _transforms = base_tile_symmetry[_cell[| 0]];
					
					_data = tile_set_index(_data,_base_tile+tile_index_offset);
					_data = tile_set_mirror(_data,_transforms & 1);
					_data = tile_set_flip(_data,_transforms & 2);
					_data = tile_set_rotate(_data,_transforms & 4);
					tilemap_set(tilemap_layer, _data, _cell_coords[0], _cell_coords[1]);
					tiled[ _cell_coords[0], _cell_coords[1]] = true;
				}
			}
		
			WFC_reset_visited();

			// Find cells with lowest entropy
			var _cur_cell_data = WFC_pick_cell();
			var _cur_cell = _cur_cell_data[0];
			var _cur_cell_x = _cur_cell_data[1];
			var _cur_cell_y = _cur_cell_data[2];

			if (_cur_cell != -1)
			{
				visited[_cur_cell_x, _cur_cell_y] = true;

				// Collapse 
				var _cell_len = ds_list_size(_cur_cell);
				entropy -= (_cell_len - 1);
				var _chosen_index;
				
				// Pick weighted random tile
				var _sum_weights = 0;
				for (var i=0; i<_cell_len; i++)
					_sum_weights += base_tile_weight[_cur_cell[| i]];
					
				_chosen_index = -1;
				var _r = random(_sum_weights);
				var _running_weight = 0;
				
				do
				{
					_chosen_index++;
					_running_weight += base_tile_weight[_cur_cell[| _chosen_index]];
				} 
				until (_r <= _running_weight)
				
				if (_chosen_index >= _cell_len)
				{
					show_message_async("Error: tile index out of range.");
					my_state = genState.idle;
					exit;
				}
				
				var _selected_value = _cur_cell[| _chosen_index];
				ds_list_clear(_cur_cell);
				_cur_cell[| 0] = _selected_value;
			
				if (async_mode && realtime_tiling)
					ds_queue_enqueue(finished_tiles_queue, [_cur_cell_x, _cur_cell_y]);
	
				// Propagate
				my_state = genState.propagate;
			}
		
			else
			{
				if (entropy == 0)
				{
					for (var i=0; i<tilemap_height; i++)
					{
						for (var j=0; j<tilemap_width; j++)
						{
							if (!tiled[ j, i])
							{
								var _data = tilemap_get(tilemap_layer, j, i);
								var _cell = tilemap_grid[# j, i];
								var _base_tile = base_tile_index[_cell[| 0]];
								var _transforms = base_tile_symmetry[_cell[| 0]];
								
								_data = tile_set_index(_data,_base_tile+tile_index_offset);
								_data = tile_set_mirror(_data,_transforms & 1);
								_data = tile_set_flip(_data,_transforms & 2);
								_data = tile_set_rotate(_data,_transforms & 4);
								tilemap_set(tilemap_layer, _data, j, i);
								tiled[ j, i] = true;
							}
						}
					}
				}
			
				else
					show_message_async("Error: Cannot generate tilemap with current tileset.");
		
				my_state = genState.idle;
				_time_up = true;
				time_taken = (current_time - start_time) / 1000;
			}
		}
	
		else if (my_state == genState.propagate)
		{
			var _changed = false;
			WFC_reset_visited();
			
			for (var _cur_cell_x=0; _cur_cell_x<tilemap_width; _cur_cell_x++)
			{
				for (var _cur_cell_y=0; _cur_cell_y<tilemap_height; _cur_cell_y++)
				{
					var _cur_cell = tilemap_grid[# _cur_cell_x, _cur_cell_y];
			
					if (ds_list_size(_cur_cell) == 0)
					{
						show_message_async("Error: Cell (" + string(_cur_cell_x) + ", " + string(_cur_cell_y) + ") has no possible state.");
						error_x = _cur_cell_x;
						error_y = _cur_cell_y;
						my_state = genState.idle;
						
						// Try to add any outstanding tiles
						for (var i=0; i<tilemap_height; i++)
						{
							for (var j=0; j<tilemap_width; j++)
							{
								if (!tiled[ j, i])
								{
									var _cell = tilemap_grid[# j, i];
									if (ds_list_size(_cell) == 1)
									{
										var _data = tilemap_get(tilemap_layer, j, i);
										var _base_tile = base_tile_index[_cell[| 0]];
										var _transforms = base_tile_symmetry[_cell[| 0]];
								
										_data = tile_set_index(_data,_base_tile+tile_index_offset);
										_data = tile_set_mirror(_data,_transforms & 1);
										_data = tile_set_flip(_data,_transforms & 2);
										_data = tile_set_rotate(_data,_transforms & 4);
										tilemap_set(tilemap_layer, _data, j, i);
										tiled[ j, i] = true;
									}
								}
							}
						}
						
						exit;
					}
						
					if (ds_list_size(_cur_cell) > 1)
					{
						// Check neighbour constraints
						for (var i=0; i<ds_list_size(_cur_cell); i++)
						{
							var _cur_tile = _cur_cell[| i];
							var _cur_constraints = tile_constraints[| _cur_tile];
							var _ok;
			
							var _cur_tile_constraint, _cur_tile_edge_ids, _cur_tile_edge,
								_neighbour_cell, _neighbour_tile, _neighbour_constraints,
								_neighbour_tile_constraint, _neighbour_tile_edge_ids, _neighbour_tile_edge;
							
							var _tile_deleted = false;
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
										ds_list_delete(_cur_cell, i);
										i--;
										entropy--;
										_tile_deleted = true;
										_changed = true;					
										_cell_changed = true;
							
										if (async_mode && realtime_tiling && ds_list_size(_cur_cell) == 1)
											ds_queue_enqueue(finished_tiles_queue, [_cur_cell_x, _cur_cell_y]);
										
										break;
									}
								}
							}
							
							visited[_cur_cell_x, _cur_cell_y] = _cell_changed;
						}
					}
				}
			}
			
			if (!_changed)
				my_state = genState.collapse
		}
		
		if (async_mode)
		{
			process_time += current_time - _step_start_time;
	
			if (process_time >= step_max_time)
				_time_up = true;
		}
	}
}
if (my_state != genState.idle)
{
	var _time_up = false;
	var _step_start_time = 0;
	process_time = 0;
		
	while (!_time_up)
	{
		_step_start_time = current_time;
		
		if (my_state == genState.observe)
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

				// Observe 
				var _cell_len, _chosen_index;
				var _changed = true;
				
				while (_changed)
				{
					_cell_len = ds_list_size(_cur_cell);
					_chosen_index = WFC_weighted_irandom(_cur_cell,_cell_len);
				
					if (_chosen_index >= _cell_len)
					{
						show_message_async("Error: tile index out of range.");
						my_state = genState.idle;
						exit;
					}
				
					_changed = WFC_neighbour_checker_single(_cur_cell,_chosen_index,_cur_cell_x,_cur_cell_y);
				}
				
				entropy -= (_cell_len - 1);
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
			var _cur_cell_x = wave_x;
			var _cur_cell_y = wave_y;
			
			if (_cur_cell_x == 0 && _cur_cell_y == 0)
			{
				changed = false;
				WFC_reset_visited();
			}
			
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
				WFC_neighbour_checker(_cur_cell, _cur_cell_x, _cur_cell_y);
			
			wave_x++;
			
			if (wave_x >= tilemap_width)
			{
				wave_y++;
				wave_x = 0;
				
				if (wave_y >= tilemap_height)
				{
					if (!changed)
						my_state = genState.observe;

					wave_x = 0;
					wave_y = 0;
				}
			}
			
			if (async_mode)
			{
				process_time += current_time - _step_start_time;
	
				if (process_time >= step_max_time)
					_time_up = true;
			}
		} // end else if (myState == propagate)
	} // end while !time_up
}
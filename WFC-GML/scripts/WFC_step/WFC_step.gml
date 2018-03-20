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

				// Up
				if (_cur_cell_y-1 >= 0)
				{
					ds_list_add(process_stack, (_cur_cell_x << 16) | (_cur_cell_y-1));
					stack_size++;
				}

				// Right
				if (_cur_cell_x+1 < tilemap_width)
				{
					ds_list_add(process_stack, ((_cur_cell_x+1) << 16) | _cur_cell_y);
					stack_size++;
				}
	
				// Down
				if (_cur_cell_y+1 < tilemap_height)
				{
					ds_list_add(process_stack, (_cur_cell_x << 16) | (_cur_cell_y+1));
					stack_size++;
				}

				// Left
				if (_cur_cell_x-1 >= 0)
				{
					ds_list_add(process_stack, ((_cur_cell_x-1) << 16) | _cur_cell_y);
					stack_size++;
				}
				
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
				{
					show_message_async("Error: Cannot generate tilemap with current tileset.");
				}
		
				my_state = genState.idle;
				_time_up = true;
				time_taken = (current_time - start_time) / 1000;
			}
		}
	
		else if (my_state == genState.propagate)
		{
			if (!ds_list_empty(process_stack))
			{
				stack_size--;
				var _cur_cell_data = process_stack[| stack_size];
				ds_list_delete(process_stack, stack_size);
				var _cur_cell_x = _cur_cell_data >> 16;
				var _cur_cell_y = _cur_cell_data - (_cur_cell_x << 16);
				var _cur_cell = tilemap_grid[# _cur_cell_x, _cur_cell_y];
			
				if (ds_list_size(_cur_cell) == 0)
				{
					show_message_async("Error: Cell (" + string(_cur_cell_x) + ", " + string(_cur_cell_y) + ") has no possible state.");
					error_x = _cur_cell_x;
					error_y = _cur_cell_y;
					my_state = genState.idle;
					exit;
				}
						
				if (!visited[_cur_cell_x, _cur_cell_y])
				{
					visited[_cur_cell_x, _cur_cell_y] = true;
				
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
							
							has_changed = false;
			
							// Up
							if (_cur_cell_y-1 >= 0)
							{
								_cur_tile_constraint = _cur_constraints[| 0];
								_cur_tile_edge_ids = tile_edge_ids[| _cur_tile];
								_cur_tile_edge = _cur_tile_edge_ids[| 0];
								_neighbour_cell = tilemap_grid[# _cur_cell_x, _cur_cell_y-1];
								_ok = false;
				
								for (var k=0; k<ds_list_size(_neighbour_cell); k++)
								{
									_neighbour_tile = _neighbour_cell[| k];
									_neighbour_tile_edge_ids = tile_edge_ids[| _neighbour_tile]
									_neighbour_tile_edge = _neighbour_tile_edge_ids[| 2];
									_neighbour_constraints = tile_constraints[| _neighbour_tile];
									_neighbour_tile_constraint = _neighbour_constraints[| 2];
				
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
									has_changed = true;
							
									WFC_reset_visited();
							
									if (async_mode && realtime_tiling && ds_list_size(_cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [_cur_cell_x, _cur_cell_y]);
								}
							}
			
							// Right
							if (!has_changed && _cur_cell_x+1 < tilemap_width)
							{
								_cur_tile_constraint = _cur_constraints[| 1];
								_cur_tile_edge_ids = tile_edge_ids[| _cur_tile];
								_cur_tile_edge = _cur_tile_edge_ids[| 1];
								_neighbour_cell = tilemap_grid[# _cur_cell_x+1, _cur_cell_y];
								_ok = false;
				
								for (var k=0; k<ds_list_size(_neighbour_cell); k++)
								{
									_neighbour_tile = _neighbour_cell[| k];
									_neighbour_tile_edge_ids = tile_edge_ids[| _neighbour_tile]
									_neighbour_tile_edge = _neighbour_tile_edge_ids[| 3];
									_neighbour_constraints = tile_constraints[| _neighbour_tile];
									_neighbour_tile_constraint = _neighbour_constraints[| 3];
				
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
									has_changed = true;			
							
									WFC_reset_visited();
							
									if (async_mode && realtime_tiling && ds_list_size(_cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [_cur_cell_x, _cur_cell_y]);
								}
							}
			
							// Down
							if (!has_changed && _cur_cell_y+1 < tilemap_height)
							{
								_cur_tile_constraint = _cur_constraints[| 2];
								_cur_tile_edge_ids = tile_edge_ids[| _cur_tile];
								_cur_tile_edge = _cur_tile_edge_ids[| 2];
								_neighbour_cell = tilemap_grid[# _cur_cell_x, _cur_cell_y+1];
								_ok = false;
				
								for (var k=0; k<ds_list_size(_neighbour_cell); k++)
								{
									_neighbour_tile = _neighbour_cell[| k];
									_neighbour_tile_edge_ids = tile_edge_ids[| _neighbour_tile]
									_neighbour_tile_edge = _neighbour_tile_edge_ids[| 0];
									_neighbour_constraints = tile_constraints[| _neighbour_tile];
									_neighbour_tile_constraint = _neighbour_constraints[| 0];
				
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
									has_changed = true;
							
									WFC_reset_visited();
																			
									if (async_mode && realtime_tiling && ds_list_size(_cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [_cur_cell_x, _cur_cell_y]);
								}
							}
			
							// Left
							if (!has_changed && _cur_cell_x-1 >= 0)
							{
								_cur_tile_constraint = _cur_constraints[| 3];
								_cur_tile_edge_ids = tile_edge_ids[| _cur_tile];
								_cur_tile_edge = _cur_tile_edge_ids[| 3];
								_neighbour_cell = tilemap_grid[# _cur_cell_x-1, _cur_cell_y];
								_ok = false;
				
								for (var k=0; k<ds_list_size(_neighbour_cell); k++)
								{
									_neighbour_tile = _neighbour_cell[| k];
									_neighbour_tile_edge_ids = tile_edge_ids[| _neighbour_tile]
									_neighbour_tile_edge = _neighbour_tile_edge_ids[| 1];
									_neighbour_constraints = tile_constraints[| _neighbour_tile];
									_neighbour_tile_constraint = _neighbour_constraints[| 1];

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
									has_changed = true;
							
									WFC_reset_visited();
																			
									if (async_mode && realtime_tiling && ds_list_size(_cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [_cur_cell_x, _cur_cell_y]);
								}
							}
						}
					}
					
					// Propagate further if the adjacent cell is:
					// - In bounds
					// - Has not been already visited
					// - Is not already in process_stack
			
					// Up
					if (_cur_cell_y-1 >= 0 && !visited[_cur_cell_x, _cur_cell_y-1] && 
						ds_list_find_index(process_stack, (_cur_cell_x << 16) | _cur_cell_y-1) == -1)
					{
						ds_list_add(process_stack, (_cur_cell_x << 16) | (_cur_cell_y-1));
						stack_size++;
					}

					// Right
					if (_cur_cell_x+1 < tilemap_width && !visited[_cur_cell_x+1, _cur_cell_y] && 
						ds_list_find_index(process_stack, ((_cur_cell_x+1) << 16) | _cur_cell_y) == -1)
					{
						ds_list_add(process_stack, ((_cur_cell_x+1) << 16 | _cur_cell_y));
						stack_size++;
					}
	
					// Down
					if (_cur_cell_y+1 < tilemap_height && !visited[_cur_cell_x, _cur_cell_y+1] && 
						ds_list_find_index(process_stack, (_cur_cell_x << 16) | (_cur_cell_y+1)) == -1)
					{
						ds_list_add(process_stack, (_cur_cell_x << 16) | (_cur_cell_y+1));
						stack_size++;
					}
				
					// Left
					if (_cur_cell_x-1 >= 0 && !visited[_cur_cell_x-1, _cur_cell_y] && 
						ds_list_find_index(process_stack, ((_cur_cell_x-1) << 16 + _cur_cell_y)) == -1)
					{
						ds_list_add(process_stack, ((_cur_cell_x-1) << 16) | _cur_cell_y);
						stack_size++;
					}
				}
			}
		
			else
				my_state = genState.collapse;
		}
		
		if (async_mode)
		{
			process_time += current_time - _step_start_time;
	
			if (process_time >= step_max_time)
				_time_up = true;
		}
	}
}
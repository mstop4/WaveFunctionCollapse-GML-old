if (my_state <> genState.idle)
{
	var time_up = false;
	var step_start_time = 0;
	process_time = 0;
		
	while (!time_up)
	{
		step_start_time = current_time;
		
		if (my_state == genState.collapse)
		{
			if (realtime_tiling)
			{
				while (!ds_queue_empty(finished_tiles_queue))
				{
					var cell_coords = ds_queue_dequeue(finished_tiles_queue);
					var data = tilemap_get(tilemap_layer, cell_coords[0], cell_coords[1]);
					var cell = tilemap_grid[# cell_coords[0], cell_coords[1]];
					var base_tile = base_tile_index[cell[| 0]];
					var transforms = base_tile_symmetry[cell[| 0]];
					data = tile_set_index(data,base_tile+tile_index_offset);
					data = tile_set_mirror(data,transforms & 1);
					data = tile_set_flip(data,transforms & 2);
					data = tile_set_rotate(data,transforms & 4);
					tilemap_set(tilemap_layer, data, cell_coords[0], cell_coords[1]);
				}
			}
		
			reset_visited();

			// Find cells with lowest entropy
			var cur_cell_data = pick_cell();
			var cur_cell = cur_cell_data[0];
			var cur_cell_x = cur_cell_data[1];
			var cur_cell_y = cur_cell_data[2];

			if (cur_cell <> -1)
			{
				visited[cur_cell_x, cur_cell_y] = true;

				// Collapse 
				var cell_len = ds_list_size(cur_cell);
				entropy -= (cell_len - 1);
				ds_list_shuffle(cur_cell);
				var selected_value = cur_cell[| 0];
				ds_list_clear(cur_cell);
				cur_cell[| 0] = selected_value;
			
				if (realtime_tiling)
					ds_queue_enqueue(finished_tiles_queue, [cur_cell_x, cur_cell_y]);
	
				// Propagate

				// Up
				if (cur_cell_y-1 >= 0)
				{
					ds_list_add(process_stack, (cur_cell_x << 16) | (cur_cell_y-1));
					stack_size++;
				}

				// Right
				if (cur_cell_x+1 < tilemap_width)
				{
					ds_list_add(process_stack, ((cur_cell_x+1) << 16) | cur_cell_y);
					stack_size++;
				}
	
				// Down
				if (cur_cell_y+1 < tilemap_height)
				{
					ds_list_add(process_stack, (cur_cell_x << 16) | (cur_cell_y+1));
					stack_size++;
				}

				// Left
				if (cur_cell_x-1 >= 0)
				{
					ds_list_add(process_stack, ((cur_cell_x-1) << 16) | cur_cell_y);
					stack_size++;
				}
				
				my_state = genState.propagate;
			}
		
			else
			{
				if (entropy == 0)
				{
					if (!realtime_tiling)
					{
						for (var i=0; i<tilemap_height; i++)
						{
							for (var j=0; j<tilemap_width; j++)
							{
								var data = tilemap_get(tilemap_layer, j, i);
								var cell = tilemap_grid[# j, i];
								data = tile_set_index(data,cell[| 0]+tile_index_offset);
								tilemap_set(tilemap_layer, data, j, i);
							}
						}
					}
				}
			
				else
				{
					show_message_async("Error: Something went wrong.");
				}
		
				my_state = genState.idle;
				time_taken = (current_time - start_time) / 1000;
			}
		}
	
		else if (my_state == genState.propagate)
		{
			if (!ds_list_empty(process_stack))
			{
				stack_size--;
				var cur_cell_data = process_stack[| stack_size];
				ds_list_delete(process_stack, stack_size);
				var cur_cell_x = cur_cell_data >> 16;
				var cur_cell_y = cur_cell_data - (cur_cell_x << 16);
				var cur_cell = tilemap_grid[# cur_cell_x, cur_cell_y];
			
				if (ds_list_size(cur_cell) == 0)
				{
					show_message_async("Something went wrong");
					my_state = genState.idle;
					exit;
				}
						
				if (!visited[cur_cell_x, cur_cell_y])
				{
					visited[cur_cell_x, cur_cell_y] = true;
				
					if (ds_list_size(cur_cell) > 1)
					{
						// Check neighbour constraints
						for (var i=0; i<ds_list_size(cur_cell); i++)
						{
							var cur_tile = cur_cell[| i];
							var cur_constraints = tile_constraints[| cur_tile];
							var ok;
			
							var cur_tile_constraint, neighbour_cell, neighbour_tile, neighbour_constraints,
								neighbour_tile_constraint, done;
							
							has_changed = false;
			
							// Up
							if (cur_cell_y-1 >= 0)
							{
								cur_tile_constraint = cur_constraints[| 0];
								neighbour_cell = tilemap_grid[# cur_cell_x, cur_cell_y-1];
								ok = false;
				
								for (var k=0; k<ds_list_size(neighbour_cell); k++)
								{
									neighbour_tile = neighbour_cell[| k];
									neighbour_constraints = tile_constraints[| neighbour_tile];
									neighbour_tile_constraint = neighbour_constraints[| 2];
				
									if (cur_tile_constraint == neighbour_tile_constraint)
									{
										ok = true;
										break;
									}
								}
					
								if (!ok)
								{
									ds_list_delete(cur_cell, i);
									i--;
									entropy--;
									has_changed = true;
							
									reset_visited();
							
									if (realtime_tiling && ds_list_size(cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [cur_cell_x, cur_cell_y]);
								}
							}
			
							// Right
							if (cur_cell_x+1 < tilemap_width && !has_changed)
							{
								cur_tile_constraint = cur_constraints[| 1];
								neighbour_cell = tilemap_grid[# cur_cell_x+1, cur_cell_y];
								ok = false;
				
								for (var k=0; k<ds_list_size(neighbour_cell); k++)
								{
									neighbour_tile = neighbour_cell[| k];
									neighbour_constraints = tile_constraints[| neighbour_tile];
									neighbour_tile_constraint = neighbour_constraints[| 3];
				
									if (cur_tile_constraint == neighbour_tile_constraint)
									{
										ok = true;
										break;
									}
								}
					
								if (!ok)
								{
									ds_list_delete(cur_cell, i);
									i--;
									entropy--;
									has_changed = true;			
							
									reset_visited();
							
									if (realtime_tiling && ds_list_size(cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [cur_cell_x, cur_cell_y]);
								}
							}
			
							// Down
							if (cur_cell_y+1 < tilemap_height && !has_changed)
							{
								cur_tile_constraint = cur_constraints[| 2];
								neighbour_cell = tilemap_grid[# cur_cell_x, cur_cell_y+1];
								ok = false;
				
								for (var k=0; k<ds_list_size(neighbour_cell); k++)
								{
									neighbour_tile = neighbour_cell[| k];
									neighbour_constraints = tile_constraints[| neighbour_tile];
									neighbour_tile_constraint = neighbour_constraints[| 0];
				
									if (cur_tile_constraint == neighbour_tile_constraint)
									{
										ok = true;
										break;
									}
								}
					
								if (!ok)
								{
									ds_list_delete(cur_cell, i);
									i--;
									entropy--;
									has_changed = true;
							
									reset_visited();
																			
									if (realtime_tiling && ds_list_size(cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [cur_cell_x, cur_cell_y]);
								}
							}
			
							// Left
							if (cur_cell_x-1 >= 0 && !has_changed)
							{
								cur_tile_constraint = cur_constraints[| 3];
								neighbour_cell = tilemap_grid[# cur_cell_x-1, cur_cell_y];
								ok = false;
				
								for (var k=0; k<ds_list_size(neighbour_cell); k++)
								{
									neighbour_tile = neighbour_cell[| k];
									neighbour_constraints = tile_constraints[| neighbour_tile];
									neighbour_tile_constraint = neighbour_constraints[| 1];

									if (cur_tile_constraint == neighbour_tile_constraint)
									{
										ok = true;
										break;
									}
								}
					
								if (!ok)
								{
									ds_list_delete(cur_cell, i);
									i--;
									entropy--;
									has_changed = true;
							
									reset_visited();
																			
									if (realtime_tiling && ds_list_size(cur_cell) == 1)
										ds_queue_enqueue(finished_tiles_queue, [cur_cell_x, cur_cell_y]);
								}
							}
						}
					}
			
					// Up
					if (cur_cell_y-1 >= 0 && !visited[cur_cell_x, cur_cell_y-1] && 
						ds_list_find_index(process_stack, (cur_cell_x << 16) | cur_cell_y-1) == -1)
					{
						ds_list_add(process_stack, (cur_cell_x << 16) | (cur_cell_y-1));
						stack_size++;
					}

					// Right
					if (cur_cell_x+1 < tilemap_width && !visited[cur_cell_x+1, cur_cell_y] && 
						ds_list_find_index(process_stack, ((cur_cell_x+1) << 16) | cur_cell_y) == -1)
					{
						ds_list_add(process_stack, ((cur_cell_x+1) << 16 | cur_cell_y));
						stack_size++;
					}
	
					// Down
					if (cur_cell_y+1 < tilemap_height && !visited[cur_cell_x, cur_cell_y+1] && 
						ds_list_find_index(process_stack, (cur_cell_x << 16) | (cur_cell_y+1)) == -1)
					{
						ds_list_add(process_stack, (cur_cell_x << 16) | (cur_cell_y+1));
						stack_size++;
					}
				
					// Left
					if (cur_cell_x-1 >= 0 && !visited[cur_cell_x-1, cur_cell_y] && 
						ds_list_find_index(process_stack, ((cur_cell_x-1) << 16 + cur_cell_y)) == -1)
					{
						ds_list_add(process_stack, ((cur_cell_x-1) << 16) | cur_cell_y);
						stack_size++;
					}
				}
			}
		
			else
				my_state = genState.collapse;
		}
		
	process_time += current_time - step_start_time;
	
	if (process_time >= step_max_time)
		time_up = true;
		
	}
}
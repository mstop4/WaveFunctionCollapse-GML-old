if (my_state <> genState.idle)
{
	if (my_state == genState.collapse)
	{
		for (var i=0; i<tilemap_height; i++)
		{
			for (var j=0; j<tilemap_width; j++)
				visited[j,i] = false;
		}

		// Find cells with lowest entropy
		var cur_cell_data = pick_cell();
		var cur_cell = cur_cell_data[0];
		var cur_cell_x = cur_cell_data[1];
		var cur_cell_y = cur_cell_data[2];

		if (cur_cell <> -1)
		{
			visited[cur_cell_x, cur_cell_y] = true;

			// Collapse 
			
			// Eliminate invalid tile choices
			for (var i=0; i<ds_list_size(cur_cell); i++)
			{
				var cur_tile = cur_cell[| i];
				var cur_constraints = tile_constraints[| cur_tile];
				var ok;
			
				var cur_tile_constraint, neighbour_cell, neighbour_tile, neighbour_constraints,
					neighbour_tile_constraint, done;
			
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
						inv_progress--;
						continue;
					}
				}
			
				// Right
				if (cur_cell_x+1 < tilemap_width)
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
						inv_progress--;
						continue;
					}
				}
			
				// Down
				if (cur_cell_y+1 < tilemap_height)
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
						inv_progress--;
						continue;
					}
				}
			
				// Left
				if (cur_cell_x-1 >= 0)
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
						inv_progress--;
						continue;
					}
				}
			}
			
			var cell_len = ds_list_size(cur_cell);
			inv_progress -= (cell_len - 1);
			ds_list_shuffle(cur_cell);
			var selected_value = cur_cell[| 0];
			ds_list_clear(cur_cell);
			cur_cell[| 0] = selected_value;
	
			// Propagate

			// Up
			if (cur_cell_y-1 >= 0 && !visited[cur_cell_x, cur_cell_y-1])
				ds_stack_push(process_stack, [cur_cell_x, cur_cell_y-1]);

			// Right
			if (cur_cell_x+1 < tilemap_width && !visited[cur_cell_x+1, cur_cell_y])
				ds_stack_push(process_stack, [cur_cell_x+1, cur_cell_y]);
	
			// Down
			if (cur_cell_y+1 < tilemap_height && !visited[cur_cell_x, cur_cell_y+1])
				ds_stack_push(process_stack, [cur_cell_x, cur_cell_y+1]);

			// Left
			if (cur_cell_x-1 >= 0 && !visited[cur_cell_x-1, cur_cell_y])
				ds_stack_push(process_stack, [cur_cell_x-1, cur_cell_y]);
				
			my_state = genState.propagate;
		}
		
		else
		{
			if (inv_progress == 0)
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
			
			else
			{
				show_message_async("Error: Something went wrong.");
			}
		
			my_state = genState.idle;
			time_taken = current_time - start_time;
		}
	}
	
	else if (my_state == genState.propagate)
	{
		if (!ds_stack_empty(process_stack))
		{
			var cur_cell_data = ds_stack_pop(process_stack);
			var cur_cell_x = cur_cell_data[0];
			var cur_cell_y = cur_cell_data[1];
			var cur_cell = tilemap_grid[# cur_cell_x, cur_cell_y];
	
			visited[cur_cell_x, cur_cell_y] = true;
	
			// Check neighbour constraints
			for (var i=0; i<ds_list_size(cur_cell); i++)
			{
				var cur_tile = cur_cell[| i];
				var cur_constraints = tile_constraints[| cur_tile];
				var ok;
			
				var cur_tile_constraint, neighbour_cell, neighbour_tile, neighbour_constraints,
					neighbour_tile_constraint, done;
			
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
						inv_progress--;
						continue;
					}
				}
			
				// Right
				if (cur_cell_x+1 < tilemap_width)
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
						inv_progress--;
						continue;
					}
				}
			
				// Down
				if (cur_cell_y+1 < tilemap_height)
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
						inv_progress--;
						continue;
					}
				}
			
				// Left
				if (cur_cell_x-1 >= 0)
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
						inv_progress--;
						continue;
					}
				}
			}
		
			// Up
			if (cur_cell_y-1 >= 0 && !visited[cur_cell_x, cur_cell_y-1])
				ds_stack_push(process_stack, [cur_cell_x, cur_cell_y-1]);

			// Right
			if (cur_cell_x+1 < tilemap_width && !visited[cur_cell_x+1, cur_cell_y])
				ds_stack_push(process_stack, [cur_cell_x+1, cur_cell_y]);
	
			// Down
			if (cur_cell_y+1 < tilemap_height && !visited[cur_cell_x, cur_cell_y+1])
				ds_stack_push(process_stack, [cur_cell_x, cur_cell_y+1]);

			// Left
			if (cur_cell_x-1 >= 0 && !visited[cur_cell_x-1, cur_cell_y])
				ds_stack_push(process_stack, [cur_cell_x-1, cur_cell_y]);
		}
		
		else
			my_state = genState.collapse;
	}
}
var visited;

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
	ds_list_shuffle(cur_cell);
	var selected_value = cur_cell[| 0];
	ds_list_clear(cur_cell);
	cur_cell[| 0] = selected_value;

	print_log(cur_cell[| 0], ", ", cur_cell_x, ", ", cur_cell_y);
	
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
		
	var count = 0;
	
	while (!ds_stack_empty(process_stack))
	{
		print_log("Doing something: ", count);
		count++;
		
		cur_cell_data = ds_stack_pop(process_stack);
		cur_cell_x = cur_cell_data[0];
		cur_cell_y = cur_cell_data[1];
		cur_cell = tilemap_grid[# cur_cell_x, cur_cell_y];
	
		visited[cur_cell_x, cur_cell_y] = true;
	
		// Check neighbour constraints
		for (var i=0; i<ds_list_size(cur_cell); i++)
		{
			var cur_tile = cur_cell[| i];
			var cur_constraints = tile_constraints[| cur_tile];
			var ok = false;
			
			var cur_tile_constraint, neighbour_cell, neighbour_tile, neighbour_constraints,
				neighbour_tile_constraint, done;
			
			// Up
			if (cur_cell_y-1 >= 0)
			{
				cur_tile_constraint = cur_constraints[| 0];
				neighbour_cell = tilemap_grid[# cur_cell_x, cur_cell_y-1];
				
				for (var k=0; k<ds_list_size(neighbour_cell); k++)
				{
					neighbour_tile = neighbour_cell[| k];
					neighbour_constraints = tile_constraints[| neighbour_tile];
					neighbour_tile_constraint = neighbour_constraints[| 2];
					done = false;
				
					for (var j=0; j<ds_list_size(cur_tile_constraint); j++)
					{
						if (ds_list_find_index(neighbour_tile_constraint,cur_tile_constraint[| j]))
						{
							ok = true;
							done = true;
							break;
						}
					}
					
					if (done)
						break;
				}
			}
			
			// Right
			if (cur_cell_x+1 < tilemap_width)
			{
				cur_tile_constraint = cur_constraints[| 1];
				neighbour_cell = tilemap_grid[# cur_cell_x+1, cur_cell_y];
				
				for (var k=0; k<ds_list_size(neighbour_cell); k++)
				{
					neighbour_tile = neighbour_cell[| k];
					neighbour_constraints = tile_constraints[| neighbour_tile];
					neighbour_tile_constraint = neighbour_constraints[| 3];
					done = false;
				
					for (var j=0; j<ds_list_size(cur_tile_constraint); j++)
					{
						if (ds_list_find_index(neighbour_tile_constraint,cur_tile_constraint[| j]))
						{
							ok = true;
							done = true;
							break;
						}
					}
					
					if (done)
						break;
				}
			}
			
			// Down
			if (cur_cell_y+1 < tilemap_height)
			{
				cur_tile_constraint = cur_constraints[| 2];
				neighbour_cell = tilemap_grid[# cur_cell_x, cur_cell_y+1];
				
				for (var k=0; k<ds_list_size(neighbour_cell); k++)
				{
					neighbour_tile = neighbour_cell[| k];
					neighbour_constraints = tile_constraints[| neighbour_tile];
					neighbour_tile_constraint = neighbour_constraints[| 0];
					done = false;
				
					for (var j=0; j<ds_list_size(cur_tile_constraint); j++)
					{
						if (ds_list_find_index(neighbour_tile_constraint,cur_tile_constraint[| j]))
						{
							ok = true;
							done = true;
							break;
						}
					}
					
					if (done)
						break;
				}
			}
			
			// Left
			if (cur_cell_x-1 >= 0)
			{
				cur_tile_constraint = cur_constraints[| 3];
				neighbour_cell = tilemap_grid[# cur_cell_x-1, cur_cell_y];
				
				for (var k=0; k<ds_list_size(neighbour_cell); k++)
				{
					neighbour_tile = neighbour_cell[| k];
					neighbour_constraints = tile_constraints[| neighbour_tile];
					neighbour_tile_constraint = neighbour_constraints[| 1];
					done = false;
				
					for (var j=0; j<ds_list_size(cur_tile_constraint); j++)
					{
						if (ds_list_find_index(neighbour_tile_constraint,cur_tile_constraint[| j]))
						{
							ok = true;
							done = true;
							break;
						}
					}
					
					if (done)
						break;
				}
			}
			
			if (!ok)
				ds_list_delete(cur_cell, i);
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
}

else
	print_log("Done!");
	
print_log("i'm Out");
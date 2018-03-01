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

visited[cur_cell_x, cur_cell_y] = true;

// Collapse 
ds_list_shuffle(cur_cell);
var selected_value = cur_cell[| 0];
ds_list_empty(cur_cell);
cur_cell[| 0] = selected_value;

print_log(cur_cell[| 0], ", ", cur_cell_x, ", ", cur_cell_y);

// Propagate

// Up
/*if (cur_cell_y-1 >= 0 && !visited[cur_cell_x][cur_cell_y-1])
	ds_stack_push(process_stack, [cur_cell_x, cur_cell_y-1]);

// Right
if (cur_cell_x+1 < tilemap_width && !visited[cur_cell_x+1][cur_cell_y])
	ds_stack_push(process_stack, [cur_cell_x+1, cur_cell_y]);
	
// Down
if (cur_cell_y+1 < tilemap_height && !visited[cur_cell_x][cur_cell_y+1])
	ds_stack_push(process_stack, [cur_cell_x, cur_cell_y+1]);

// Left
if (cur_cell_x-1 >= 0 && !visited[cur_cell_x-1][cur_cell_y])
	ds_stack_push(process_stack, [cur_cell_x-1, cur_cell_y]);
	
while (!ds_stack_empty(process_stack))
{
	cur_cell_data = ds_stack_pop(process_stack);
	cur_cell_x = cur_cell_data[0];
	cur_cell_y = cur_cell_data[1];
	cur_cell = tilemap_grid[cur_cell_x][cur_cell_y];
	
	visited[cur_cell_x][cur_cell_y] = true;
	
	// Check neighbour constraints
	var neighbour_cell;
	
	
	// Up
	if (cur_cell_y-1 >= 0)
	{
		neighbour_cell = tilemap_grid[# cur_cell_x, cur_cell_y-1];
		for (var i=0; i<ds_list_size(
	}

	// Right
	if (cur_cell_x+1 < tilemap_width && !visited[cur_cell_x+1][cur_cell_y])
		ds_stack_push(process_stack, [cur_cell_x+1, cur_cell_y]);
	
	// Down
	if (cur_cell_y+1 < tilemap_height && !visited[cur_cell_x][cur_cell_y+1])
		ds_stack_push(process_stack, [cur_cell_x, cur_cell_y+1]);

	// Left
	if (cur_cell_x-1 >= 0 && !visited[cur_cell_x-1][cur_cell_y])
		ds_stack_push(process_stack, [cur_cell_x-1, cur_cell_y]);
}*/
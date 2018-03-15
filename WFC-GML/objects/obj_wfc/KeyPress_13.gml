entropy = 0;
start_time = current_time;
ds_list_clear(process_stack);
stack_size = 0;
ds_queue_clear(finished_tiles_queue);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
	{
		var cur_list = tilemap_grid[# j, i];
		ds_list_clear(cur_list);
	
		for (var k=0; k<num_tiles; k++)
		{
			ds_list_add(cur_list, k);
			entropy++;
		}
	}
}

tilemap_clear(tilemap_layer,0);

entropy -= tilemap_width*tilemap_height;
max_entropy = entropy;
my_state  = genState.collapse;
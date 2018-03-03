inv_progress = 0;
start_time = current_time;
ds_stack_clear(process_stack);
ds_queue_clear(finished_tiles_queue);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
	{
		var cur_list = tilemap_grid[# j, i];
	
		for (var k=0; k<num_tiles; k++)
		{
			cur_list[| k] = k;
			inv_progress++;
		}
	}
}

tilemap_clear(tilemap_layer,0);

inv_progress -= tilemap_width*tilemap_height;
my_state  = genState.collapse;
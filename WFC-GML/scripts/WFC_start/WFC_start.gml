start_time = current_time;
entropy = 0;
error_x = -1;
error_y = -1;
wave_x = 0;
wave_y = 0;
changed = false;

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
WFC_reset_tiled();

entropy -= tilemap_width*tilemap_height;
max_entropy = entropy;
my_state  = genState.observe;
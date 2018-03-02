inv_progress = 0;

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

inv_progress -= tilemap_width*tilemap_height;
my_state  = genState.collapse;
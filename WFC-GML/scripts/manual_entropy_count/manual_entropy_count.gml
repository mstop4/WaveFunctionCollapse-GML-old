elephant = 0;
for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
	{
		var cur_list = tilemap_grid[# j, i];
		elephant += ds_list_size(cur_list);
	}
}
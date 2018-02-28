for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
	{
		var cur_list = tilemap_grid[# j, i];
		var str = "";
		
		for (var k=0; k<num_tiles; k++)
			str += string(cur_list[| k]) + ", ";
			
		show_debug_message(str);
	}
}
process_stack = ds_stack_create();

// Get tile constraints
tile_constraints = -1;
json_map = -1;
num_tiles = 0;

var file = file_text_open_read("16-tile.json");

if (file)
{
	var json = file_text_read_string(file);
	json_map = json_decode(json);
	
	if (json_map > -1)
	{
		show_debug_message("Success");
		tile_constraints = json_map[? "default"];
		num_tiles = ds_list_size(tile_constraints);
	}
}

file_text_close(file);

// Init tilemap
tilemap_grid = ds_grid_create(tilemap_width, tilemap_height);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
	{
		tilemap_grid[# j, i] = ds_list_create();
		var cur_list = tilemap_grid[# j, i];
		
		for (var k=0; k<num_tiles; k++)
			cur_list[| k] = k;
	}
}
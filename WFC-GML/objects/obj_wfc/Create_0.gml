//randomize();

process_stack = ds_stack_create();
finished_tiles_queue = ds_queue_create();
tile_layer = layer_create(-1000);
tilemap_layer = layer_tilemap_create(tile_layer,0,0,tile_set,tilemap_width,tilemap_height);
is_generating = false;
dirty = false;
restart_x = -1;
restart_y = -1;
my_state = genState.idle;
visited = -1;
inv_progress = 0;
time_taken = -1;
start_time = -1;

// Get tile constraints
tile_constraints = -1;
json_map = -1;
num_tiles = 0;

var file = file_text_open_read(constraints_file);

if (file)
{
	var json = file_text_read_string(file);
	json_map = json_decode(json);
	
	if (json_map > -1)
	{
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
		tilemap_grid[# j, i] = ds_list_create();
}
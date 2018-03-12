randomize();

process_stack = ds_list_create();
stack_size = 0;
finished_tiles_queue = ds_queue_create();
tile_layer = layer_create(-1000);
tilemap_layer = layer_tilemap_create(tile_layer,0,0,tile_set,tilemap_width,tilemap_height);
visited = -1;
my_state = genState.idle;
entropy = 0;
has_changed = false;
time_taken = -1;
start_time = -1;

// Get tile constraints
tile_constraints = -1;
json_map = -1;
num_tiles = 0;
clude_tiles = ds_list_create();

ds_list_add(clude_tiles, 3, 6, 9, 12);

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
tilemap_grid = ds_grid_create(tilemap_width, tilemap_width);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
		tilemap_grid[# j, i] = ds_list_create();
}
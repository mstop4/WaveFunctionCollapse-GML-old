process_time = 0;
step_max_time = 1000 / room_speed;

finished_tiles_queue = ds_queue_create();
visited = -1;
tiled = -1;

wave_x = 0;
wave_y = 0;
changed = false;
my_state = genState.idle;
entropy = 1;
max_entropy = 1;
time_taken = -1;
start_time = -1;
error_x = -1;
error_y = -1;

// Get tileset data
tile_edge_ids = -1;
tile_constraints = -1;
num_tiles = 0;
base_tile_index[0] = 0;
base_tile_symmetry[0] = 0;
base_tile_weight[0] = 0;

symmetries_json = -1;
constraints_json = -1;
weights_json = -1;
WFC_load_tileset_data(symmetries_file,constraints_file,weights_file);

// Init tilemap
tilemap_grid = ds_grid_create(tilemap_width, tilemap_width);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
		tilemap_grid[# j, i] = ds_list_create();
}
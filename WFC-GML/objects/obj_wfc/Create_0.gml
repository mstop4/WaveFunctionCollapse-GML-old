randomize();

process_stack = ds_list_create();
stack_size = 0;

process_time = 0;
step_max_time = 1000 / room_speed;

//tilemap_width = room_width div 32;
//tilemap_height = room_height div 32;

finished_tiles_queue = ds_queue_create();
tile_layer = layer_create(50);
tilemap_layer = layer_tilemap_create(tile_layer,0,0,tile_set,tilemap_width,tilemap_height);
visited = -1;
tiled = -1;

my_state = genState.idle;
entropy = 1;
max_entropy = 1;
has_changed = false;
time_taken = -1;
start_time = -1;

// Get tile constraints
tile_constraints = -1;
num_tiles = 0;
base_tile_index[0] = 0;
base_tile_symmetry[0] = 0;
tile_filter = ds_list_create();
ds_list_add(tile_filter, 3);

load_constraints(symmetries_file,constraints_file);

// Init tilemap
tilemap_grid = ds_grid_create(tilemap_width, tilemap_width);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
		tilemap_grid[# j, i] = ds_list_create();
}
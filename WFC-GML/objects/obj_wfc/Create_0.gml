randomize();

process_stack = ds_list_create();
stack_size = 0;

process_time = 0;
step_max_time = 1000 / room_speed;

finished_tiles_queue = ds_queue_create();
tile_layer = layer_create(-1000);
tilemap_layer = layer_tilemap_create(tile_layer,0,0,tile_set,tilemap_width,tilemap_height);
visited = -1;
my_state = genState.idle;
entropy = 1;
max_entropy = 1;
has_changed = false;
time_taken = -1;
start_time = -1;
json_map = -1;

// Get tile constraints
tile_constraints = -1;
num_tiles = 0;
clude_tiles = ds_list_create();
//ds_list_add(clude_tiles, 3, 5, 6, 9, 12);

load_constraints();

// Init tilemap
tilemap_grid = ds_grid_create(tilemap_width, tilemap_width);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
		tilemap_grid[# j, i] = ds_list_create();
}
if (ds_exists(tile_constraints, ds_type_list))
	ds_list_destroy(tile_constraints);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
		ds_list_destroy(tilemap_grid[# j, i]);
}

ds_grid_destroy(tilemap_grid);
ds_list_destroy(process_stack);
ds_queue_destroy(finished_tiles_queue);
ds_map_destroy(json_map);
ds_list_destroy(clude_tiles);
layer_destroy(tile_layer);
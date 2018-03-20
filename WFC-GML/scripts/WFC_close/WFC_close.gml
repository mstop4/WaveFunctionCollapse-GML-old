if (ds_exists(tile_constraints, ds_type_list))
	ds_list_destroy(tile_constraints);
	
if (ds_exists(tile_edge_ids, ds_type_list))
	ds_list_destroy(tile_edge_ids);
	
if (ds_exists(symmetries_json, ds_type_map))
	ds_map_destroy(symmetries_json);
	
if (ds_exists(constraints_json, ds_type_list))
	ds_map_destroy(constraints_json);
	
if (ds_exists(weights_json, ds_type_list))
	ds_map_destroy(weights_json);

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
		ds_list_destroy(tilemap_grid[# j, i]);
}

ds_grid_destroy(tilemap_grid);
ds_list_destroy(process_stack);
ds_queue_destroy(finished_tiles_queue);
ds_list_destroy(tile_filter);
layer_destroy(tile_layer);
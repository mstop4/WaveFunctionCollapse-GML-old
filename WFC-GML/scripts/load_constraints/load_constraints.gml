var file = file_text_open_read(constraints_file);
var json_map;

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
ds_map_destroy(json_map);
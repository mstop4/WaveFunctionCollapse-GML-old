tile_constraints = -1;
json_map = -1;

var file = file_text_open_read("16-tile.json");

if (file)
{
	var json = file_text_read_string(file);
	json_map = json_decode(json);
	
	if (json_map > -1)
	{
		show_debug_message("Success");
		tile_constraints = json_map[? "default"];
	}
}

file_text_close(file);
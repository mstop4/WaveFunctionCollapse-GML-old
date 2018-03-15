var tile_index = real(string_digits(keyboard_lastchar));

if (tile_index >= 0 && tile_index < 8)
{
	for (var i=0; i<tilemap_width; i++)
	{
		for (var j=0; j<tilemap_height; j++)
		{
			var data = tilemap_get(tilemap_layer, i, j);
			data = tile_set_index(data,tile_index);
			data = tile_set_mirror(data,i&1);
			data = tile_set_flip(data,i&2);
			data = tile_set_rotate(data,j);
			tilemap_set(tilemap_layer, data, i, j);
		}
	}
}
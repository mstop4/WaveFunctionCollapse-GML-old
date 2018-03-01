/// @function     pick_cell()
/// @description  Pick a random cell with the lowest entropy > 1

var lowest_entropy = num_tiles;
var lowest_cells = ds_list_create();
var return_value;

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
	{
		var entropy = ds_list_size(tilemap_grid[# j, i]);
		
		if (entropy <= lowest_entropy && entropy > 1)
		{
			if (entropy < lowest_entropy)
			{
				ds_list_clear(lowest_cells);
				lowest_entropy = entropy;
			}
			
			ds_list_add(lowest_cells, [ tilemap_grid[# j, i], j, i ]);
		}
	}
}

if (!ds_list_empty(lowest_cells))
{
	ds_list_shuffle(lowest_cells);
	return_value = lowest_cells[| 0];
}

else
	return_value = [ -1, -1, -1 ];

ds_list_destroy(lowest_cells);
return return_value;
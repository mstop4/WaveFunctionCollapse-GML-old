/// @function     WFC_pick_cell()
/// @description  Pick a random cell with the lowest _entropy > 1

var _lowest_entropy = num_tiles;
var _lowest_cells = ds_list_create();
var _return_value;

for (var i=0; i<tilemap_height; i++)
{
	for (var j=0; j<tilemap_width; j++)
	{
		var _entropy = ds_list_size(tilemap_grid[# j, i]);
		
		if (_entropy <= _lowest_entropy && _entropy > 1)
		{
			if (_entropy < _lowest_entropy)
			{
				ds_list_clear(_lowest_cells);
				_lowest_entropy = _entropy;
			}
			
			ds_list_add(_lowest_cells, [ tilemap_grid[# j, i], j, i ]);
		}
	}
}

if (!ds_list_empty(_lowest_cells))
{
	var _lowest_cells_len = ds_list_size(_lowest_cells);
	_return_value = _lowest_cells[| irandom(_lowest_cells_len-1)];
}

else
	_return_value = [ -1, -1, -1 ];

ds_list_destroy(_lowest_cells);
return _return_value;
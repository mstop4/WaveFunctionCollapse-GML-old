/// @function  WFC_weighted_irandom(cur_cell, max)
/// @param     cur_cell 
/// @param     max      

var _cur_cell = argument[0];
var _max = argument[1];

var _sum_weights = 0;
var _result = -1;

for (var i=0; i<_max; i++)
	_sum_weights += base_tile_weight[_cur_cell[| i]];
					
var _r = random(_sum_weights);
var _running_weight = 0;
				
do
{
	_result++;
	_running_weight += base_tile_weight[_cur_cell[| _result]];
} 
until (_r <= _running_weight)

return _result;
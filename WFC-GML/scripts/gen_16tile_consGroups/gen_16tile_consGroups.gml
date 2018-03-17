var str = "[\n";

// i j
// k l

for (var l=0; l<2; l++)
{
	for (var k=0; k<2; k++)
	{
		for (var j=0; j<2; j++)
		{
			for (var i=0; i<2; i++)
			{
				str += "\t{\n";
				// tile id
				str += "\t\t\"tileId\": " + string(l*8 + k*4 + j*2 + i) + ",\n";
				// up
				str += "\t\t\"upId\": " + string(j*2 + i) + ",\n";
				// right
				str += "\t\t\"rightId\": " + string(l*2 + j) + ",\n";
				// down
				str += "\t\t\"downId\": " + string(l*2 + k) + ",\n";
				// left
				str += "\t\t\"leftId\": " + string(k*2 + i) + ",\n";
				str += "\t\t\"symmetry\": \"X\"\n";
				str += "\t},\n";
			}
		}
	}
}

str = string_delete(str,string_length(str)-1,2);
str += "\n]";

return str;
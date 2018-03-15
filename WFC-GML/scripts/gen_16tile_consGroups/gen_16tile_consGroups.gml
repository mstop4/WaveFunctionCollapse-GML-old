var str = "[";

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
				str += "[";
				// up
				str += string(j*2 + i) + ",";
				// right
				str += string(l*2 + j) + ",";
				// down
				str += string(l*2 + k) + ",";
				// left
				str += string(k*2 + i);
				str += ",\"X\"],";
			}
		}
	}
}

str = string_delete(str,string_length(str),1);
str += "]";

return str;
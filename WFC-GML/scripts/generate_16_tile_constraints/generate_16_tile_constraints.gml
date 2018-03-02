var str = "[";

// i j
// k l

for (var i=1; i>-1; i--)
{
	for (var j=1; j>-1; j--)
	{
		for (var k=1; k>-1; k--)
		{
			for (var l=1; l>-1; l--)
			{
				str += "[";
				// up
				str += string(j*2 + i) + ", ";
				// right
				str += string(l*2 + j) + ", ";
				// down
				str += string(l*2 + k) + ", ";
				// left
				str += string(k*2 + i);
				str += "],";
			}
		}
	}
}

str = string_delete(str,string_length(str),1);
str += "]";

return str;
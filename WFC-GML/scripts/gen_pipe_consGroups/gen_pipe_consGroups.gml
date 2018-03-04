var str = "[";

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
				str += string(i) + ", ";
				// right
				str += string(j) + ", ";
				// down
				str += string(k) + ", ";
				// left
				str += string(l);
				str += "],";
			}
		}
	}
}

str = string_delete(str,string_length(str),1);
str += "]";

return str;
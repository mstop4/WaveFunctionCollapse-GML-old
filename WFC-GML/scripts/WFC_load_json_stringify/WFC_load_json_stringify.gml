var _filename = argument[0];

var _file = file_text_open_read(_filename);

if (_file != -1)
{
	var _json = "";
	
	while (!file_text_eof(_file))
		_json += file_text_readln(_file);
		
	_json = string_replace_all(_json," ","");		// spaces
	_json = string_replace_all(_json,"\t","");		// tabs
	_json = string_replace_all(_json,"\r","");		// returns
	_json = string_replace_all(_json,"\n","");		// newlines
		
	file_text_close(_file);
	
	return _json;
}

else
	return "";
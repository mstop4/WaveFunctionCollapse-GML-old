var _file;

_file = get_open_filename_ext("*.json|JSON","",program_directory,"Load Constraints File");

if (_file <> "")
{
	constraints_file = _file;
	if (!ignore_weights)
	{
		_file = get_open_filename_ext("*.json|JSON","",program_directory,"Load Weights File");

		if (_file <> "")
		{
			weights_file = _file;
			WFC_load_tileset_data(symmetries_file,constraints_file,weights_file);
		}
		
		else
			show_message_async("Error: File not found.");
	}
	
	else 
		WFC_load_tileset_data(symmetries_file,constraints_file,weights_file);
}

else
	show_message_async("Error: File not found.");
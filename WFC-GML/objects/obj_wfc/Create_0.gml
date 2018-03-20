//gml_pragma("forceinline", true);
//randomize();

//tilemap_width = room_width div tile_width;
//tilemap_height = room_height div tile_height;
tile_layer = layer_create(50);
tilemap_layer = layer_tilemap_create(tile_layer,0,0,tile_set,tilemap_width,tilemap_height);

tile_filter = ds_list_create();
//ds_list_add(tile_filter, 0,1,6,7);

WFC_init();
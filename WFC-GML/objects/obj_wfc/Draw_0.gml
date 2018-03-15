draw_set_halign(fa_center);
draw_set_valign(fa_center);

var _percent = ((max_entropy-entropy)/max_entropy)*100;
draw_healthbar(room_width-200,0,room_width,12,_percent,c_black,progress_bar_col,progress_bar_col,0,false,true);
draw_text(room_width-100,6,string_format(_percent,4,1) + "%");

draw_set_halign(fa_right);
draw_set_valign(fa_top);

if (time_taken <> -1)
	draw_text(room_width,16,"Time taken: " + string(time_taken) + "s");

draw_text(room_width,32,"FPS: " + string(fps));

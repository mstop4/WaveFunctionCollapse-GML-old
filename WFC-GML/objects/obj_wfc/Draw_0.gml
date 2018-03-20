draw_set_color(c_black);
draw_set_alpha(0.33);
draw_rectangle(room_width-208,0,room_width,74,false);

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_center);

var _percent 
if (max_entropy > 0)
	_percent = ((max_entropy-entropy)/max_entropy)*100;
else
	_percent = 100;
	
draw_healthbar(room_width-200,0,room_width,12,_percent,c_black,progress_bar_col,progress_bar_col,0,true,true);
draw_text(room_width-100,6,string_format(_percent,4,1) + "%");

draw_set_halign(fa_right);
draw_set_valign(fa_top);

if (time_taken <> -1)
	draw_text(room_width,16,"Time taken: " + string(time_taken) + "s");

draw_text(room_width,32,"FPS: " + string(fps));
draw_text(room_width,48,"Time/step: " + string(step_max_time) + " ms");

if (error_x != -1 && error_y != -1)
{
	draw_set_color(c_red);
	draw_set_halign(fa_center);
	draw_set_valign(fa_center);
	draw_text((error_x + 0.5) * tile_width, (error_y + 0.5) * tile_height, "X");
}
draw_set_halign(fa_right);
draw_text(room_width,0,string(entropy));

if (time_taken <> -1)
	draw_text(room_width,16,"Time taken: " + string(time_taken));

draw_text(room_width,32,"FPS: " + string(fps) + "\nStack: " + string(stack_size));

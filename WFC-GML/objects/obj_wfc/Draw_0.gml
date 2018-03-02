draw_set_halign(fa_right);
draw_text(room_width,0,string(inv_progress));

if (time_taken <> -1)
draw_text(room_width,32,"Time taken: " + string(time_taken));
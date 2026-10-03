//MOEDA GIRANDO (O FRAME ANDA NO STEP). NO ULTIMO SEGUNDO PISCA AVISANDO QUE VAI SUMIR
if(!pegou and timer > MOEDA_VIDA - room_speed and (timer div 4) mod 2 == 0) exit;
draw_sprite_ext(spr_moeda, frame, x, y, esc, esc, 0, c_white, 1);

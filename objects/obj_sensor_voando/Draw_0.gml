//RASTRO + BLOCO VERMELHO PISCANDO
for(var i = 1; i <= 3; i++) draw_sprite_ext(spr_peca, frame, x - dir * i * 5, y, 1, 1, 0, c_white, .25 / i);
draw_sprite_ext(spr_peca, frame, x, y, 1, 1, 0, c_white, 1);
gpu_set_fog(true, c_red, 0, 1);
draw_sprite_ext(spr_peca, frame, x, y, 1, 1, 0, c_white, .35 + .25 * sin(current_time / 40));
gpu_set_fog(false, c_white, 0, 1);

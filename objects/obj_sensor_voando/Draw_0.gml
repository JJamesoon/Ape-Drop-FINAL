//RASTRO + O BLOCO COM A SETA ACESA (QUADRO 6 DO TIRO), VIRADO PRO LADO QUE ELE VAI. PISCA UM CLARAO BRANCO
for(var i = 1; i <= 3; i++) draw_sprite_ext(spr_bloco_sniper_tiro, 6, x - dir * i * 5, y, dir, 1, 0, c_white, .25 / i);
draw_sprite_ext(spr_bloco_sniper_tiro, 6, x, y, dir, 1, 0, c_white, 1);
gpu_set_fog(true, c_white, 0, 1);
draw_sprite_ext(spr_bloco_sniper_tiro, 6, x, y, dir, 1, 0, c_white, .15 + .15 * sin(current_time / 40));
gpu_set_fog(false, c_white, 0, 1);

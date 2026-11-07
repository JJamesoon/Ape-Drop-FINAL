//FICHA DOURADA COM A LETRA, COM UM BRILHO PULSANDO EM VOLTA (PISCA NOS ULTIMOS 3S ANTES DE SUMIR)
if(timer < room_speed * 3 and (timer div 5) mod 2 == 0) exit;
//BRILHO PULSANDO EM VOLTA
draw_set_alpha(.25 + .2 * sin(current_time / 90));
draw_set_color(c_yellow);
draw_circle(x, y + sin(current_time / 180) * 1.5, 14 * esc, false);
draw_set_alpha(1);

//A FICHA FLUTUA PRA CIMA E PRA BAIXO
var _y = y + sin(current_time / 180) * 1.5;
var _r = 8 * esc;
//SOMBRA, FICHA E O BRILHO DE CIMA
draw_set_color(#3A1E08);
draw_circle(x, _y + 1, _r + 1, false);
draw_set_color(#FFB21E);
draw_circle(x, _y, _r, false);
draw_set_color(#FFE66B);
draw_circle(x - 1, _y - 1, _r - 2, false);

//A LETRA (COM SOMBRA)
draw_set_font(fnt_hud);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed_color(x + 1, _y + 1, letras_nomes_de(dono)[letra], esc, esc, 0, #3A1E08, #3A1E08, #3A1E08, #3A1E08, 1);
draw_text_transformed_color(x, _y, letras_nomes_de(dono)[letra], esc, esc, 0, #C24A00, #C24A00, #C24A00, #C24A00, 1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

//ESPINHOS: TETO ESCURO DESCENDO COM UMA FILEIRA DE ESPINHOS NA PONTA
if(!instance_exists(area)) exit;
//TREME JUNTO COM A ARENA
var _sx = global.shake_x, _sy = global.shake_y + global.lerp_y;
var _x1 = area.x + _sx, _x2 = area.x + area.sprite_width + _sx;
var _base = espinho_y - 8 + _sy;	//ONDE OS ESPINHOS COMEÇAM (A PONTA FICA EM ESPINHO_Y)
if(_base > area.y)
{
	draw_set_color(#1A0F2A);
	draw_rectangle(_x1, area.y + _sy, _x2 - 1, _base, false);
	draw_set_color(#3B2A55);
	draw_line(_x1, _base, _x2, _base);
}
espinhos_desenhar(_x1, _x2, espinho_y + _sy);
draw_set_color(c_white);

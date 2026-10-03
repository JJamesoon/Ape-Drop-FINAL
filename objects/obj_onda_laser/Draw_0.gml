//LASERS (AVISO PISCANDO E O FEIXE), DO TOPO DA TELA (VEM DO CEU) AO CHAO DA ARENA. TREMEM JUNTO COM A ARENA
if(!instance_exists(obj_area)) exit;
var _y1 = view_enabled ? camera_get_view_y(view_camera[0]) : 0; //(O TOPO NAO TREME: SENAO ABRIA UM BURACO EM CIMA)
var _y2 = obj_area.y + obj_area.sprite_height + global.shake_y + global.lerp_y;
for(var i = 0; i < array_length(lasers); i++)
{
	var _l = lasers[i];
	var _x = _l.x + global.shake_x;
	if(_l.t < LASER_AVISO)
	{
		//AVISO: LINHA VERMELHA FINA QUE VAI FICANDO MAIS FORTE E PISCA MAIS RAPIDO PERTO DE DISPARAR
		var _p = _l.t / LASER_AVISO;
		var _pisca = ((_l.t div (_p > .6 ? 3 : 6)) mod 2) ? 1 : .5;
		draw_set_alpha((.15 + .35 * _p) * _pisca);
		draw_set_color(c_red);
		draw_rectangle(_x - CEL / 2, _y1, _x + CEL / 2 - 1, _y2, false);
		draw_set_alpha((.5 + .5 * _p) * _pisca);
		draw_line_width(_x, _y1, _x, _y2, 1);
		//SETINHAS NO TOPO MOSTRANDO A COLUNA
		draw_triangle(_x - 5, _y1 + 2, _x + 5, _y1 + 2, _x, _y1 + 8, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
	}
	else
	{
		//FEIXE: BRILHO LARGO, NUCLEO ROSA E MIOLO BRANCO (A LARGURA VIBRA UM POUCO E DIMINUI NO FINAL)
		var _f = 1 - (_l.t - LASER_AVISO) / LASER_ATIVO;
		var _w = (LASER_LARGURA / 2) * (.6 + .4 * _f) + random(1);
		draw_set_alpha(.35 * _f + .15);
		draw_set_color(#FF3060);
		draw_rectangle(_x - _w - 3, _y1, _x + _w + 3, _y2, false);
		draw_set_alpha(.9);
		draw_set_color(#FF7A9A);
		draw_rectangle(_x - _w, _y1, _x + _w, _y2, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_rectangle(_x - _w * .35, _y1, _x + _w * .35, _y2, false);
	}
}

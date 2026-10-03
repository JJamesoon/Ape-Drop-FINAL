//MURO DESCENDO (TIJOLOS ESCUROS) COM O BURACO DA PEÇA E OS ESPINHOS EMBAIXO
if(!instance_exists(area)) exit;
//TREME JUNTO COM A ARENA
var _sx = global.shake_x, _sy = global.shake_y + global.lerp_y;
var _x1 = area.x + _sx, _x2 = area.x + area.sprite_width + _sx;
//TOPO DA ARENA E ONDE O MURO TERMINA (OS ESPINHOS FICAM EMBAIXO)
var _topo = area.y + _sy;
var _base = muro_y - 8 + _sy;
if(_base > area.y)
{
	//FUNDO DO MURO
	draw_set_color(#2A1C40);
	draw_rectangle(_x1, _topo, _x2 - 1, _base, false);
	//TIJOLOS
	draw_set_color(#3B2A55);
	var _linha = 0;
	for(var yy = _base; yy > _topo; yy -= 8)
	{
		draw_line(_x1, yy, _x2, yy);
		for(var xx = _x1 + (_linha mod 2) * 8; xx < _x2; xx += 16) draw_line(xx, max(_topo, yy - 8), xx, yy);
		_linha++;
	}

	//BURACO: A FORMA QUE A PEÇA TEM QUE FICAR (BORDA AMARELA PISCANDO)
	if(estado == "puzzle" and array_length(alvo) > 0 and voo < 0)
	{
		//MEIO E TAMANHO DO BURACO: CANTO DE CIMA DELE
		var _m = buraco_meio(alvo), _t = forma_tam(alvo);
		var _bx = _m[0] - _t[0] * ENC_BURACO / 2 + _sx, _by = _m[1] - _t[1] * ENC_BURACO / 2 + _sy;
		var _p = .5 + .5 * sin(current_time / 150);
		for(var i = 0; i < array_length(alvo); i++)
		{
			var _cx = _bx + alvo[i][0] * ENC_BURACO, _cy = _by + alvo[i][1] * ENC_BURACO;
			draw_set_color(#0E071B);
			draw_rectangle(_cx, _cy, _cx + ENC_BURACO - 1, _cy + ENC_BURACO - 1, false);
			draw_set_alpha(.4 + .5 * _p);
			draw_set_color(c_yellow);
			draw_rectangle(_cx, _cy, _cx + ENC_BURACO - 1, _cy + ENC_BURACO - 1, true);
			draw_set_alpha(1);
		}
	}

	//PEÇA QUE ACABOU DE ENCAIXAR (PISCANDO NA COR DELA)
	if(flash > 0 and array_length(flash_forma) > 0)
	{
		var _m = buraco_meio(flash_forma), _t = forma_tam(flash_forma);
		var _bx = _m[0] - _t[0] * ENC_BURACO / 2 + _sx, _by = _m[1] - _t[1] * ENC_BURACO / 2 + _sy;
		draw_set_alpha(flash / 25);
		for(var i = 0; i < array_length(flash_forma); i++)
		{
			var _cx = _bx + flash_forma[i][0] * ENC_BURACO, _cy = _by + flash_forma[i][1] * ENC_BURACO;
			draw_set_color((flash div 3) mod 2 == 0 ? c_white : flash_cor);
			draw_rectangle(_cx, _cy, _cx + ENC_BURACO - 1, _cy + ENC_BURACO - 1, false);
		}
		draw_set_alpha(1);
	}
}
//ESPINHOS NA PONTA DO MURO
if(muro_y > area.y) espinhos_desenhar(_x1, _x2, muro_y + _sy);
draw_set_color(c_white);

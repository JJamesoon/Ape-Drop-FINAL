//A CORTINA COBRE A TELA INTEIRA (GUI_TELA: NO CELULAR A GUI TEM DESLOCAMENTO)
var _tl = gui_tela();
var _x0 = _tl[0], _y0 = _tl[1];
var _gw = _tl[2] - _tl[0];
var _gh = _tl[3] - _tl[1];

draw_set_colour(c_black);

//FECHANDO: OS DOIS LADOS VEM ATE O MEIO
if(entrando)
{
	rec_e = lerp(rec_e, _gw/2+20, .2);
	rec_d = lerp(rec_d, _gw/2+20, .2);
	
	draw_rectangle(_x0, _y0, _x0 + rec_e, _y0 + _gh, 0);
	draw_rectangle(_x0 + _gw, _y0, _x0 + _gw - rec_d, _y0 + _gh, 0);
	
	//FECHOU: TROCA DE ROOM E DAQUI A 10 FRAMES COMEÇA A ABRIR
	if(rec_e >= _gw/2+20 - 2)
	{
		rec_e = _gw/2;
		rec_d = _gw/2;
		entrando = false;
		
		room_goto(prox_room);
		if(alarm[0] == -1) alarm[0] = 10;
	}
//ABRINDO: A PARTE DE CIMA SOBE E A DE BAIXO DESCE
}else
{
	if(sair)
	{
		rec_t = lerp(rec_t, _gh/2+50, .13);
		rec_b = lerp(rec_b, _gh/2+50, .13);
	}
	
	draw_rectangle(_x0, _y0, _x0 + _gw, _y0 + _gh/2 - rec_t, 0);
	draw_rectangle(_x0, _y0 + _gh, _x0 + _gw, _y0 + _gh/2 + rec_b, 0);
	
	//CORTINA TOTALMENTE ABERTA: A TRANSIÇAO ACABOU
	if(sair and rec_t >= _gh/2 + 50 - 2) instance_destroy();
}

draw_set_colour(c_white);


//PROFUNDIDADE: A MESMA REGRA DAS PEÇAS (SCR_GRIDS): EM CIMA NA FRENTE; NA MESMA LINHA, A DIREITA NA FRENTE
depth = profundidade(x, y);

//TREME JUNTO COM A ARENA (O CABEÇUDO VAI PRA FRENTE NA CABEÇADA)
var _x = x + shake_x + dir * 4 * cab_bump;
aqua_inicio(); //BLOCO RAIO LIGADO: O INIMIGO SAI AQUA

//NOCAUTE: DE PONTA CABEÇA, COM AS PERNINHAS PRA CIMA
if(estado == "nocaute")
{
	if(pernas > 0) draw_sprite_part_ext(spr_inimigo_pes, 0, 0, 3 - pernas, 16, pernas + 1, _x - 8, y - 7, 1, -1, c_white, 1);
	if(cabecudo) draw_sprite_ext(spr_bloco_cabecudo, dir > 0 ? 0 : 1, _x, y, 1, -1, 0, c_white, 1);
	else draw_sprite_ext(bomba ? spr_inimigo_bomba : spr_inimigo, 2, _x, y, 1, -1, 0, c_white, 1);
	aqua_fim();
	exit;
}

//OLHANDO PRA ONDE ANDA (FRAME 0 DIREITA, 1 ESQUERDA, 2 TONTO. O CABEÇUDO SO TEM OS 2 PRIMEIROS)
var _frame = (estado == "amassado" and !cabecudo) ? 2 : (dir > 0 ? 0 : 1);
var _base = y + 8 - pernas; //BAIXO DO CORPO (SOBE COM AS PERNAS)

//PES (SPR_INIMIGO_PES TEM 4 LINHAS, A SOLA NA ULTIMA): APARECEM DEBAIXO DO BLOCO CONFORME AS PERNAS CRESCEM.
//A LINHA DE CIMA FICA ATRAS DA BEIRADA DO CORPO
if(pernas > 0)
{
	var _pf = (estado == "andando" and velv == 0) ? 1 + (floor(passo) mod 2) : 0;
	draw_sprite_part_ext(spr_inimigo_pes, _pf, 0, 3 - pernas, 16, pernas + 1, _x - 8, _base - 1, 1, 1, c_white, alpha);
}

//CORPO (O AMASSADINHO FICA PRESO NO CHAO)
var _y = _base - 8 * esc_y;
//BOMBA: O MESMO BLOCO DO INIMIGO, ESCURO, COM CARA MALVADA E PAVIO EM CIMA (SPR_INIMIGO_BOMBA, MESMOS FRAMES).
//NO AVISO ELA INCHA E PISCA VERMELHO, CADA VEZ MAIS RAPIDO
var _spr = cabecudo ? spr_bloco_cabecudo : (bomba ? spr_inimigo_bomba : spr_inimigo);
var _ex = esc_x, _ey = esc_y;
var _vermelho = 0;
if(bomba and vivo()) //DESARMADA (AMASSADA) PARA DE PULSAR
{
	if(bomba_timer < BOMBA_AVISO)
	{
		var _vel = bomba_timer < room_speed ? 40 : 90;
		var _p = .5 + .5 * sin(current_time / _vel);
		_ex *= 1 + .18 * _p;
		_ey *= 1 + .18 * _p;
		_vermelho = _p * .8;
	}
}
draw_sprite_ext(_spr, _frame, _x, _y, _ex, _ey, 0, c_white, alpha);
aqua_fim();
if(alpha_fog > 0)
{
	gpu_set_fog(true, c_white, 0, 1);
	draw_sprite_ext(_spr, _frame, _x, _y, _ex, _ey, 0, c_white, alpha_fog * alpha);
	gpu_set_fog(false, c_white, 0, 1);
}
if(_vermelho > 0)
{
	gpu_set_fog(true, c_red, 0, 1);
	draw_sprite_ext(_spr, _frame, _x, _y, _ex, _ey, 0, c_white, _vermelho * alpha);
	gpu_set_fog(false, c_white, 0, 1);
}

//BOMBA ACESA: FAISCA PISCANDO NA PONTA DO PAVIO (PIXEL 16,1 DA SPRITE, A ORIGEM E 11,20). DESARMADA NAO TEM
if(bomba and estado != "amassado")
{
	var _fx = _x + 5.5 * _ex, _fy = _y - 19.5 * _ey;
	var _r = 2 + random(1.5);
	draw_set_alpha(.55 * alpha);
	draw_circle_color(_fx, _fy, _r + 1.5, #FF8A1E, #FF8A1E, false);
	draw_set_alpha(alpha);
	draw_circle_color(_fx, _fy, _r * .55, c_yellow, c_yellow, false);
	draw_set_color(c_white);
	draw_rectangle(_fx - .5, _fy - .5, _fx + .5, _fy + .5, false);
	//RAIOZINHOS SAINDO PRA TODO LADO
	draw_set_color(#FFD84A);
	repeat(2)
	{
		var _a = irandom(7) * 45;
		draw_line(_fx, _fy, _fx + lengthdir_x(_r + 2, _a), _fy + lengthdir_y(_r + 2, _a));
	}
	draw_set_color(c_white);
	draw_set_alpha(1);
}

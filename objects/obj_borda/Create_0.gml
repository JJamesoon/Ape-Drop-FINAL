//BORDA/HUD DA ARENA: PAINEIS DE SCORE, LEVEL, TEMPO, MOEDAS, LETRAS E PODERES (DESENHADOS NO DRAW)


pontos_mostrado = 0; //O NUMERO DO HUD SOBE SUAVE ATE OS PONTOS DE VERDADE
//QUANTO O PAINEL DA DIREITA (SCORE, RETRATO, MOEDAS, LETRAS, PODERES) ANDA PRA DIREITA QUANDO A ARENA E MAIS
//LARGA QUE A ARTE DA BORDA (O OBJ_AREA MUDA: NO COOP SAO 96PX). A BORDA ESTICA NO MEIO (BORDA_DESENHAR)
dx_hud = 0;

moeda_esc = 1;		//A CAIXINHA DE MOEDAS DA UM "POP" QUANDO CHEGA MOEDA
energia_mostrada = 0;	//A BARRA DE ENERGIA SOBE SUAVE
alerta_tempo = 0;		//0 A 1: O ALERTA DO PODER DE PARAR O TEMPO DO LADO DA BARRA (ENTRA DESLIZANDO QUANDO ENCHE)

score_esc = 1;		//O SCORE DA UM PULO QUANDO CHEGA PONTO VOANDO
combo_alpha = 0;		//CONTADOR DE COMBO NA LATERAL
combo_mostrado = 0;
perigo_alpha = 0;		//ARENA PISCANDO VERMELHO QUANDO OS BLOCOS CHEGAM PERTO DO TOPO
febre_mix = 0;	//0 A ~.55: QUANTO OS PAINEIS FICAM LARANJA NA FEBRE (IGUAL A BORDA)
poder_pop = array_create(array_length(global.poderes_lista), 1);	//ICONE DO PODER DA UM "POP" QUANDO GANHA
poderes_antes = [];	//PODERES QUE O PLAYER TINHA NO FRAME ANTERIOR (PRA SABER QUAL E NOVO)

//PAINEL NO ESTILO DA BORDA: CONTORNO BRANCO, FUNDO ESCURO E A LATERAL 3D CINZA PRA CIMA E PRA DIREITA
hud_painel = function(_x1, _y1, _x2, _y2)
{
	var _g = 3;
	draw_set_color(merge_color(#E0E0E0, #FF7A1A, febre_mix));
	draw_rectangle(_x1 + _g, _y1 - _g, _x2 + _g, _y2 - _g, false);
	draw_triangle(_x1, _y1, _x1 + _g, _y1 - _g, _x1 + _g, _y1, false);
	draw_triangle(_x2, _y2, _x2 + _g, _y2 - _g, _x2, _y2 - _g, false);
	draw_set_color(merge_color(c_white, #FF7A1A, febre_mix));
	draw_rectangle(_x1, _y1, _x2, _y2, false);
	draw_set_color(#0E071B);
	draw_rectangle(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, false);
}

//FAIXA DE TITULO IGUAL AS DO SCORE/LEVEL/TIME (3 TONS DA ESQUERDA PRA DIREITA E SOMBRA EMBAIXO)
hud_faixa = function(_x1, _y1, _x2, _texto, _c1, _c2, _c3)
{
	var _w = _x2 - _x1;
	draw_set_color(_c1);
	draw_rectangle(_x1, _y1, _x1 + _w * .62, _y1 + 8, false);
	draw_set_color(_c2);
	draw_rectangle(_x1 + _w * .62, _y1, _x1 + _w * .82, _y1 + 8, false);
	draw_set_color(_c3);
	draw_rectangle(_x1 + _w * .82, _y1, _x2, _y1 + 8, false);
	draw_set_color(#1A1932);
	draw_rectangle(_x1, _y1 + 9, _x2, _y1 + 9, false);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_text_transformed_color(_x1 + 4, _y1 + 5.5, _texto, .55, .55, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
	draw_text_transformed_color(_x1 + 3, _y1 + 4.5, _texto, .55, .55, 0, c_white, c_white, c_white, c_white, 1);
}

//ICONE 9X9 DO PODER (PODER_ICONE_DESENHAR, SCR_PODERES)
hud_icone = function(_id, _x, _y, _cor, _apagado)
{
	poder_icone_desenhar(_id, _x, _y, 1, _cor, _apagado);
}

//RETRATO DE UM JOGADOR (52X60) COM A CARA DO MOMENTO (_CARA = EMOÇAO GERAL).
//FRAMES DO SPR_*_PERFIL: 0 NORMAL, 1 GRITANDO, 2 OLHO FECHADO, 3 MACHUCADO, 4 PODER (AZUL), 5 PODER MACHUCADO (SO O MACACO)
//NO COOP, MORTO: O RETRATO ESCURECE E MOSTRA QUANTO FALTA PRA VOLTAR
hud_retrato = function(_n, _x, _y, _cara)
{
	var _p = player_n(_n);
	var _perfil = global.skins[_n == 2 ? global.skin_player_2 : global.skin_player_1].perfil;
	if(_p != noone and _cara == 0 and _p.estado == state.jump) _cara = 1;	//GRITA NO PULO (IGUAL NO JOGO ANTIGO)
	if(global.febre > 0) _cara = 4;												//NA FEBRE FICA COM PODER
	if(_p != noone and (_p.estado == state.dano or _p.estado == state.morte or _p.imune > 0))
	{
		_cara = (_cara == 4 and sprite_get_number(_perfil) > 5) ? 5 : 3;		//MACHUCADO (OU PODER MACHUCADO)
	}
	if(_cara == 0 and (current_time + _n * 1700) mod 3500 < 130) _cara = 2;	//PISCA DE VEZ EM QUANDO (CADA UM NUMA HORA)
	//O RETRATO TEM 60X60 E A CAIXA 52 DE LARGURA: CORTA 4PX DE CADA LADO (SEM ESTICAR O PIXEL ART)
	draw_sprite_part(_perfil, _cara, 4, 0, 52, 60, _x, _y);

	if(global.coop and _p != noone and _p.estado == state.morte)
	{
		draw_set_alpha(.65);
		draw_set_color(#0E071B);
		draw_rectangle(_x, _y, _x + 51, _y + 59, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		//O PARCEIRO TA VIVO: CONTAGEM PRA VOLTAR
		if(!todos_mortos())
		{
			var _cor = _n == 2 ? COOP_COR_P2 : COOP_COR_P1;
			draw_set_font(fnt_hud);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_text_transformed_color(_x + 26, _y + 20, global.linguagem == 0 ? "VOLTA EM" : "BACK IN", .55, .55, 0, c_white, c_white, c_white, c_white, 1);
			draw_text_transformed_color(_x + 26, _y + 38, string(ceil(max(0, _p.reviver) / room_speed)), 1.6, 1.6, 0, _cor, _cor, _cor, _cor, 1);
			draw_set_font(fnt_mini_hud);
			draw_set_halign(1);
			draw_set_valign(1);
		}
	}
}

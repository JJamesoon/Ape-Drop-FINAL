//DESENHANDO A BORDA========================
var shake_x, shake_y;

//TREME JUNTO COM A ARENA DELA (NO VERSUS, A DA DIREITA USA A TREMIDA DO PLAYER 2)
if(modo_arcade() or x < room_width/2)
{
	shake_x = global.shake_x;
	shake_y = global.shake_y;
}
else 
{
	shake_x = global.shake_x_2;
	shake_y = global.shake_y_2;
}
//FRAME DA BORDA: 3 NO ARCADE E NA ARENA DA DIREITA DO VERSUS, 1 NO RESTO
var _index;
if(modo_arcade() or room == rm_versus and x > room_width/2) _index = 3;
else _index = 1;
borda_desenhar(sprite_index, _index, x + shake_x, y + shake_y, dx_hud);

//FEBRE: A BORDA PISCA EM LARANJA (MAIS RAPIDO NOS ULTIMOS 2 SEGUNDOS, PRA AVISAR QUE TA ACABANDO)
//(FEBRE_MIX: OS PAINEIS DESENHADOS NO CODIGO PISCAM JUNTO, VER HUD_PAINEL)
febre_mix = 0;
if(modo_arcade() and global.febre > 0)
{
	var _vel_pisca = global.febre < room_speed * 2 ? 50 : 120;
	febre_mix = .3 + .25 * sin(current_time / _vel_pisca);
	gpu_set_fog(true, #FF7A1A, 0, 1);
	borda_desenhar(sprite_index, _index, x + shake_x, y + shake_y, dx_hud, febre_mix);
	gpu_set_fog(false, c_white, 0, 1);
}
//DESENHANDO A BORDA========================

//INICIANDO O SISTEMA DE MOSTRAR A HUD
//VALORES DO PAINEL: [PONTOS, RECORDE, LEVEL, TEMPO] DO MODO/LADO CERTO
var _array;
if(modo_arcade())
{
	_array = [global.pontos_1, recorde_atual(), global.level, 0]; //NO COOP: PONTOS DO TIME E RECORDE DO COOP
}
else if(room == rm_coop)
{
	_array = [global.pontos_coop, global.record_coop, global.level, 0];
}
else if(x < room_width/2)
{
	_array = [global.pontos_1, global.record_1, global.level, 0];
}
else
{
	_array = [global.pontos_2, global.record_2, global.level_2, 0];
}

//PONTOS SOBEM SUAVE ATE O VALOR REAL (MENOS OS QUE AINDA TAO VOANDO ATE AQUI)
var _alvo_pontos = _array[0];
if(modo_arcade()) _alvo_pontos = max(0, _array[0] - global.pontos_pendentes);
pontos_mostrado = lerp(pontos_mostrado, _alvo_pontos, .2);
if(abs(pontos_mostrado - _alvo_pontos) < 1) pontos_mostrado = _alvo_pontos;
_array[0] = round(pontos_mostrado);
score_esc = lerp(score_esc, 1, .15);

//O HI-SCORE ACOMPANHA O PLACAR (SENAO ELE SUBIA ANTES DOS PONTOS CHEGAREM VOANDO)
if(modo_arcade() and instance_exists(obj_game_control)) _array[1] = max(obj_game_control.recorde_inicio, _array[0]);

//TEMPO DA PARTIDA (MM:SS)
var _seg = floor(global.tempo_partida);
_array[3] = string_replace_all(string_format(_seg div 60, 2, 0), " ", "0") + ":" + string_replace_all(string_format(_seg mod 60, 2, 0), " ", "0");

//X DO PAINEL DA DIREITA (ANDA DX_HUD PRA DIREITA: HOJE 0)
var _hx = x + dx_hud;

//COLUNA DOS NUMEROS NO PAINEL
var _x = _hx + 217 + shake_x;

draw_set_font(fnt_mini_hud);
draw_set_valign(1);
draw_set_halign(1);

//SCORE, HI-SCORE, LEVEL E TIME (UM EMBAIXO DO OUTRO NO PAINEL DA BORDA)
for(var i = 0; i < array_length(_array); i ++)
{
	var _y = y + 106 + 22*i + shake_y;
	var _e = i == 0 ? score_esc : 1; //O SCORE DA UM PULO QUANDO CHEGA PONTO
	var _c = (i == 0 and score_esc > 1.05) ? c_yellow : c_white;
	draw_text_transformed_color(_x + 1, _y + 1, _array[i], _e, _e, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
	draw_text_transformed_color(_x, _y, _array[i], _e, _e, 0, _c, _c, _c, _c, 1);
}

if(modo_arcade())
{
	//EMOÇAO DO MOMENTO (GLOBAL.EMOCAO DURA EMOCAO_TIMER FRAMES). VALE PROS DOIS RETRATOS
	var _cara = 0;
	if(global.emocao_timer > 0)
	{
		global.emocao_timer--;
		_cara = global.emocao;
	}

	//RETRATO DO PLAYER 1 (NA CAIXA ONDE FICAVA A PROXIMA PEÇA) E OS CORAÇOES DELE
	//(A BORDA JA TEM O CONTORNO DOS CORAÇOES, AQUI SO PREENCHE OS QUE AINDA TEM)
	hud_retrato(1, _hx + 194 + shake_x, y + 16 + shake_y, _cara);
	var _p1 = player_n(1);
	var _vida = _p1 != noone ? _p1.vida_atual : 0;
	for(var i = 0; i < 3; i++)
	{
		if(i < _vida) draw_sprite(spr_coracao, 2, _hx + 254 + shake_x, y + 24 + 20*i + shake_y);
	}

	//COOP: ETIQUETA NO RETRATO DO P1 E O PAINEL DO PLAYER 2 NO LADO ESQUERDO DA ARENA (RETRATO + CORAÇOES)
	if(global.coop)
	{
		draw_set_font(fnt_hud);
		draw_text_transformed_color(_hx + 204 + shake_x, y + 23 + shake_y, "P1", .6, .6, 0, COOP_COR_P1, COOP_COR_P1, COOP_COR_P1, COOP_COR_P1, 1);
		draw_set_font(fnt_mini_hud);
		var _qx = x - 104 + shake_x, _qy = y + 6 + shake_y;
		hud_painel(_qx, _qy, _qx + 74, _qy + 74);
		hud_faixa(_qx + 1, _qy + 1, _qx + 73, "PLAYER 2", #0E5A7A, #1C8FB8, COOP_COR_P2);
		hud_retrato(2, _qx + 2, _qy + 12, _cara);
		var _p2 = player_n(2);
		var _vida2 = _p2 != noone ? _p2.vida_atual : 0;
		for(var i = 0; i < 3; i++) draw_sprite(spr_coracao, i < _vida2 ? 2 : 1, _qx + 64, _qy + 22 + 20 * i);
		draw_set_halign(1);
		draw_set_valign(1);
	}

	//BARRA DE ENERGIA (CANAL DA PAREDE ESQUERDA DA BORDA: 6PX DE LARGURA, 303 DE ALTURA)
	//A BARRA SOBE SUAVE ATE A ENERGIA DE VERDADE. _TOPO = ATE ONDE ELA TA CHEIA
	energia_mostrada = lerp(energia_mostrada, global.energia, .1);
	var _bx1 = x - 7 + shake_x, _bx2 = x - 2 + shake_x;
	var _by1 = y + 1 + shake_y,  _by2 = y + 303 + shake_y;
	var _alt = _by2 - _by1;
	var _topo = _by2 - _alt * (energia_mostrada / ENERGIA_MAX);
	var _pulso = .75 + .25 * sin(current_time / 150);
	
	//PARTE CHEIA (CARGAS COMPLETAS PISCAM, A QUE TA ENCHENDO FICA MAIS ESCURA)
	for(var i = 0; i < ENERGIA_MAX; i++)
	{
		//CADA CARGA E UM PEDAÇO DA BARRA
		var _seg_base = _by2 - _alt * i / ENERGIA_MAX;
		var _seg_topo = _by2 - _alt * (i + 1) / ENERGIA_MAX;
		var _fim = max(_seg_topo, _topo);
		if(_fim >= _seg_base) continue;
		var _cheia = energia_mostrada >= i + 1;
		draw_set_alpha(_cheia ? _pulso : .55);
		draw_rectangle_color(_bx1, _fim, _bx2, _seg_base, #31FCFF, #31FCFF, #1C6FD1, #1C6FD1, false);
	}
	draw_set_alpha(1);
	//DIVISOES ENTRE AS CARGAS
	for(var i = 1; i < ENERGIA_MAX; i++)
	{
		var _yy = _by2 - _alt * i / ENERGIA_MAX;
		draw_line_color(_bx1, _yy, _bx2 + 1, _yy, c_white, c_white);
	}
	
	//ENERGIA CHEIA: ALERTA DO PODER DE PARAR O TEMPO DO LADO DA BARRA (RELOGIO, NOME E A TECLA 1), COM UMA SETA PRA BARRA
	//E A BARRA PISCANDO EM VERDE. ENTRA DESLIZANDO DA ESQUERDA
	var _pronto = global.energia >= ENERGIA_MAX and global.tempo_fase == "";
	alerta_tempo = lerp(alerta_tempo, _pronto ? 1 : 0, .15);
	if(_pronto)
	{
		draw_set_alpha(.35 + .35 * sin(current_time / 110));
		draw_set_color(TEMPO_VERDE);
		draw_rectangle(_bx1, _by1, _bx2, _by2, false);
		draw_set_alpha(1);
	}
	if(alerta_tempo > .02)
	{
		var _ea = alerta_tempo;
		var _ax2 = x - 16 + shake_x - (1 - _ea) * 40, _ax1 = _ax2 - 92;
		var _ay1 = y + 196 + shake_y, _ay2 = _ay1 + 46;
		hud_painel(_ax1, _ay1, _ax2, _ay2);
		hud_faixa(_ax1 + 1, _ay1 + 1, _ax2 - 1, global.linguagem == 0 ? "PODER PRONTO!" : "POWER READY!", #0E6A3A, #1FA85A, TEMPO_VERDE);
		//RELOGIO (PONTEIRO GIRANDO)
		var _rx = _ax1 + 13, _ry = _ay1 + 29;
		draw_set_color(#0E3A22);
		draw_circle(_rx, _ry, 9, false);
		draw_set_color(TEMPO_VERDE);
		draw_circle(_rx, _ry, 9, true);
		draw_circle(_rx, _ry, 8, true);
		for(var k = 0; k < 4; k++) draw_point(_rx + lengthdir_x(6, k * 90), _ry + lengthdir_y(6, k * 90));
		draw_set_color(c_white);
		draw_line(_rx, _ry, _rx + lengthdir_x(6, 90 - current_time / 8), _ry + lengthdir_y(6, 90 - current_time / 8));
		draw_line(_rx, _ry, _rx + lengthdir_x(4, 90), _ry + lengthdir_y(4, 90));
		//NOME DO PODER
		draw_set_font(fnt_hud);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _tx = _ax1 + 47;
		var _l1 = global.linguagem == 0 ? "PARAR O" : "TIME", _l2 = global.linguagem == 0 ? "TEMPO" : "STOP";
		draw_text_transformed_color(_tx + 1, _ay1 + 23, _l1, .6, .6, 0, #0E071B, #0E071B, #0E071B, #0E071B, _ea);
		draw_text_transformed_color(_tx, _ay1 + 22, _l1, .6, .6, 0, c_white, c_white, c_white, c_white, _ea);
		draw_text_transformed_color(_tx + 1, _ay1 + 34, _l2, .7, .7, 0, #0E071B, #0E071B, #0E071B, #0E071B, _ea);
		draw_text_transformed_color(_tx, _ay1 + 33, _l2, .7, .7, 0, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, _ea);
		//TECLA 1 (UMA TECLINHA QUE "APERTA" SOZINHA)
		var _apertou = (current_time div 400) mod 2 == 0;
		var _kx = _ax2 - 17, _ky = _ay1 + 21 + (_apertou ? 2 : 0);
		draw_set_color(#5A6A88);
		draw_rectangle(_kx - 1, _ay1 + 21 + 1, _kx + 13, _ay1 + 21 + 15, false);
		draw_set_color(_apertou ? #C8D2E6 : c_white);
		draw_rectangle(_kx - 1, _ky - 1, _kx + 13, _ky + 12 - (_apertou ? 2 : 0), false);
		draw_set_color(#0E071B);
		draw_rectangle(_kx - 1, _ky - 1, _kx + 13, _ky + 12 - (_apertou ? 2 : 0), true);
		draw_text_transformed_color(_kx + 6, _ky + 5.5 - (_apertou ? 1 : 0), "1", .8, .8, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
		//SETA APONTANDO PRA BARRA
		var _sx = _ax2 + 3 + sin(current_time / 120) * 2, _sy = _ay1 + 26;
		draw_set_color(TEMPO_VERDE);
		draw_triangle(_sx, _sy - 4, _sx, _sy + 4, _sx + 5, _sy, false);
		draw_set_halign(1);
		draw_set_valign(1);
		draw_set_font(fnt_mini_hud);
		draw_set_color(c_white);
	}

	//COMBO DE LINHAS (LADO ESQUERDO DA ARENA, NO ESPAÇO VAZIO)
	//APARECE COM COMBO DE 2 OU MAIS
	combo_alpha = lerp(combo_alpha, global.combo_seq >= 2 ? 1 : 0, .2);
	if(global.combo_seq >= 2) combo_mostrado = global.combo_seq;
	if(combo_alpha > .01)
	{
		var _ccx = x - 48 + shake_x;
		var _ccy = y + 130 + shake_y;
		//NO CELULAR EM PE O LADO ESQUERDO DA ARENA NAO APARECE: O COMBO VAI PRO CANTO DE CIMA DA ARENA
		if(gui_retrato()) { _ccx = x + 30 + shake_x; _ccy = y + 24 + shake_y; }
		var _pul = 1 + .08 * sin(current_time / 90);
		draw_set_font(fnt_hud);
		draw_set_halign(fa_center);
		//"COMBO" E EMBAIXO O "XN" GRANDE PULSANDO
		draw_text_transformed_color(_ccx + 1, _ccy + 1, "COMBO", 1, 1, 0, #0E071B, #0E071B, #0E071B, #0E071B, combo_alpha);
		draw_text_transformed_color(_ccx, _ccy, "COMBO", 1, 1, 0, c_aqua, c_aqua, c_aqua, c_aqua, combo_alpha);
		var _txt_c = "x" + string(combo_mostrado);
		var _ce = (1.6 + .1 * min(combo_mostrado, 6)) * _pul;
		draw_text_transformed_color(_ccx + 2, _ccy + 22, _txt_c, _ce, _ce, 0, #0E071B, #0E071B, #0E071B, #0E071B, combo_alpha);
		draw_text_transformed_color(_ccx, _ccy + 20, _txt_c, _ce, _ce, 0, c_white, c_white, c_aqua, c_aqua, combo_alpha);
		//TEMPO QUE FALTA PRA PERDER O COMBO
		var _bw = 40 * (global.combo_timer / COMBO_TEMPO);
		draw_set_alpha(combo_alpha);
		draw_rectangle_color(_ccx - 20, _ccy + 38, _ccx + 20, _ccy + 41, #0E071B, #0E071B, #0E071B, #0E071B, false);
		draw_rectangle_color(_ccx - 20, _ccy + 38, _ccx - 20 + _bw, _ccy + 41, c_aqua, c_aqua, c_aqua, c_aqua, false);
		draw_set_alpha(1);
		draw_set_font(fnt_mini_hud);
	}
	
	//PERIGO: ARENA PULSANDO VERMELHO
	perigo_alpha = lerp(perigo_alpha, global.perigo ? 1 : 0, .1);
	if(perigo_alpha > .01)
	{
		var _ar = obj_area;
		var _pp = (.5 + .5 * sin(current_time / 120)) * perigo_alpha;
		//FAIXA VERMELHA NAS 4 LINHAS DE CIMA, CONTORNO DA ARENA E O AVISO "PERIGO"
		draw_set_alpha(.18 * _pp);
		draw_rectangle_color(_ar.x, _ar.y, _ar.x + _ar.sprite_width, _ar.y + CEL * 4, c_red, c_red, c_red, c_red, false);
		draw_set_alpha(_pp);
		draw_rectangle_color(_ar.x, _ar.y, _ar.x + _ar.sprite_width, _ar.y + _ar.sprite_height, c_red, c_red, c_red, c_red, true);
		draw_set_alpha(1);
		draw_set_font(fnt_hud);
		draw_set_halign(fa_center);
		draw_text_transformed_color(_ar.x + _ar.sprite_width/2, _ar.y - 10, texto("perigo"), 1, 1, 0, c_red, c_red, c_red, c_red, _pp);
		draw_set_font(fnt_mini_hud);
	}
	
	//PAINEIS DE BAIXO (NO MESMO ESTILO DA BORDA): MOEDAS, LETRAS A P E D R O P E PODERES
	var _px1 = _hx + 170 + shake_x, _px2 = _hx + 255 + shake_x;
	var _sy = y + shake_y;

	//MOEDAS: A MOEDA FICA NA CAIXINHA DA BORDA E O NUMERO NUM PAINEL DO LADO
	moeda_esc = lerp(moeda_esc, 1, .15);
	hud_painel(_hx + 200 + shake_x, _sy + 182, _px2, _sy + 197);
	draw_sprite_ext(spr_moeda, current_time / 100, _hx + 187 + shake_x, _sy + 188, moeda_esc, moeda_esc, 0, c_white, 1);
	draw_set_font(fnt_mini_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _txt_moeda = string(global.moedas_partida);
	draw_text_transformed_color(_hx + 206 + shake_x, _sy + 190.5, _txt_moeda, moeda_esc, moeda_esc, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
	draw_text_transformed_color(_hx + 205 + shake_x, _sy + 189.5, _txt_moeda, moeda_esc, moeda_esc, 0, c_yellow, c_yellow, #FFB21E, #FFB21E, 1);

	//LETRAS A P E D R O P: CADA UMA E UM BLOQUINHO (APAGADO ATE PEGAR; PEGOU, GANHA A COR E DA UM "POP")
	hud_painel(_px1, _sy + 205, _px2, _sy + 226);
	//CORES DE CADA LETRA
	var _cores_l = [ #8BFF32, #FFFF00, #DE65FF, #31FCFF, #FF3237, #8BFF32, #FFFF00];
	var _nl = array_length(global.letras);
	var _lt = _nl <= 4 ? 6 : 5;					//TAMANHO (METADE) DE CADA BLOQUINHO
	var _le = _nl <= 4 ? 17 : 11.5;				//ESPAÇO ENTRE ELES
	var _lmeio = (_px1 + _px2) / 2;
	var _todas = letras_completas();
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	for(var i = 0; i < array_length(global.letras); i++)
	{
		global.letra_pop[i] = lerp(global.letra_pop[i], 1, .12);
		var _lx = _lmeio + (i - (_nl - 1) / 2) * _le;
		var _ly = _sy + 215.5;
		//FESTA DA PALAVRA COMPLETA: UMA ONDA PASSA PULANDO AS LETRAS DA ESQUERDA PRA DIREITA (DUAS VEZES) E ELAS INCHAM
		var _festa = global.palavra_festa > 0;
		if(_festa)
		{
			var _q = frac((1 - global.palavra_festa / PALAVRA_FESTA) * 2) * 1.6 - i * .1;
			if(_q > 0 and _q < 1) { _ly -= sin(_q * pi) * 8; global.letra_pop[i] = max(global.letra_pop[i], 1 + sin(_q * pi) * .6); }
		}
		var _h = _lt * global.letra_pop[i];
		var _ts = _lt / 10;	//ESCALA DA LETRA
		//LETRA PEGA: BLOQUINHO COLORIDO COM LUZ EM CIMA E NA ESQUERDA
		if(global.letras[i])
		{
			var _c = _cores_l[i];
			if(_todas and (current_time div 120) mod 2 == 0) _c = c_white; //PEGOU TODAS: PISCA
			if(_festa) _c = merge_color(_c, #FFE600, .5 + .5 * sin(current_time / 60 + i));	//NA FESTA VAI PRO DOURADO
			draw_set_color(merge_color(_c, c_black, .5));
			draw_rectangle(_lx - _h, _ly - _h, _lx + _h, _ly + _h, false);
			draw_set_color(_c);
			draw_rectangle(_lx - _h, _ly - _h, _lx + _h - 1, _ly + _h - 1, false);
			draw_set_color(merge_color(_c, c_white, .55));
			draw_rectangle(_lx - _h, _ly - _h, _lx + _h - 1, _ly - _h, false);
			draw_rectangle(_lx - _h, _ly - _h, _lx - _h, _ly + _h - 1, false);
			draw_text_transformed_color(_lx, _ly, global.letras_nomes[i], _ts * global.letra_pop[i], _ts * global.letra_pop[i], 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
		}
		else
		{
			//LETRA QUE FALTA: BLOQUINHO APAGADO
			draw_set_color(#1A1932);
			draw_rectangle(_lx - _lt, _ly - _lt, _lx + _lt, _ly + _lt, false);
			draw_set_color(#424C6E);
			draw_rectangle(_lx - _lt, _ly - _lt, _lx + _lt, _ly + _lt, true);
			draw_text_transformed_color(_lx, _ly, global.letras_nomes[i], _ts, _ts, 0, #424C6E, #424C6E, #424C6E, #424C6E, 1);
		}
	}

	//FESTA DA PALAVRA COMPLETA: BRILHO DOURADO EM VOLTA DO PAINEL DAS LETRAS, FAISCAS E O NOME DA PALAVRA EM CIMA
	if(global.palavra_festa > 0)
	{
		var _pf = 1 - global.palavra_festa / PALAVRA_FESTA;
		var _ab = 3 + sin(current_time / 70) * 2;
		gpu_set_blendmode(bm_add);
		draw_set_alpha(.35 * (1 - _pf * .5));
		draw_set_color(#FFB21E);
		draw_rectangle(_px1 - _ab, _sy + 205 - _ab, _px2 + _ab, _sy + 226 + _ab, false);
		draw_set_alpha(1);
		draw_set_color(#FFE66B);
		for(var k = 0; k < 10; k++)
		{
			var _fa = k * 36 + current_time / 6;
			var _fd = 20 + ((current_time / 20 + k * 7) mod 30);
			var _fx = _lmeio + lengthdir_x(_fd * 1.6, _fa), _fy = _sy + 215 + lengthdir_y(_fd * .6, _fa);
			draw_rectangle(_fx, _fy, _fx + 1, _fy + 1, false);
		}
		gpu_set_blendmode(bm_normal);
		var _palavra = "";
		for(var k = 0; k < array_length(global.letras_nomes); k++) _palavra += global.letras_nomes[k];
		var _pe = 1 + .25 * max(0, 1 - _pf * 4);	//ENTRA GRANDE E ASSENTA
		draw_text_transformed_color(_lmeio + 1, _sy + 196, _palavra + "!", _pe, _pe, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
		draw_text_transformed_color(_lmeio, _sy + 195, _palavra + "!", _pe, _pe, 0, #FFE66B, #FFE66B, #FFB21E, #FFB21E, 1);
	}

	//PODERES: OS 8 PODERES DO JOGO NUMA GRADE. OS QUE TEM FICAM ACESOS NA COR DELES (COM A BARRA DO REFLEXO
	//E DO ESCUDO EMBAIXO DO ICONE). OS QUE FALTAM FICAM SO A SOMBRA
	var _lista = global.poderes_lista;
	for(var i = 0; i < array_length(_lista); i++)
	{
		//PODER NOVO: O ICONE DA UM "POP"
		if(tem_poder(_lista[i].id) and !array_contains(poderes_antes, _lista[i].id)) poder_pop[i] = 1.6;
		poder_pop[i] = lerp(poder_pop[i], 1, .12);
	}
	//GUARDA OS PODERES DESSE FRAME PRA COMPARAR NO PROXIMO
	poderes_antes = array_create(0);
	array_copy(poderes_antes, 0, global.poderes, 0, array_length(global.poderes));
	//PAINEL DOS PODERES (4 POR LINHA) COM A FAIXA DE TITULO
	var _gy = _sy + 233;
	var _linhas = ceil(array_length(_lista) / 4);
	hud_painel(_px1, _gy, _px2, _gy + 14 + _linhas * 19);
	hud_faixa(_px1 + 1, _gy + 1, _px2 - 1, global.linguagem == 0 ? "PODERES" : "POWERS", #7A1450, #B8247A, #FF4FB0);
	for(var i = 0; i < array_length(_lista); i++)
	{
		var _pid = _lista[i].id;
		var _tem = tem_poder(_pid);
		//POSIÇAO DO ICONE NA GRADE
		var _bx = _px1 + 4 + (i mod 4) * 20 + 8;
		var _by = _gy + 14 + (i div 4) * 19 + 8;
		var _h = 8 * poder_pop[i];
		var _pcor = _lista[i].cor;
		//TEM: CAIXINHA NA COR DO PODER COM O ICONE
		if(_tem)
		{
			draw_set_color(merge_color(_pcor, #0E071B, .75));
			draw_rectangle(_bx - _h, _by - _h, _bx + _h, _by + _h, false);
			draw_set_color(_pcor);
			draw_rectangle(_bx - _h, _by - _h, _bx + _h, _by + _h, true);
			hud_icone(_pid, _bx - 4, _by - 5, _pcor, false);
			//REFLEXO E ESCUDO: BARRINHA DE ENERGIA/RESISTENCIA EMBAIXO
			var _barra = -1, _quebrado = false;
			if(_pid == "reflexo" and instance_exists(obj_player)) _barra = obj_player.reflexo_energia;
			if(_pid == "escudo" and instance_exists(obj_player)) { _barra = obj_player.escudo_vida; _quebrado = obj_player.escudo_quebrado; }
			if(_barra >= 0)
			{
				draw_set_color(#0E071B);
				draw_rectangle(_bx - 6, _by + 5, _bx + 6, _by + 6, false);
				draw_set_color(_quebrado ? #7A3030 : c_white);
				draw_rectangle(_bx - 6, _by + 5, _bx - 6 + 12 * _barra / 100, _by + 6, false);
			}
		}
		else
		{
			//NAO TEM: SO A SOMBRA DO ICONE
			draw_set_color(#1A1932);
			draw_rectangle(_bx - 8, _by - 8, _bx + 8, _by + 8, false);
			draw_set_color(#2E2A4A);
			draw_rectangle(_bx - 8, _by - 8, _bx + 8, _by + 8, true);
			hud_icone(_pid, _bx - 4, _by - 5, #2E2A4A, true);
		}
	}
	draw_set_color(c_white);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);

	//AVISO DO MODO DE TESTE
	if(IMORTAL) draw_text_transformed_color(_px1, _sy + 312, "IMORTAL (TESTE)", .5, .5, 0, c_lime, c_lime, c_lime, c_lime, 1);

	//VISAO ESPIRITUAL: AVISA QUE O PROXIMO A NASCER E UM INIMIGO (OU UMA BOMBA)
	if(tem_poder("visao") and (global.prox_especie == "inimigo" or global.prox_especie == "bomba") and instance_exists(obj_area))
	{
		var _vx = obj_area.x + obj_area.sprite_width / 2;
		var _vy = obj_area.y + 14 + sin(current_time / 120) * 2;
		draw_set_halign(fa_center);
		var _vt = global.linguagem == 0 ? "! INIMIGO VINDO !" : "! ENEMY INCOMING !";
		if(global.prox_especie == "bomba") _vt = global.linguagem == 0 ? "! BOMBA VINDO !" : "! BOMB INCOMING !";
		draw_text_transformed_color(_vx + 1, _vy + 1, _vt, .8, .8, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
		draw_text_transformed_color(_vx, _vy, _vt, .8, .8, 0, #FF7AE0, #FF7AE0, #FF7AE0, #FF7AE0, .6 + .4 * sin(current_time / 90));
	}
	draw_set_valign(fa_top);
	draw_set_halign(fa_center);
}

//VOLTA O PADRAO DE DESENHO
draw_set_font(-1);
draw_set_valign(-1);
draw_set_halign(-1);



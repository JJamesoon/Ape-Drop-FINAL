//VERSUS: A TELA DOS DOIS JOGADORES (SCR_COOP)
if(vs) { versus_sel_desenhar(); exit; }

//TELA DE SELEÇAO NO ESTILO SUNSET RIDERS: OS 4 PERSONAGENS EM PAINEIS ALTOS LADO A LADO. CADA PAINEL TEM A FAIXA "1UP NOME"
//NA COR DO PERSONAGEM E O RETRATO GRANDE NUM FUNDO ESCURO DA MESMA COR. O ESCOLHIDO SOBE, ACENDE (LUZ, BRILHO PASSANDO E FAGULHAS),
//PISCA A MOLDURA E FAZ A CARA BRAVA; OS OUTROS FICAM MAIS ESCUROS E DE OLHO FECHADO. EMBAIXO DE CADA PAINEL O PERSONAGEM ANIMANDO
//(O BLOQUEADO E SO SILHUETA). AO CONFIRMAR: OS OUTROS CAEM E ESCURECEM, O ESCOLHIDO VAI PRO MEIO E O NOME CARIMBA NUMA FAIXA
var _centro_x = room_width / 2;
var _sombra = #0E071B;
var _pt = global.linguagem == 0;
var _confirmando = conf >= 0 or out_k > .02;

//FUNDO DO MENU (MAIS ESCURO PROS PAINEIS APARECEREM)
draw_sprite_ext(spr_menu_fundo, 0, _centro_x, room_height / 2, .6, .6, 0, c_white, 1);
draw_set_alpha(.55 + .2 * out_k);
draw_set_color(_sombra);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

//FEIXE DE LUZ DE CIMA NO PAINEL ESCOLHIDO (NA COR DO PERSONAGEM, SOMA COM O FUNDO)
var _total = array_length(global.skins);
for(var i = 0; i < _total; i++)
{
	if(ativa[i] < .02 or !global.pers_liberados[i]) continue;
	var _cl = selecao_cores(i);
	var _lx = x_personagem(i) + (i == conf_i ? sel_dx : 0);
	var _bal = sin(timer * 1.3) * 6;
	var _al = (.2 + .12 * out_k * (i == conf_i)) * ativa[i];
	var _col = merge_color(_cl[0], c_white, .25);
	gpu_set_blendmode(bm_add);
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_color(_lx - 8 + _bal * .3, 0, _col, _al);
	draw_vertex_color(_lx + 8 + _bal * .3, 0, _col, _al);
	draw_vertex_color(_lx - SEL_LARG * .75 + _bal, SEL_TOPO + SEL_ALT + 40, _col, 0);
	draw_vertex_color(_lx + SEL_LARG * .75 + _bal, SEL_TOPO + SEL_ALT + 40, _col, 0);
	draw_primitive_end();
	gpu_set_blendmode(bm_normal);
}

//FNT_HUD TEM ACENTO (A FNT_MINI_HUD NAO TEM Ç, Ã...)
draw_set_font(fnt_hud);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

//TITULO NUMA FAIXA (NO COOP: QUEM TA ESCOLHENDO, NA COR DELE, E AS TECLAS DOS DOIS). SOBE E SOME QUANDO CONFIRMA
var _ty = -out_k * 64;
var _titulo = _pt ? "ESCOLHA O SEU RECEPTÁCULO" : "CHOOSE YOUR VESSEL";
var _cor_t = c_white;
if(global.coop)
{
	_titulo = "PLAYER " + string(jogador_escolhendo) + ": " + _titulo;
	_cor_t = jogador_escolhendo == 2 ? COOP_COR_P2 : COOP_COR_P1;
	var _teclas = _pt ? "P1: WASD + J K L M      P2: SETAS + C X Z V      ESPAÇO: TELEPORTE" : "P1: WASD + J K L M      P2: ARROWS + C X Z V      SPACE: TELEPORT";
	draw_text_transformed_color(_centro_x, 58 + _ty, _teclas, .6, .6, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, 1);
}
var _tw = string_width(_titulo) / 2 + 18;
draw_set_color(_sombra);
draw_rectangle(_centro_x - _tw + 3, 27 + _ty, _centro_x + _tw + 3, 49 + _ty, false);
draw_set_color(#7A1020);
draw_rectangle(_centro_x - _tw, 24 + _ty, _centro_x + _tw, 46 + _ty, false);
draw_set_color(#C8323C);
draw_rectangle(_centro_x - _tw, 24 + _ty, _centro_x + _tw, 27 + _ty, false);
draw_set_color(c_white);
draw_rectangle(_centro_x - _tw, 24 + _ty, _centro_x + _tw, 46 + _ty, true);
draw_text_color(_centro_x + 1, 36 + _ty, _titulo, _sombra, _sombra, _sombra, _sombra, 1);
draw_text_color(_centro_x, 35 + _ty, _titulo, _cor_t, _cor_t, _cor_t, _cor_t, 1);

//MOEDAS GUARDADAS (CANTO DE CIMA)
draw_set_halign(fa_right);
draw_sprite(spr_moeda, current_time / 100, room_width - 30 - string_width(string(global.moedas)) - 12, 22 + _ty);
draw_text_color(room_width - 29, 23 + _ty, string(global.moedas), _sombra, _sombra, _sombra, _sombra, 1);
draw_text_color(room_width - 30, 22 + _ty, string(global.moedas), c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_center);

//OS PAINEIS
var _frame = get_timer() / 100000;
var _up = string(jogador_escolhendo) + "UP";
var _cor_jog = jogador_escolhendo == 2 ? COOP_COR_P2 : COOP_COR_P1;
//ORDEM DE DESENHO: QUANDO ALGUEM CONFIRMA, O PAINEL CONFIRMADO FICA POR ULTIMO (POR CIMA DOS OUTROS, JA QUE VAI PRO MEIO DA TELA)
var _ordem = [];
for(var k = 0; k < _total; k++) if(!(_confirmando and k == conf_i)) array_push(_ordem, k);
if(_confirmando) array_push(_ordem, conf_i);
for(var o = 0; o < _total; o++)
{
	var i = _ordem[o];
	var _sel = (i == indice);
	var _liberado = global.pers_liberados[i];
	var _c = selecao_cores(i);	//[FAIXA, FUNDO, MOLDURA DE DENTRO]
	var _eh_conf = _confirmando and i == conf_i;		//O PAINEL QUE FOI CONFIRMADO
	var _cx = x_personagem(i) + (_eh_conf ? sel_dx : 0);
	var _queda = (_confirmando and !_eh_conf) ? out_k * 26 : 0;	//OS OUTROS CAEM UM POUCO
	var _x1 = _cx - SEL_LARG / 2 + (_sel ? random_range(-shake_msg, shake_msg) : 0);
	var _x2 = _x1 + SEL_LARG;
	var _y1 = SEL_TOPO - painel_sobe[i] + _queda;
	var _y2 = _y1 + SEL_ALT;
	var _escuro = _sel ? c_white : #8C8C9C;	//OS NAO ESCOLHIDOS FICAM MAIS APAGADOS
	if(_confirmando and !_eh_conf) _escuro = merge_color(_escuro, #3A3550, out_k * .8);

	//SOMBRA E LUZ EM VOLTA DO PAINEL ESCOLHIDO (HALO NA COR DELE QUE PULSA)
	draw_set_color(_sombra);
	draw_rectangle(_x1 - 2 + 4, _y1 - 2 + 4, _x2 + 2 + 4, _y2 + 2 + 4, false);
	if(ativa[i] > .02 and _liberado)
	{
		var _pulso = .5 + .5 * sin(timer * 2.4);
		gpu_set_blendmode(bm_add);
		draw_set_color(_c[0]);
		for(var g = 1; g <= 6; g++)
		{
			draw_set_alpha((.34 + .22 * _pulso + .3 * (_eh_conf ? out_k : 0)) * ativa[i] * (1 - g / 7));
			draw_rectangle(_x1 - 3 - g * 2, _y1 - 3 - g * 2, _x2 + 3 + g * 2, _y2 + 3 + g * 2, true);
		}
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	}

	//MOLDURA BRANCA (A DO ESCOLHIDO PISCA NA COR DO JOGADOR; AO CONFIRMAR PISCA DOURADA)
	var _mold = (_sel and (current_time div 180) mod 2 == 0) ? _cor_jog : c_white;
	if(_eh_conf and conf >= 0) _mold = ((conf div 3) mod 2 == 0) ? #FFE66B : c_white;
	draw_set_color(merge_color(_mold, _sombra, _sel ? 0 : .35));
	draw_rectangle(_x1 - 3, _y1 - 3, _x2 + 3, _y2 + 3, false);

	//FUNDO: A COR DO PERSONAGEM, ESCURECENDO PRA BAIXO, COM UM BRILHO ATRAS DO RETRATO
	var _fundo = merge_color(_c[1], _sombra, _sel ? 0 : .35);
	draw_rectangle_colour(_x1, _y1, _x2, _y2, _fundo, _fundo, merge_color(_fundo, _sombra, .55), merge_color(_fundo, _sombra, .55), false);
	draw_set_alpha((_sel ? .35 : .15) + (_eh_conf ? .25 * out_k : 0));
	draw_set_color(merge_color(_c[0], c_white, .3));
	draw_circle(_cx, _y2 - 70, 52 + (_sel ? sin(timer * 2) * 3 : 0) + (_eh_conf ? 14 * out_k : 0), false);
	draw_set_alpha(1);

	//RETRATO GRANDE SAINDO DE BAIXO DO PAINEL (ESCOLHIDO: CARA BRAVA; OS OUTROS: OLHO FECHADO; BLOQUEADO: SILHUETA)
	//AO CONFIRMAR: GRITA ("GRITANDO") E DEPOIS VOLTA PRA CARA BRAVA
	var _perfil = global.skins[i].perfil;
	var _pe = SEL_RETRATO * esc[i];
	var _px = _cx - sprite_get_width(_perfil) * _pe / 2;
	var _py = _y2 - sprite_get_height(_perfil) * _pe;
	var _pf = _sel ? 0 : 2;
	if(_eh_conf and conf >= 0 and conf < 40) _pf = min(1, sprite_get_number(_perfil) - 1);
	if(_liberado) draw_sprite_ext(_perfil, _pf, _px, _py, _pe, _pe, 0, _escuro, 1);
	else
	{
		gpu_set_fog(true, _sombra, 0, 1);
		draw_sprite_ext(_perfil, 2, _px, _py, _pe, _pe, 0, c_white, .85);
		gpu_set_fog(false, c_white, 0, 1);
	}

	//BRILHO QUE PASSA NA DIAGONAL PELO PAINEL ESCOLHIDO (TIRAS FINAS, PRA NAO SAIR DO PAINEL)
	if(_sel and _liberado and conf < 0)
	{
		var _p = ((brilho_t mod 170) / 170) * 1.7 - .35;
		var _bx = _x1 + (_x2 - _x1) * _p;
		gpu_set_blendmode(bm_add);
		draw_set_color(c_white);
		draw_set_alpha(.17);
		for(var yy = _y1 + 21; yy < _y2 - 1; yy += 2)
		{
			var _sk = (yy - _y1) * .35;
			var _a1 = clamp(_bx - _sk, _x1 + 2, _x2 - 2);
			var _a2 = clamp(_bx - _sk + 18, _x1 + 2, _x2 - 2);
			if(_a2 > _a1) draw_rectangle(_a1, yy, _a2, yy + 1, false);
		}
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	}

	//MOLDURA DE DENTRO NA COR CLARA DO PERSONAGEM (POR CIMA DO RETRATO, PRA ELE FICAR "DENTRO" DO PAINEL)
	draw_set_color(merge_color(_c[2], _sombra, _sel ? 0 : .35));
	draw_rectangle(_x1, _y1, _x2, _y2, true);
	draw_rectangle(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, true);

	//FAIXA DE CIMA: "1UP" E O NOME
	var _faixa = merge_color(_c[0], _sombra, _sel ? 0 : .35);
	draw_set_color(_faixa);
	draw_rectangle(_x1, _y1, _x2, _y1 + 20, false);
	draw_set_color(merge_color(_faixa, c_white, .45));
	draw_rectangle(_x1, _y1, _x2, _y1 + 2, false);
	draw_set_color(merge_color(_faixa, _sombra, .35));
	draw_rectangle(_x1, _y1 + 18, _x2, _y1 + 20, false);
	draw_set_halign(fa_left);
	var _cup = merge_color(_faixa, _sombra, .65);	//"1UP" NUM TOM ESCURO DA FAIXA
	draw_text_transformed_color(_x1 + 6, _y1 + 10, _up, .75, .75, 0, _cup, _cup, _cup, _cup, 1);
	draw_set_halign(fa_right);
	var _nome = string_upper(global.skins[i].nome);
	draw_text_transformed_color(_x2 - 5, _y1 + 11, _nome, .9, .9, 0, _sombra, _sombra, _sombra, _sombra, .6);
	draw_text_transformed_color(_x2 - 6, _y1 + 10, _nome, .9, .9, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_halign(fa_center);

	//BLOQUEADO: AVISO NO MEIO DO PAINEL E O PREÇO
	if(!_liberado)
	{
		var _preco = string(global.skins[i].preco);
		var _pode = global.moedas >= global.skins[i].preco;
		var _cp = _pode ? c_yellow : #92A1B9;
		draw_set_color(_sombra);
		draw_set_alpha(.75);
		draw_rectangle(_x1 + 2, _y1 + 58, _x2 - 2, _y1 + 98, false);
		draw_set_alpha(1);
		draw_text_transformed_color(_cx, _y1 + 69, texto("bloqueado"), .8, .8, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, 1);
		draw_sprite_ext(spr_moeda, current_time / 100, _cx - string_width(_preco) / 2 - 10, _y1 + 87, .8, .8, 0, c_white, 1);
		draw_text_color(_cx + 1, _y1 + 88, _preco, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_color(_cx, _y1 + 87, _preco, _cp, _cp, _cp, _cp, 1);
	}

	//COOP: ETIQUETA EM QUEM O PLAYER 1 JA ESCOLHEU
	if(global.coop and jogador_escolhendo == 2 and i == global.skin_player_1)
	{
		draw_set_color(COOP_COR_P1);
		draw_rectangle(_x1 + 4, _y1 + 25, _x1 + 26, _y1 + 37, false);
		draw_text_transformed_color(_x1 + 15, _y1 + 31, "P1", .7, .7, 0, _sombra, _sombra, _sombra, _sombra, 1);
	}

	//SETINHA DO JOGADOR EM CIMA DO ESCOLHIDO (SOME QUANDO CONFIRMA)
	if(_sel and out_k < .5)
	{
		var _ay = _y1 - 10 + sin(timer * 3) * 2;
		var _ax = _cx;
		draw_set_color(_sombra);
		draw_triangle(_ax - 7 + 1, _ay - 6 + 1, _ax + 7 + 1, _ay - 6 + 1, _ax + 1, _ay + 2 + 1, false);
		draw_set_color(_cor_jog);
		draw_triangle(_ax - 7, _ay - 6, _ax + 7, _ay - 6, _ax, _ay + 2, false);
	}

	//OS OUTROS PAINEIS ESCURECEM POR CIMA QUANDO ALGUEM CONFIRMA
	if(_confirmando and !_eh_conf)
	{
		draw_set_alpha(out_k * .72);
		draw_set_color(_sombra);
		draw_rectangle(_x1 - 3, _y1 - 3, _x2 + 3, _y2 + 3, false);
		draw_set_alpha(1);
	}

	//EMBAIXO: O PERSONAGEM ANIMANDO EM CIMA DE UMA SOMBRINHA (AO CONFIRMAR: DA UM PULO COM O PAINEL)
	var _spr = skin_sprite(i, spr_player_idle);
	var _pulo = 0;
	var _se = _sel ? 2.6 : 2.2;
	if(_eh_conf and conf >= 0) _se = lerp(2.6, 3.2, out_k);	//CRESCE UM POUCO (SEM PULAR)
	var _ix = _cx, _iy = SEL_TOPO + SEL_ALT + 52 + (_sel ? sin(timer) * 2 : 0) + _queda - _pulo;
	draw_set_alpha(.5 * (1 - _pulo / 40));
	draw_set_color(_sombra);
	draw_ellipse(_ix - 18, SEL_TOPO + SEL_ALT + 49 + _queda, _ix + 18, SEL_TOPO + SEL_ALT + 56 + _queda, false);
	draw_set_alpha(1);
	if(_liberado) draw_sprite_ext(_spr, (_sel and _pulo <= 3) ? _frame : 0, _ix, _iy, _se, _se, 0, _escuro, 1);
	else
	{
		gpu_set_fog(true, #1A1932, 0, 1);
		draw_sprite_ext(_spr, 0, _ix, _iy, _se, _se, 0, c_white, 1);
		gpu_set_fog(false, c_white, 0, 1);
	}
}

//ANEIS DE ONDA E FAGULHAS (POR CIMA DOS PAINEIS)
gpu_set_blendmode(bm_add);
for(var i = 0; i < array_length(aneis); i++)
{
	var _an = aneis[i];
	if(_an.atraso > 0) continue;
	draw_set_color(_an.cor);
	draw_set_alpha(clamp(_an.a, 0, 1) * .8);
	draw_circle(_an.x, _an.y, _an.r, true);
	draw_circle(_an.x, _an.y, _an.r - 2, true);
}
gpu_set_blendmode(bm_normal);
for(var i = 0; i < array_length(fagulhas); i++)
{
	var _f = fagulhas[i];
	draw_set_alpha(clamp(_f.life / (_f.dur * .5), 0, 1));
	draw_set_color(_f.cor);
	draw_rectangle(_f.x - _f.t / 2, _f.y - _f.t / 2, _f.x + _f.t / 2, _f.y + _f.t / 2, false);
}
draw_set_alpha(1);

//FAIXA COM O NOME DO ESCOLHIDO (CARIMBA: ENTRA DE LADO E O NOME CAI GRANDE E ASSENTA)
if(conf >= 0)
{
	var _cn = selecao_cores(conf_i);
	var _ini = conf_longo ? 14 : 7;
	var _fy = 344;
	var _entra = ease_back(clamp((conf - _ini + 8) / 12, 0, 1));
	var _fx = (1 - clamp(_entra, 0, 1)) * -room_width;
	draw_set_color(_sombra);
	draw_set_alpha(.88);
	draw_rectangle(_fx, _fy, _fx + room_width, _fy + 46, false);
	draw_set_alpha(1);
	draw_set_color(_cn[0]);
	draw_rectangle(_fx, _fy, _fx + room_width, _fy + 3, false);
	draw_rectangle(_fx, _fy + 43, _fx + room_width, _fy + 46, false);
	draw_set_color(c_white);
	draw_rectangle(_fx, _fy + 3, _fx + room_width, _fy + 4, false);
	draw_rectangle(_fx, _fy + 42, _fx + room_width, _fy + 43, false);

	var _kp = clamp((conf - _ini) / 14, 0, 1);
	if(conf >= _ini)
	{
		var _ee = ease_back(_kp);
		var _esc = lerp(4.2, 1.7, _ee);
		var _nm = string_upper(global.skins[conf_i].nome);
		if(global.coop) _nm = "P" + string(jogador_escolhendo) + "  " + _nm;
		var _ac = clamp(_kp * 3, 0, 1);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed_color(_centro_x + 2, _fy + 19 + 2, _nm, _esc, _esc, 0, _sombra, _sombra, _sombra, _sombra, _ac);
		draw_text_transformed_color(_centro_x - 1, _fy + 19, _nm, _esc, _esc, 0, _cn[0], _cn[0], _cn[0], _cn[0], _ac);
		draw_text_transformed_color(_centro_x, _fy + 18, _nm, _esc, _esc, 0, c_white, c_white, c_white, c_white, _ac);
		//SUBTITULO
		var _sub = global.coop ? (_pt ? "PLAYER " + string(jogador_escolhendo) + " PRONTO!" : "PLAYER " + string(jogador_escolhendo) + " READY!") : (_pt ? "O ESCOLHIDO" : "THE CHOSEN ONE");
		var _as = clamp((conf - _ini - 8) / 8, 0, 1);
		draw_text_transformed_color(_centro_x, _fy + 36, _sub, .7, .7, 0, #FFE66B, #FFE66B, #FFE66B, #FFE66B, _as);
	}
}

//DICAS (SOMEM QUANDO CONFIRMA)
var _confirmar = global.pers_liberados[indice] ? (_pt ? "ESPAÇO CONFIRMAR" : "SPACE CONFIRM") : texto("comprar");
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed_color(_centro_x, room_height - 16, (_pt ? "A/D ESCOLHER" : "A/D CHOOSE") + "    " + _confirmar + "    " + (_pt ? "ESC VOLTAR" : "ESC BACK"), .8, .8, 0, c_white, c_white, c_white, c_white, .7 * (1 - out_k));

//CLARAO DA CONFIRMAÇAO
if(flash > .01)
{
	draw_set_alpha(flash * .75);
	draw_set_color(c_white);
	draw_rectangle(0, 0, room_width, room_height, false);
	draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

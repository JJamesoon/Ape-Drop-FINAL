//TELA DE SELEÇAO NO ESTILO SUNSET RIDERS: OS 4 PERSONAGENS EM PAINEIS ALTOS LADO A LADO. CADA PAINEL TEM A FAIXA "1UP NOME"
//NA COR DO PERSONAGEM E O RETRATO GRANDE NUM FUNDO ESCURO DA MESMA COR. O ESCOLHIDO SOBE, PISCA A MOLDURA E FAZ A CARA BRAVA;
//OS OUTROS FICAM MAIS ESCUROS E DE OLHO FECHADO. EMBAIXO DE CADA PAINEL O PERSONAGEM ANIMANDO (O BLOQUEADO E SO SILHUETA)
var _centro_x = room_width / 2;
var _sombra = #0E071B;
var _pt = global.linguagem == 0;

//FUNDO DO MENU (MAIS ESCURO PROS PAINEIS APARECEREM)
draw_sprite_ext(spr_menu_fundo, 0, _centro_x, room_height / 2, .6, .6, 0, c_white, 1);
draw_set_alpha(.55);
draw_set_color(_sombra);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

//FNT_HUD TEM ACENTO (A FNT_MINI_HUD NAO TEM Ç, Ã...)
draw_set_font(fnt_hud);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

//TITULO NUMA FAIXA (NO COOP: QUEM TA ESCOLHENDO, NA COR DELE, E AS TECLAS DOS DOIS)
var _titulo = _pt ? "ESCOLHA SEU PERSONAGEM" : "CHOOSE YOUR CHARACTER";
var _cor_t = c_white;
if(global.coop)
{
	_titulo = "PLAYER " + string(jogador_escolhendo) + ": " + _titulo;
	_cor_t = jogador_escolhendo == 2 ? COOP_COR_P2 : COOP_COR_P1;
	var _teclas = _pt ? "P1: WASD + J K L M      P2: SETAS + C X Z V      ESPAÇO: TELEPORTE" : "P1: WASD + J K L M      P2: ARROWS + C X Z V      SPACE: TELEPORT";
	draw_text_transformed_color(_centro_x, 58, _teclas, .6, .6, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, 1);
}
var _tw = string_width(_titulo) / 2 + 18;
draw_set_color(_sombra);
draw_rectangle(_centro_x - _tw + 3, 27, _centro_x + _tw + 3, 49, false);
draw_set_color(#7A1020);
draw_rectangle(_centro_x - _tw, 24, _centro_x + _tw, 46, false);
draw_set_color(#C8323C);
draw_rectangle(_centro_x - _tw, 24, _centro_x + _tw, 27, false);
draw_set_color(c_white);
draw_rectangle(_centro_x - _tw, 24, _centro_x + _tw, 46, true);
draw_text_color(_centro_x + 1, 36, _titulo, _sombra, _sombra, _sombra, _sombra, 1);
draw_text_color(_centro_x, 35, _titulo, _cor_t, _cor_t, _cor_t, _cor_t, 1);

//MOEDAS GUARDADAS (CANTO DE CIMA)
draw_set_halign(fa_right);
draw_sprite(spr_moeda, current_time / 100, room_width - 30 - string_width(string(global.moedas)) - 12, 22);
draw_text_color(room_width - 29, 23, string(global.moedas), _sombra, _sombra, _sombra, _sombra, 1);
draw_text_color(room_width - 30, 22, string(global.moedas), c_yellow, c_yellow, c_yellow, c_yellow, 1);
draw_set_halign(fa_center);

//OS PAINEIS
var _total = array_length(global.skins);
var _frame = get_timer() / 100000;
var _up = string(jogador_escolhendo) + "UP";
var _cor_jog = jogador_escolhendo == 2 ? COOP_COR_P2 : COOP_COR_P1;
for(var i = 0; i < _total; i++)
{
	var _sel = (i == indice);
	var _liberado = global.pers_liberados[i];
	var _c = selecao_cores(i);	//[FAIXA, FUNDO, MOLDURA DE DENTRO]
	var _x1 = x_personagem(i) - SEL_LARG / 2 + (_sel ? random_range(-shake_msg, shake_msg) : 0);
	var _x2 = _x1 + SEL_LARG;
	var _y1 = SEL_TOPO - painel_sobe[i];
	var _y2 = _y1 + SEL_ALT;
	var _escuro = _sel ? c_white : #8C8C9C;	//OS NAO ESCOLHIDOS FICAM MAIS APAGADOS

	//SOMBRA E MOLDURA BRANCA (A DO ESCOLHIDO PISCA NA COR DO JOGADOR)
	draw_set_color(_sombra);
	draw_rectangle(_x1 - 2 + 4, _y1 - 2 + 4, _x2 + 2 + 4, _y2 + 2 + 4, false);
	var _mold = (_sel and (current_time div 180) mod 2 == 0) ? _cor_jog : c_white;
	draw_set_color(merge_color(_mold, _sombra, _sel ? 0 : .35));
	draw_rectangle(_x1 - 3, _y1 - 3, _x2 + 3, _y2 + 3, false);

	//FUNDO: A COR DO PERSONAGEM, ESCURECENDO PRA BAIXO, COM UM BRILHO ATRAS DO RETRATO
	var _fundo = merge_color(_c[1], _sombra, _sel ? 0 : .35);
	draw_rectangle_colour(_x1, _y1, _x2, _y2, _fundo, _fundo, merge_color(_fundo, _sombra, .55), merge_color(_fundo, _sombra, .55), false);
	draw_set_alpha(_sel ? .35 : .15);
	draw_set_color(merge_color(_c[0], c_white, .3));
	draw_circle(x_personagem(i), _y2 - 70, 52 + (_sel ? sin(timer * 2) * 3 : 0), false);
	draw_set_alpha(1);

	//RETRATO GRANDE SAINDO DE BAIXO DO PAINEL (ESCOLHIDO: CARA BRAVA; OS OUTROS: OLHO FECHADO; BLOQUEADO: SILHUETA)
	var _perfil = global.skins[i].perfil;
	var _pe = SEL_RETRATO * esc[i];
	var _px = x_personagem(i) - sprite_get_width(_perfil) * _pe / 2;
	var _py = _y2 - sprite_get_height(_perfil) * _pe;
	var _pf = _sel ? 0 : 2;
	if(_liberado) draw_sprite_ext(_perfil, _pf, _px, _py, _pe, _pe, 0, _escuro, 1);
	else
	{
		gpu_set_fog(true, _sombra, 0, 1);
		draw_sprite_ext(_perfil, 2, _px, _py, _pe, _pe, 0, c_white, .85);
		gpu_set_fog(false, c_white, 0, 1);
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
		draw_text_transformed_color(x_personagem(i), _y1 + 69, texto("bloqueado"), .8, .8, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, 1);
		draw_sprite_ext(spr_moeda, current_time / 100, x_personagem(i) - string_width(_preco) / 2 - 10, _y1 + 87, .8, .8, 0, c_white, 1);
		draw_text_color(x_personagem(i) + 1, _y1 + 88, _preco, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_color(x_personagem(i), _y1 + 87, _preco, _cp, _cp, _cp, _cp, 1);
	}

	//COOP: ETIQUETA EM QUEM O PLAYER 1 JA ESCOLHEU
	if(global.coop and jogador_escolhendo == 2 and i == global.skin_player_1)
	{
		draw_set_color(COOP_COR_P1);
		draw_rectangle(_x1 + 4, _y1 + 25, _x1 + 26, _y1 + 37, false);
		draw_text_transformed_color(_x1 + 15, _y1 + 31, "P1", .7, .7, 0, _sombra, _sombra, _sombra, _sombra, 1);
	}

	//SETINHA DO JOGADOR EM CIMA DO ESCOLHIDO
	if(_sel)
	{
		var _ay = _y1 - 10 + sin(timer * 3) * 2;
		var _ax = x_personagem(i);
		draw_set_color(_sombra);
		draw_triangle(_ax - 7 + 1, _ay - 6 + 1, _ax + 7 + 1, _ay - 6 + 1, _ax + 1, _ay + 2 + 1, false);
		draw_set_color(_cor_jog);
		draw_triangle(_ax - 7, _ay - 6, _ax + 7, _ay - 6, _ax, _ay + 2, false);
	}

	//EMBAIXO: O PERSONAGEM ANIMANDO EM CIMA DE UMA SOMBRINHA
	var _spr = skin_sprite(i, spr_player_idle);
	var _ix = x_personagem(i), _iy = SEL_TOPO + SEL_ALT + 52 + (_sel ? sin(timer) * 2 : 0);
	draw_set_alpha(.5);
	draw_set_color(_sombra);
	draw_ellipse(_ix - 18, SEL_TOPO + SEL_ALT + 49, _ix + 18, SEL_TOPO + SEL_ALT + 56, false);
	draw_set_alpha(1);
	var _se = _sel ? 2.6 : 2.2;
	if(_liberado) draw_sprite_ext(_spr, _sel ? _frame : 0, _ix, _iy, _se, _se, 0, _escuro, 1);
	else
	{
		gpu_set_fog(true, #1A1932, 0, 1);
		draw_sprite_ext(_spr, 0, _ix, _iy, _se, _se, 0, c_white, 1);
		gpu_set_fog(false, c_white, 0, 1);
	}
}

//DICAS
var _confirmar = global.pers_liberados[indice] ? (_pt ? "ESPAÇO CONFIRMAR" : "SPACE CONFIRM") : texto("comprar");
draw_text_transformed_color(_centro_x, room_height - 16, (_pt ? "A/D ESCOLHER" : "A/D CHOOSE") + "    " + _confirmar + "    " + (_pt ? "ESC VOLTAR" : "ESC BACK"), .8, .8, 0, c_white, c_white, c_white, c_white, .7);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

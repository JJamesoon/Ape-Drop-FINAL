//==================== MENU PRINCIPAL NOVO (OBJ_MENU_PRINCIPAL) ====================
//LISTA UNICA NA ESQUERDA (TODAS AS OPÇOES A VISTA, UMA EMBAIXO DA OUTRA), E NA DIREITA UM CARTAO QUE EXPLICA A OPÇAO SELECIONADA.
//EMBAIXO, A BARRA COM AS TECLAS DE CADA TELA. NAVEGAÇAO: CIMA/BAIXO (OU W/S), ESPAÇO/ENTER ESCOLHE, ESC VOLTA, E O MOUSE TAMBEM FUNCIONA.
//COOP E VERSUS SAEM DIRETO DA LISTA (SEM SUBMENU) E O "BLOCOS" ABRE A TABELA DOS BLOCOS.
//PRA VOLTAR AO MENU ANTIGO DE SPRITES SEM APAGAR CODIGO: MENU_NOVO = FALSE.
#macro MENU_NOVO		true
#macro MENU_LISTA_X		22		//X DO TEXTO DAS OPÇOES
#macro MENU_LISTA_Y		92		//Y DA PRIMEIRA OPÇAO
#macro MENU_LINHA		22		//ALTURA DE CADA OPÇAO
#macro MENU_GRUPO		9		//ESPAÇO EXTRA ENTRE UM GRUPO E OUTRO
#macro MENU_PAINEL_X	286		//ONDE TERMINA O PAINEL ESCURO DA ESQUERDA (NO TOPO; A BORDA E INCLINADA)

//AS OPÇOES, NA ORDEM. GRUPO SEPARA A LISTA EM BLOCOS. TAG E O SELO NA DIREITA DA LINHA. NOME/DESC: [PT, EN]
function menu_itens()
{
	return [
		{ id : "arcade", grupo : 0, tag : "1P",
			nome : ["ARCADE", "ARCADE"],
			desc : ["VOCÊ É O CAMPEÃO! SOBREVIVA A ESSES DESAFIOS E PROVE QUE NADA PODE PARAR O ESCOLHIDO.",
					"YOU ARE THE CHAMPION! SURVIVE THESE CHALLENGES AND PROVE THAT NOTHING CAN STOP THE CHOSEN ONE."] },
		{ id : "coop", grupo : 0, tag : "2P",
			nome : ["COOP", "CO-OP"],
			desc : ["TUDO EM DUPLA FICA MAIS LEGAL, ATÉ MESMO SOBREVIVER A UMA GRADE CHEIA DE DESAFIOS.",
					"EVERYTHING IS MORE FUN AS A PAIR, EVEN SURVIVING A GRID FULL OF CHALLENGES."] },
		{ id : "versus", grupo : 0, tag : "2P",
			nome : ["VERSUS", "VERSUS"],
			desc : ["DUELO DE 2 JOGADORES. AQUI É CADA MACACO NO SEU GALHO.",
					"A 2-PLAYER DUEL. HERE IT'S EVERY MONKEY ON ITS OWN BRANCH."] },
		{ id : "blocos", grupo : 1, tag : "",
			nome : ["BLOCOS", "BLOCKS"],
			desc : ["BLOCOS DESCOBERTOS.",
					"DISCOVERED BLOCKS."] },
		{ id : "ranks", grupo : 1, tag : "",
			nome : ["RECORDES", "RECORDS"],
			desc : ["OS MELHORES JOGADORES FICAM AQUI.",
					"THE BEST PLAYERS ARE HERE."] },
		{ id : "config", grupo : 2, tag : "",
			nome : ["CONFIGURAÇÕES", "SETTINGS"],
			desc : ["PERSONALIZE A SUA EXPERIÊNCIA.",
					"CUSTOMIZE YOUR EXPERIENCE."] },
		{ id : "creditos", grupo : 2, tag : "",
			nome : ["CRÉDITOS", "CREDITS"],
			desc : ["SOBRE OS CRIADORES.",
					"ABOUT THE CREATORS."] },
		{ id : "steam", grupo : 2, tag : "",
			nome : ["STEAM", "STEAM"],
			desc : ["ABRE A PÁGINA DO JOGO NA STEAM. VEJA AS NOVIDADES!",
					"OPENS THE GAME PAGE ON STEAM. SEE WHAT'S NEW!"] },
		{ id : "sair", grupo : 2, tag : "",
			nome : ["SAIR", "EXIT"],
			desc : ["AQUI FECHA O JOGO, VOCÊ NÃO QUER ISSO...",
					"THIS CLOSES THE GAME. YOU DON'T WANT THAT..."] },
	];
}

//CHAMADO NO CREATE DO OBJ_MENU_PRINCIPAL: ESTADO DA LISTA NOVA
function menu_novo_criar()
{
	global.versus_sel = false;
	global.teste_dif = false;	//O TESTE DE DIFICULDADE SO VALE ATE VOLTAR PRO MENU
	mn_itens = menu_itens();
	mn_n = array_length(mn_itens);
	mn_y = [];				//Y DE CADA OPÇAO
	mn_sel = [];			//0 A 1: QUANTO A OPÇAO ESTA DESTACADA (ANIMA)
	mn_ent = [];			//0 A 1: ENTRADA DESLIZANDO (ESCALONADA)
	var _y = MENU_LISTA_Y;
	for(var i = 0; i < mn_n; i++)
	{
		if(i > 0 and mn_itens[i].grupo != mn_itens[i - 1].grupo) _y += MENU_GRUPO;
		array_push(mn_y, _y);
		array_push(mn_sel, 0);
		array_push(mn_ent, 0);
		_y += MENU_LINHA;
	}
	mn_t = 0;				//FRAMES DESDE QUE A LISTA ABRIU
	mn_mx = -1;				//MOUSE (PRA SO REAGIR QUANDO ELE MEXE)
	mn_my = -1;
	mn_card = 0;			//0 A 1: O CARTAO "ACENDE" QUANDO TROCA DE OPÇAO
	mn_card_i = -1;
	mn_aviso = 0;			//FRAMES COM O AVISO "ABRINDO A STEAM"
	mn_conf_k = -99;		//QUAL LINHA DAS CONFIGURAÇOES O CARTAO ESTA MOSTRANDO (PRA ANIMAR NA TROCA)
	mn_card_h = -1;		//ALTURA DO CARTAO (ANIMA ATE O TAMANHO DO TEXTO; -1 = AINDA NAO CALCULOU)

	//NASCEU JA NO MENU PRINCIPAL (VOLTANDO DA SELEÇAO DE PERSONAGEM, ETC): TUDO JA PRONTO, SEM A ANIMAÇAO DE ENTRADA
	angle_title = 0;
	mn_estado_ant = estado;
	if(estado == menu.principal)
	{
		mn_t = 999;
		for(var i = 0; i < mn_n; i++) mn_ent[i] = 1;
		mn_card = 1;
		mn_card_i = indice;
		esc_fundo = .6;
		esc_fundo_lerp = .6;
		y_title = -100;
		alpha_title = 0;
		_alpha = 0;
		alpha_bg_blocos = 1;
	}
}

//A OPÇAO ESCOLHIDA (ESPAÇO / ENTER / CLIQUE)
function menu_novo_ativar(_id)
{
	switch(_id)
	{
		case "arcade":
			som_tocar(snd_menu_select_01);
			global.versus_sel = false;
			global.coop = false;
			scr_trans(rm_selecao);
			break;
		case "coop":
			som_tocar(snd_menu_select_01);
			global.versus_sel = false;
			global.coop = true;
			scr_trans(rm_selecao);
			break;
		case "versus":	//OS DOIS ESCOLHEM O PERSONAGEM NA MESMA TELA E A LUTA COMEÇA
			som_tocar(snd_menu_select_01);
			global.coop = false;
			global.versus_sel = true;
			scr_trans(rm_selecao);
			break;
		case "blocos":
			som_tocar(snd_menu_select_01);
			estado = menu.blocos;
			blocos_sel = 0;
			break;
		case "ranks":
			som_tocar(snd_menu_select_01);
			estado = menu.ranks;
			break;
		case "config":
			som_tocar(snd_menu_select_01);
			estado = menu.config;
			conf_sub = noone;
			conf_indice = 0;
			conf_resetar_anim();
			break;
		case "creditos":
			som_tocar(snd_menu_select_01);
			estado = menu.creditos;
			creditos_y = room_height + 15;
			alpha_img_creditos = 0;
			break;
		case "steam":
			url_open("https://store.steampowered.com/app/3495060/");
			som_tocar(snd_certo);
			mn_aviso = room_speed * 2;
			break;
		case "sair":
			jogo_salvar();
			game_end();
			break;
	}
}

//TODO FRAME COM O MENU PRINCIPAL ABERTO: NAVEGAÇAO (TECLADO E MOUSE) E ANIMAÇOES
function menu_novo_step(_up, _down, _enter, _voltar)
{
	//AS OPÇOES SO ENTRAM DESLIZANDO QUANDO VEM DA TELA DE TITULO (VOLTANDO DE OUTRA TELA JA ESTAO LA)
	if(mn_estado_ant != estado)
	{
		if(estado == menu.principal and mn_estado_ant == menu.inicio) mn_t = 0;
		mn_estado_ant = estado;
	}
	mn_t++;
	if(mn_aviso > 0) mn_aviso--;

	//MOUSE: PASSAR POR CIMA SELECIONA (SO SE ELE MEXEU), CLICAR ESCOLHE
	var _mexeu = (mouse_x != mn_mx or mouse_y != mn_my);
	mn_mx = mouse_x;
	mn_my = mouse_y;
	var _sobre = -1;
	for(var i = 0; i < mn_n; i++)
	{
		if(point_in_rectangle(mouse_x, mouse_y, 8, mn_y[i] - MENU_LINHA / 2, MENU_PAINEL_X - 40, mn_y[i] + MENU_LINHA / 2)) _sobre = i;
	}
	if(_mexeu and _sobre != -1 and _sobre != indice)
	{
		indice = _sobre;
		som_tocar(snd_menu_select_03);
	}
	var _clique = mouse_check_button_pressed(mb_left) and _sobre != -1;
	if(_clique) indice = _sobre;

	//TECLADO: CIMA/BAIXO DA A VOLTA NA LISTA
	if(_up xor _down)
	{
		indice = (indice + _down - _up + mn_n) mod mn_n;
		som_tocar(snd_menu_select_03);
	}

	if(_voltar)
	{
		som_tocar(snd_menu_erro_02);
		estado = menu.inicio;
		timer_inicio = 10;
	}
	else if((_enter or _clique) and timer_inicio <= 0) menu_novo_ativar(mn_itens[indice].id);

	//ANIMAÇOES
	for(var i = 0; i < mn_n; i++)
	{
		mn_sel[i] = lerp(mn_sel[i], indice == i ? 1 : 0, .25);
		mn_ent[i] = lerp(mn_ent[i], mn_t > i * 2 ? 1 : 0, .22);
	}
	if(mn_card_i != indice) { mn_card_i = indice; mn_card = 0; }
	mn_card = lerp(mn_card, 1, .22);
}

//QUEBRA O TEXTO EM LINHAS QUE CABEM NA LARGURA (NA FONTE E ESCALA ATUAIS)
function menu_quebrar(_txt, _larg, _esc)
{
	var _palavras = string_split(_txt, " ");
	var _linha = "", _res = "";
	for(var i = 0; i < array_length(_palavras); i++)
	{
		var _t = _linha == "" ? _palavras[i] : _linha + " " + _palavras[i];
		if(string_width(_t) * _esc > _larg and _linha != "")
		{
			_res += _linha + chr(10);
			_linha = _palavras[i];
		}
		else _linha = _t;
	}
	return _res + _linha;
}

//TEXTO COM SOMBRINHA ESCURA (LE EM QUALQUER FUNDO)
function menu_texto(_x, _y, _txt, _cor, _a, _esc = 1)
{
	draw_text_transformed_color(_x + 1, _y + 1, _txt, _esc, _esc, 0, #0E071B, #0E071B, #0E071B, #0E071B, _a);
	draw_text_transformed_color(_x, _y, _txt, _esc, _esc, 0, _cor, _cor, _cor, _cor, _a);
}

//A BARRA DE TECLAS EMBAIXO. _LISTA = [[TECLA, O QUE FAZ], ...]
function menu_dicas(_lista, _direita = false)
{
	draw_set_font(fnt_hud);
	draw_set_valign(fa_middle);
	var _esc = .8;
	var _larg = 0;
	var _ws = [], _wt = [];
	for(var i = 0; i < array_length(_lista); i++)
	{
		var _wk = string_width(_lista[i][0]) * _esc + 10;
		var _wx = string_width(_lista[i][1]) * _esc;
		array_push(_ws, _wk);
		array_push(_wt, _wx);
		_larg += _wk + 6 + _wx + (i < array_length(_lista) - 1 ? 22 : 0);
	}
	var _y = room_height - 15;
	var _x = _direita ? room_width - 32 - _larg : room_width / 2 - _larg / 2;	//_DIREITA = ENCOSTADA NO CANTO
	draw_set_alpha(.78);
	draw_set_color(#0E071B);
	draw_rectangle(_x - 12, _y - 11, _x + _larg + 12, _y + 11, false);
	draw_set_alpha(1);
	draw_set_color(#5A3A8A);
	draw_rectangle(_x - 12, _y - 11, _x + _larg + 12, _y + 11, true);
	draw_set_halign(fa_left);
	for(var i = 0; i < array_length(_lista); i++)
	{
		//A TECLA NUMA CAIXINHA E O QUE ELA FAZ AO LADO
		draw_set_color(#1E1A38);
		draw_rectangle(_x, _y - 7, _x + _ws[i], _y + 7, false);
		draw_set_color(#A98BE0);
		draw_rectangle(_x, _y - 7, _x + _ws[i], _y + 7, true);
		draw_text_transformed_color(_x + 5, _y + 1, _lista[i][0], _esc, _esc, 0, c_white, c_white, c_white, c_white, 1);
		_x += _ws[i] + 6;
		draw_text_transformed_color(_x, _y + 1, _lista[i][1], _esc, _esc, 0, #C7CFDD, #C7CFDD, #C7CFDD, #C7CFDD, 1);
		_x += _wt[i] + 22;
	}
	draw_set_color(c_white);
	draw_set_valign(fa_top);
}

//AS TECLAS DE CADA TELA DO MENU (CHAMADO NO DRAW)
function menu_dicas_estado()
{
	var _pt = global.linguagem == 0;
	var _setas = _pt ? "ESCOLHER" : "CHOOSE";
	var _ok = _pt ? "SELECIONAR" : "SELECT";
	var _volta = _pt ? "VOLTAR" : "BACK";
	switch(estado)
	{
		case menu.principal:
			menu_dicas([["SETAS", _setas], [_pt ? "ESPAÇO" : "SPACE", _ok], ["ESC", _pt ? "TELA INICIAL" : "TITLE"]]);
			break;
		case menu.config:
			menu_dicas([["SETAS", conf_sub == noone ? _setas : (_pt ? "ESCOLHER / MUDAR" : "CHOOSE / CHANGE")], [_pt ? "ESPAÇO" : "SPACE", _ok], ["ESC", _volta]]);
			break;
		case menu.blocos:
			menu_dicas([["SETAS", _setas], ["ESC", _volta]]);
			break;
		case menu.ranks:
		case menu.creditos:
			menu_dicas([["ESC", _volta]]);
			break;
		case menu.versus:
			menu_dicas([["SETAS", _setas], [_pt ? "ESPAÇO" : "SPACE", _ok], ["ESC", _volta]]);
			break;
	}
}

//PAINEL ESCURO DA ESQUERDA (BORDA INCLINADA) COM A LOGO. USADO NO MENU PRINCIPAL E NAS CONFIGURAÇOES
function menu_painel_esq()
{
	var _sombra = #0E071B;
	var _h = room_height;
	//O ANGULO DA LOGO VEM DO OBJ_MENU_PRINCIPAL. FORA DELE (PAUSA DO JOGO) BALANÇA SOZINHA, IGUAL
	var _ang = variable_instance_exists(id, "angle_title") ? angle_title : sin(current_time / 600) * 1.8;
	draw_set_color(_sombra);
	draw_set_alpha(.84);
	draw_triangle(0, 0, MENU_PAINEL_X, 0, MENU_PAINEL_X - 36, _h, false);
	draw_triangle(0, 0, MENU_PAINEL_X - 36, _h, 0, _h, false);
	draw_set_color(#A98BE0);
	draw_set_alpha(.9);
	draw_line_width(MENU_PAINEL_X, 0, MENU_PAINEL_X - 36, _h, 2);
	draw_set_alpha(1);
	//LOGO (BALANÇA DE LEVE)
	var _ls = 196 / sprite_get_width(spr_bg_ape);
	draw_sprite_ext(spr_bg_ape, 0, 128 + 1, 52 + 1, _ls, _ls, _ang * .6, _sombra, 1);
	draw_sprite_ext(spr_bg_ape, 0, 128, 52, _ls, _ls, _ang * .6, c_white, 1);
}

//A CAIXA DO CARTAO DA DIREITA (FUNDO, BORDA E FAIXA DO TITULO). _Y1 = TOPO, _H = ALTURA, _SLIDE = DESLOCAMENTO DO TEXTO NA TROCA
function menu_cartao_caixa(_y1, _h, _titulo, _a, _slide)
{
	var _x1 = 312, _x2 = room_width - 20, _y2 = _y1 + _h;
	draw_set_alpha(.84);
	draw_set_color(#0E071B);
	draw_rectangle(_x1, _y1, _x2, _y2, false);
	draw_set_alpha(1);
	draw_set_color(#A98BE0);
	draw_rectangle(_x1, _y1, _x2, _y2, true);
	draw_rectangle(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, true);
	//FAIXA DO TITULO (2 TONS)
	draw_set_color(#5A3A8A);
	draw_rectangle(_x1 + 2, _y1 + 2, _x2 - 2, _y1 + 30, false);
	draw_set_color(#7A52B8);
	draw_rectangle(_x1 + 2, _y1 + 2, _x1 + 130, _y1 + 30, false);
	draw_set_font(fnt_table);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	menu_texto(_x1 + 12 + _slide, _y1 + 17, _titulo, #FFE66B, _a, 1);
	draw_set_font(fnt_hud);
	draw_set_valign(fa_top);
}

//DESENHO DO MENU PRINCIPAL NOVO (CHAMADO NO DRAW DO OBJ_MENU_PRINCIPAL SO NO ESTADO PRINCIPAL)
function menu_novo_draw()
{
	var _pt = global.linguagem == 0;
	var _l = global.linguagem == 0 ? 0 : 1;
	var _sombra = #0E071B;
	var _roxo = #A98BE0;
	var _h = room_height;

	//PAINEL ESCURO NA ESQUERDA + LOGO (PRA LISTA SEMPRE LER BEM)
	menu_painel_esq();

	//AS OPÇOES
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	for(var i = 0; i < mn_n; i++)
	{
		var _it = mn_itens[i];
		var _s = mn_sel[i];
		var _e = mn_ent[i];
		var _y = mn_y[i];
		var _a = _e;
		var _x = MENU_LISTA_X + _s * 8 - (1 - _e) * 70;
		//BARRA DA OPÇAO SELECIONADA (DEGRADE AMARELO -> LARANJA) E SETINHA QUE PULSA
		if(_s > .02)
		{
			draw_set_alpha(_a * _s);
			draw_rectangle_color(14 - (1 - _s) * 6, _y - 10, MENU_PAINEL_X - 56, _y + 10, #FFB21E, #FFE66B, #FFE66B, #FFB21E, false);
			var _bob = sin(current_time / 110) * 2;
			draw_set_color(#FFE66B);
			draw_triangle(5 + _bob, _y - 5, 5 + _bob, _y + 5, 11 + _bob, _y, false);
			draw_set_alpha(1);
		}
		var _cor = merge_color(#C7CFDD, #1B1038, _s);
		if(_s < .5) menu_texto(_x, _y + 1, _it.nome[_l], _cor, _a * (.8 + _s * .4));
		else draw_text_transformed_color(_x, _y + 1, _it.nome[_l], 1, 1, 0, _cor, _cor, _cor, _cor, _a);

		//SELO NA DIREITA: 1P / 2P
		var _tag = _it.tag;
		if(_tag != "")
		{
			var _tx = MENU_PAINEL_X - 62;
			draw_set_halign(fa_right);
			var _ct = merge_color(#92A1B9, #1B1038, _s);
			draw_text_transformed_color(_tx, _y + 1, _tag, .8, .8, 0, _ct, _ct, _ct, _ct, _a);
			draw_set_halign(fa_left);
		}
	}

	//CARTAO DA DIREITA: O QUE A OPÇAO FAZ. A ALTURA SE AJUSTA AO TEXTO
	var _it = mn_itens[indice];
	var _cx1 = 312, _cx2 = room_width - 20;
	var _cy1 = 78;
	var _ca = mn_card;
	var _slide = (1 - _ca) * 14;
	draw_set_font(fnt_hud);
	var _desc = menu_quebrar(_it.desc[_l], _cx2 - _cx1 - 36, 1);
	var _alt = string_height(_desc);

	//LINHAS EXTRAS DE CADA OPÇAO (RECORDE, PROGRESSO, AVISOS)
	var _ex = [];
	switch(_it.id)
	{
		case "arcade":
			array_push(_ex, [_pt ? "RECORDE" : "RECORD", string(global.record_1), #8BFF32]);
			break;
		case "coop":
			array_push(_ex, [_pt ? "RECORDE" : "RECORD", string(global.record_coop), #8BFF32]);
			break;
		case "blocos":
			var _cat = blocos_catalogo();
			var _vistos = 0;
			for(var k = 0; k < array_length(_cat); k++) if(bloco_visto(_cat[k].id)) _vistos++;
			array_push(_ex, [_pt ? "DESCOBERTOS" : "FOUND", string(_vistos) + "/" + string(array_length(_cat)), #8BFF32]);
			break;
		case "steam":
			if(mn_aviso > 0) array_push(_ex, [_pt ? "ABRINDO" : "OPENING", _pt ? "NO SEU NAVEGADOR..." : "IN YOUR BROWSER...", #8BFF32]);
			break;
	}
	//SO OS MODOS DE JOGO TEM O MACACO CORRENDO NO CANTO (OS OUTROS ITENS FICAM LIMPOS)
	var _corre = (_it.id == "arcade" or _it.id == "coop" or _it.id == "versus");
	//ALTURA: TITULO + TEXTO + LINHAS EXTRAS + FOLGA PRO MACACO CORRENDO
	var _alvo = 30 + 14 + _alt + (array_length(_ex) > 0 ? 14 + 15 * array_length(_ex) : 0) + (_corre ? 26 : 8);
	mn_card_h = mn_card_h < 0 ? max(_alvo, 112) : lerp(mn_card_h, max(_alvo, 112), .3);
	var _cy2 = _cy1 + mn_card_h;

	menu_cartao_caixa(_cy1, mn_card_h, _it.nome[_l], _ca, _slide);

	//DESCRIÇAO E LINHAS EXTRAS
	draw_set_valign(fa_top);
	menu_texto(_cx1 + 16 + _slide, _cy1 + 44, _desc, c_white, _ca, 1);
	var _ey = _cy1 + 44 + _alt + 14;
	for(var k = 0; k < array_length(_ex); k++)
	{
		menu_texto(_cx1 + 16 + _slide, _ey, _ex[k][0] + ":", #92A1B9, _ca, .85);
		menu_texto(_cx1 + 16 + _slide + 94, _ey, _ex[k][1], _ex[k][2], _ca, .85);
		_ey += 15;
	}

	//MACACOS CORRENDO NO CANTO DE BAIXO DO CARTAO (ENFEITE E JA MOSTRA SE O MODO E DE 1 OU 2 JOGADORES)
	var _dois = (_it.id == "coop" or _it.id == "versus");
	var _frame = get_timer() / 100000;
	if(_corre)
	{
		draw_sprite_ext(skin_sprite(global.skin_player_1, red_corrida2), _frame, _cx2 - (_dois ? 70 : 40), _cy2 - 14, -1, 1, 0, c_white, _ca);
		if(_dois) draw_sprite_ext(skin_sprite(global.skin_player_2, red_corrida2), _frame + 2, _cx2 - 36, _cy2 - 14, -1, 1, 0, c_white, _ca);
		draw_set_color(#5A3A8A);
		draw_line_width(_cx2 - 110, _cy2 - 8, _cx2 - 8, _cy2 - 8, 2);
	}
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

//==================== CONFIGURAÇOES NO MESMO ESTILO DO MENU PRINCIPAL ====================
//LISTA NA ESQUERDA (COM O VALOR DE CADA LINHA NA DIREITA) E, NA DIREITA, UM CARTAO QUE EXPLICA A LINHA SELECIONADA E MOSTRA O CONTROLE EM GRANDE.
//A LOGICA (SETAS, ESPAÇO, ESC) CONTINUA NO STEP DO OBJ_MENU_PRINCIPAL; AQUI SO O DESENHO, O MOUSE E A ANIMAÇAO DO CARTAO

//Y DE CADA LINHA
function menu_conf_y(_i)
{
	return 118 + 24 * _i;
}

//NOS CONTROLES SO A LINHA DO LAYOUT PODE SER ESCOLHIDA (AS OUTRAS SO MOSTRAM A TECLA)
function menu_conf_selecionavel(_i)
{
	return conf_sub != menu_conf.controles or _i == 0;
}

//MOUSE: PASSAR POR CIMA SELECIONA (SO SE MEXEU), CLICAR DEVOLVE TRUE (VALE COMO ESPAÇO)
function menu_conf_mouse()
{
	var _mexeu = (mouse_x != mn_mx or mouse_y != mn_my);
	mn_mx = mouse_x;
	mn_my = mouse_y;
	var _sobre = -1;
	var _qtd = array_length(conf_linhas());
	for(var i = 0; i < _qtd; i++)
	{
		if(menu_conf_selecionavel(i) and point_in_rectangle(mouse_x, mouse_y, 8, menu_conf_y(i) - 12, MENU_PAINEL_X - 40, menu_conf_y(i) + 12)) _sobre = i;
	}
	if(_mexeu and _sobre != -1 and _sobre != conf_indice)
	{
		conf_indice = _sobre;
		som_tocar(snd_menu_select_03);
	}
	return mouse_check_button_pressed(mb_left) and _sobre != -1;
}

//O CARTAO "ACENDE" QUANDO MUDA DE LINHA OU DE TELA
function menu_conf_anim()
{
	var _k = (conf_sub == noone ? -1 : conf_sub) * 20 + conf_indice;
	if(mn_conf_k != _k) { mn_conf_k = _k; mn_card = 0; }
	mn_card = lerp(mn_card, 1, .22);
}

//TEXTO DE UMA LINHA: [DESCRIÇAO PT, DESCRIÇAO EN]
function menu_conf_desc()
{
	switch(conf_sub)
	{
		case noone:
			switch(conf_indice)
			{
				case menu_conf.audio:		return ["VOLUME DA MÚSICA E DOS EFEITOS SONOROS.", "MUSIC AND SOUND EFFECTS VOLUME."];
				case menu_conf.controles:	return ["ESCOLHA O LAYOUT DE TECLAS E VEJA QUAL TECLA FAZ O QUÊ.", "PICK A KEY LAYOUT AND SEE WHAT EACH KEY DOES."];
				case menu_conf.jogo:		return ["TELA CHEIA, TREMOR DE TELA E COMANDOS NA TELA.", "FULLSCREEN, SCREEN SHAKE AND ON-SCREEN KEYS."];
				case menu_conf.idioma:		return ["TROQUE O IDIOMA DO JOGO.", "CHANGE THE GAME LANGUAGE."];
			}
			break;
		case menu_conf.audio:
			if(conf_indice == 0) return ["VOLUME DA MÚSICA DE FUNDO.", "BACKGROUND MUSIC VOLUME."];
			return ["VOLUME DOS EFEITOS SONOROS (SOCOS, BLOCOS, MENUS...).", "SOUND EFFECTS VOLUME (PUNCHES, BLOCKS, MENUS...)."];
		case menu_conf.controles:
			return ["TROCA O CONJUNTO DE TECLAS DO JOGO. AS TECLAS DE CADA AÇÃO APARECEM NA LISTA AO LADO.", "SWITCHES THE GAME KEY SET. EACH ACTION KEY IS LISTED ON THE LEFT."];
		case menu_conf.jogo:
			switch(conf_indice)
			{
				case 0: return ["LIGA OU DESLIGA A TELA CHEIA.", "TURNS FULLSCREEN ON OR OFF."];
				case 1: return ["TREMIDAS DE TELA EM EXPLOSÕES E GOLPES FORTES. DESLIGUE SE INCOMODAR.", "SCREEN SHAKES ON EXPLOSIONS AND HEAVY HITS. TURN OFF IF IT BOTHERS YOU."];
				case 2: return ["MOSTRA AS TECLAS DO JOGO NO RODAPÉ DA PARTIDA.", "SHOWS THE GAME KEYS AT THE BOTTOM OF THE MATCH."];
			}
			break;
	}
	return ["", ""];
}

//DESENHO (CHAMADO NO DRAW DO OBJ_MENU_PRINCIPAL SO NO ESTADO CONFIG)
function menu_conf_draw()
{
	var _pt = global.linguagem == 0;
	var _l = _pt ? 0 : 1;
	var _sombra = #0E071B;
	var _roxo = #A98BE0;
	menu_painel_esq();

	var _linhas = conf_linhas();
	var _qtd = array_length(_linhas);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);

	//NOME DA TELA ACIMA DA LISTA
	var _tit = texto("title_confg");
	switch(conf_sub)
	{
		case menu_conf.audio:		_tit = texto("audio");		break;
		case menu_conf.controles:	_tit = texto("control");	break;
		case menu_conf.jogo:		_tit = texto("op_game");	break;
	}
	menu_texto(MENU_LISTA_X, 90, _tit, _roxo, 1, .95);

	//AS LINHAS
	var _t = global.imputs;
	for(var i = 0; i < _qtd; i++)
	{
		var _y = menu_conf_y(i);
		var _ok = menu_conf_selecionavel(i);
		var _s = i < array_length(conf_x) ? clamp(conf_x[i] / 8, 0, 1) : 0;
		if(!_ok) _s = 0;
		var _x = MENU_LISTA_X + _s * 8;
		if(_s > .02)
		{
			draw_set_alpha(_s);
			draw_rectangle_color(14 - (1 - _s) * 6, _y - 10, MENU_PAINEL_X - 56, _y + 10, #FFB21E, #FFE66B, #FFE66B, #FFB21E, false);
			var _bob = sin(current_time / 110) * 2;
			draw_set_color(#FFE66B);
			draw_triangle(5 + _bob, _y - 5, 5 + _bob, _y + 5, 11 + _bob, _y, false);
			draw_set_alpha(1);
		}
		var _cor = merge_color(#C7CFDD, #1B1038, _s);
		var _a = _ok ? (.8 + _s * .2) : .6;
		if(_s < .5) menu_texto(_x, _y + 1, _linhas[i], _cor, _a);
		else draw_text_transformed_color(_x, _y + 1, _linhas[i], 1, 1, 0, _cor, _cor, _cor, _cor, 1);

		//VALOR NA DIREITA DA LINHA
		var _val = "";
		var _pilula = -1;	//-1 SEM PILULA, 0 DESLIGADO, 1 LIGADO
		switch(conf_sub)
		{
			case noone:
				_val = (i == menu_conf.idioma) ? texto("idioma_nome") : ">";
				break;
			case menu_conf.audio:
				_val = string(round((i == 0 ? global.musica : global.som_geral) * 100)) + "%";
				break;
			case menu_conf.controles:
				switch(i)
				{
					case 0: _val = "< 0" + string(global.meus_imputs + 1) + " >";				break;
					case 1: _val = tecla_nome(_t.left) + " / " + tecla_nome(_t.rigth);			break;
					case 2: _val = tecla_nome(_t.jump);			break;
					case 3: _val = tecla_nome(_t.soco);			break;
					case 4: _val = tecla_nome(_t.soco_press);	break;
					case 5: _val = tecla_nome(_t.giro);			break;
					case 6: _val = tecla_nome(_t.acelerar);		break;
					case 7: _val = tecla_nome(_t.dash);			break;
					case 8: _val = tecla_nome(_t.down) + " + " + tecla_nome(_t.soco); break;
				}
				break;
			case menu_conf.jogo:
				_pilula = (i == 0 ? global.full_screen : (i == 1 ? global.shake : global.mostrar_teclas)) ? 1 : 0;
				_val = _pilula == 1 ? (_pt ? "LIGADO" : "ON") : (_pt ? "DESLIGADO" : "OFF");
				break;
		}
		draw_set_halign(fa_right);
		var _vx = MENU_PAINEL_X - 62;
		if(_pilula != -1)
		{
			var _w = string_width(_val) * .8 + 10;
			draw_set_color(_sombra);
			draw_rectangle(_vx - _w + 4, _y - 7, _vx + 4, _y + 8, false);
			var _cp = _pilula == 1 ? #8BFF32 : #FF5577;
			draw_text_transformed_color(_vx - 1, _y + 1, _val, .8, .8, 0, _cp, _cp, _cp, _cp, 1);
		}
		else
		{
			var _cv = merge_color(#92A1B9, #1B1038, _s);
			if(conf_sub == menu_conf.controles and i > 0) _cv = #C7CFDD;
			draw_text_transformed_color(_vx, _y + 1, _val, .9, .9, 0, _cv, _cv, _cv, _cv, _a);
		}
		draw_set_halign(fa_left);
	}

	//CARTAO DA DIREITA: A LINHA SELECIONADA, O QUE ELA FAZ E O CONTROLE EM GRANDE
	var _desc = menu_conf_desc();
	var _cx1 = 312, _cx2 = room_width - 20, _cy1 = 78;
	var _ca = mn_card;
	var _slide = (1 - _ca) * 14;
	var _txt = menu_quebrar(_desc[_l], _cx2 - _cx1 - 36, 1);
	var _alt = string_height(_txt);
	var _alvo = 30 + 14 + _alt + 16 + 46 + 18;
	mn_card_h = mn_card_h < 0 ? _alvo : lerp(mn_card_h, _alvo, .3);
	menu_cartao_caixa(_cy1, mn_card_h, _linhas[conf_indice], _ca, _slide);
	draw_set_font(fnt_hud);
	draw_set_valign(fa_top);
	menu_texto(_cx1 + 16 + _slide, _cy1 + 44, _txt, c_white, _ca);

	//O CONTROLE EM GRANDE (BARRA DE VOLUME, CHAVE LIGA/DESLIGA, LAYOUTS OU IDIOMAS)
	var _wx = _cx1 + 16 + _slide;
	var _wy = _cy1 + 44 + _alt + 16;
	var _dica = "";
	var _tipo = "nada";
	var _mudar = _pt ? "MUDAR" : "CHANGE";
	if(conf_sub == menu_conf.audio) _tipo = "volume";
	else if(conf_sub == menu_conf.jogo) _tipo = "chave";
	else if(conf_sub == menu_conf.controles) _tipo = "layout";
	else if(conf_sub == noone and conf_indice == menu_conf.idioma) _tipo = "idioma";
	else if(conf_sub == noone) _dica = _pt ? "ESPAÇO: ABRIR" : "SPACE: OPEN";
	switch(_tipo)
	{
		case "volume":
			var _vol = conf_indice == 0 ? global.musica : global.som_geral;
			draw_set_alpha(_ca);
			draw_set_color(#1E1A38);
			draw_rectangle(_wx, _wy + 6, _wx + 270, _wy + 20, false);
			draw_rectangle_color(_wx, _wy + 6, _wx + 270 * _vol, _wy + 20, #31FCFF, #8BFF32, #8BFF32, #31FCFF, false);
			draw_set_color(#5A3A8A);
			draw_rectangle(_wx, _wy + 6, _wx + 270, _wy + 20, true);
			draw_set_color(c_white);
			draw_rectangle(_wx + 270 * _vol - 2, _wy + 2, _wx + 270 * _vol + 2, _wy + 24, false);
			draw_set_alpha(1);
			menu_texto(_wx + 282, _wy + 6, string(round(_vol * 100)) + "%", #FFE66B, _ca, 1);
			_dica = "< >  " + _mudar + (_pt ? " (SEGURE PRA IR RÁPIDO)" : " (HOLD TO GO FAST)");
			break;
		case "chave":
			var _lig = conf_indice == 0 ? global.full_screen : (conf_indice == 1 ? global.shake : global.mostrar_teclas);
			var _tg = _lig ? (_pt ? "LIGADO" : "ON") : (_pt ? "DESLIGADO" : "OFF");
			var _wp = string_width(_tg) + 28;
			draw_set_alpha(_ca);
			draw_set_color(_sombra);
			draw_rectangle(_wx, _wy + 2, _wx + _wp, _wy + 26, false);
			draw_set_color(_lig ? #8BFF32 : #FF5577);
			draw_rectangle(_wx, _wy + 2, _wx + _wp, _wy + 26, true);
			draw_set_alpha(1);
			draw_set_valign(fa_middle);
			menu_texto(_wx + 14, _wy + 15, _tg, _lig ? #8BFF32 : #FF5577, _ca);
			draw_set_valign(fa_top);
			_dica = (_pt ? "ESPAÇO: LIGAR / DESLIGAR" : "SPACE: TURN ON / OFF");
			break;
		case "layout":
			for(var k = 0; k < array_length(global.layouts_imputs); k++)
			{
				var _bx = _wx + k * 44;
				var _atual = (k == global.meus_imputs);
				draw_set_alpha(_ca);
				draw_set_color(_atual ? #FFB21E : #1E1A38);
				draw_rectangle(_bx, _wy + 2, _bx + 38, _wy + 26, false);
				draw_set_color(_atual ? #FFE66B : #5A3A8A);
				draw_rectangle(_bx, _wy + 2, _bx + 38, _wy + 26, true);
				draw_set_alpha(1);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				menu_texto(_bx + 19, _wy + 15, "0" + string(k + 1), _atual ? #1B1038 : #C7CFDD, _ca);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
			}
			_dica = "< >  " + (_pt ? "TROCAR LAYOUT" : "SWITCH LAYOUT");
			break;
		case "idioma":
			var _nomes = ["PT-BR", "ENGLISH"];
			for(var k = 0; k < 2; k++)
			{
				var _bx = _wx + k * 100;
				var _atual = (k == (_pt ? 0 : 1));
				draw_set_alpha(_ca);
				draw_set_color(_atual ? #FFB21E : #1E1A38);
				draw_rectangle(_bx, _wy + 2, _bx + 90, _wy + 26, false);
				draw_set_color(_atual ? #FFE66B : #5A3A8A);
				draw_rectangle(_bx, _wy + 2, _bx + 90, _wy + 26, true);
				draw_set_alpha(1);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				menu_texto(_bx + 45, _wy + 15, _nomes[k], _atual ? #1B1038 : #C7CFDD, _ca);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
			}
			_dica = "< >  " + (_pt ? "OU ESPAÇO TROCA" : "OR SPACE SWITCHES");
			break;
	}
	if(_dica != "") menu_texto(_wx, _wy + 34, _dica, #92A1B9, _ca, .85);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

//==================== TEXTOS E TABELAS DA PAUSA ====================
//NO CELULAR A PAUSA CONTINUA NO PAINEL ANTIGO (OBJ_GAME_CONTROL, DRAW GUI). A TELA DE GAME OVER TAMBEM. A PAUSA DO PC (NAVE) VEM LOGO DEPOIS

//OPÇOES DA PAUSA, NA ORDEM (CELULAR = PAINEL ANTIGO, PC = PAUSA DA NAVE)
function pausa_ids()
{
	return MOBILE ? ["continuar", "comandos", "teclas", "dificuldade", "reiniciar", "menu"] : ["continuar", "reiniciar", "comandos", "opcoes", "sair"];
}

//O TEXTO DE CADA OPÇAO DA PAUSA (NA MESMA ORDEM DO PAUSA_IDS)
function pausa_nomes()
{
	var _pt = global.linguagem == 0;
	var _sim = _pt ? "SIM" : "ON", _nao = _pt ? "NÃO" : "OFF";
	var _ids = pausa_ids();
	var _r = [];
	for(var i = 0; i < array_length(_ids); i++)
	{
		switch(_ids[i])
		{
			case "continuar":	array_push(_r, texto("continuar_jogo")); break;
			case "comandos":	array_push(_r, _pt ? "COMANDOS" : "CONTROLS"); break;
			case "teclas":		array_push(_r, (_pt ? "TECLAS: " : "KEYS: ") + (global.mostrar_teclas ? _sim : _nao)); break;
			case "dificuldade":	array_push(_r, (_pt ? "TESTE DE DIFICULDADE: " : "DIFFICULTY TEST: ") + (global.teste_dif ? _sim : _nao)); break;
			case "reiniciar":	array_push(_r, texto("reiniciar")); break;
			case "menu":		array_push(_r, texto("voltar_menu")); break;
			case "opcoes":		array_push(_r, _pt ? "OPÇÕES" : "OPTIONS"); break;
			case "sair":		array_push(_r, _pt ? "SAIR" : "EXIT"); break;
		}
	}
	return _r;
}

//A TABELA DE COMANDOS: A PRIMEIRA LINHA E O CABEÇALHO. SOLO = [ACAO, TECLADO, CONTROLE]. COOP/VERSUS = [ACAO, P1, P2, CONTROLE]
function pausa_comandos_linhas()
{
	var _pt = global.linguagem == 0;
	var _dois = dois_players();
	var _a = imputs_jogador(1);
	var _b = imputs_jogador(2);
	var _versus = modo_versus();
	var _mov = function(_i) { return tecla_nome(_i.left) + " " + tecla_nome(_i.rigth); };
	//[ACAO, TECLAS DO P1, TECLAS DO P2, BOTAO DO CONTROLE] (SOLO NAO TEM A COLUNA DO P2)
	var _linha = function(_acao, _t1, _t2, _pad, _dois) { return _dois ? [_acao, _t1, _t2, _pad] : [_acao, _t1, _pad]; };
	var _l = [];
	array_push(_l, _dois ? [_pt ? "AÇÃO" : "ACTION", "P1", "P2", _pt ? "CONTROLE" : "GAMEPAD"] : [_pt ? "AÇÃO" : "ACTION", _pt ? "TECLADO" : "KEYBOARD", _pt ? "CONTROLE" : "GAMEPAD"]);
	array_push(_l, _linha(_pt ? "ANDAR" : "MOVE",					_mov(_a),					_mov(_b),					_pt ? "ANALÓG. / D-PAD" : "STICK / D-PAD", _dois));
	array_push(_l, _linha(_pt ? "PULO" : "JUMP",					tecla_nome(_a.jump),		tecla_nome(_b.jump),		"A", _dois));
	array_push(_l, _linha(_pt ? "SOCO" : "PUNCH",					tecla_nome(_a.soco),		tecla_nome(_b.soco),		"X", _dois));
	array_push(_l, _linha(_pt ? "SUPER SOCO" : "SUPER PUNCH",		tecla_nome(_a.soco_press),	tecla_nome(_b.soco_press),	"RB", _dois));
	array_push(_l, _linha(_pt ? "GIRO" : "SPIN",					tecla_nome(_a.giro),		tecla_nome(_b.giro),		"B", _dois));
	array_push(_l, _linha(_pt ? "DASH (PODER)" : "DASH (POWER)",	tecla_nome(_a.dash),		tecla_nome(_b.dash),		"Y", _dois));
	array_push(_l, _linha(_pt ? "TELEPORTAR PEÇA" : "DROP PIECE",	tecla_nome(_a.acelerar),	tecla_nome(_b.acelerar),	"LB / RT", _dois));
	if(_versus) array_push(_l, _linha(_pt ? "PODER FANTASMA" : "GHOST POWER", tecla_nome(versus_tecla_poder(1)), tecla_nome(versus_tecla_poder(2)), "LT / SELECT", _dois));
	else array_push(_l, _linha(_pt ? "PARAR O TEMPO" : "TIME STOP", tecla_nome(TEMPO_TECLA), tecla_nome(TEMPO_TECLA), "LT / SELECT", _dois));
	array_push(_l, _linha(_pt ? "PAUSA" : "PAUSE", "ESC", "ESC", "START", _dois));
	return _l;
}

//==================== PAUSA NA NAVE (SO NO PC) ====================
//O JOGO SOME E SOBRA O ESPAÇO: ESTRELAS ANDANDO, UMA NAVE COM O ALIEN NA CUPULA (OS OLHOS SEGUEM O MOUSE OU A OPÇAO ESCOLHIDA) E A LUZ DELA
//DESCENDO ATE O CHAO. AS OPÇOES FICAM EMPILHADAS DENTRO DA LUZ, LEVEMENTE TORTAS, E A ESCOLHIDA VIRA UM BOTAO AMARELO MAIOR.
//TUDO E DESENHADO EM PIXELS DA ROOM (720 X 405). O MOUSE FUNCIONA: PASSAR POR CIMA ESCOLHE, CLICAR CONFIRMA.
#macro PAUSA_CX		360		//MEIO DA TELA (NAVE, LUZ E BOTOES)
#macro PAUSA_CHAO		337		//Y ONDE A LUZ BATE NO CHAO

//ESTADO VISUAL DA PAUSA (ESTRELAS E OLHOS). FICA NUMA GLOBAL PORQUE ESSAS FUNÇOES NAO TEM INSTANCIA PROPRIA
function pausa_vis()
{
	if(!variable_global_exists("pausa_v"))
	{
		var _cores = [ #FFFFFF, #FFFFFF, #FFFFFF, #C7CFDD, #31FCFF, #FFB21E, #FF77D8, #FFE66B];
		var _est = [];
		for(var i = 0; i < 70; i++)
		{
			array_push(_est, {
				x : random(room_width),
				y : random(PAUSA_CHAO - 6),
				v : choose(.05, .08, .08, .12, .12, .2, .32),	//PIXELS POR FRAME. AS MAIS RAPIDAS SAO MAIORES (PARALAXE)
				c : _cores[irandom(array_length(_cores) - 1)],
				f : random(6.28)								//FASE DO PISCA
			});
		}
		global.pausa_v = {
			est : _est,
			olho_x : 0, olho_y : 0,			//PRA ONDE OS OLHOS ESTAO OLHANDO (PIXELS DENTRO DA CARA)
			mx : -1, my : -1,				//MOUSE NA ROOM
			moveu : false,					//O MOUSE MEXEU NESTE FRAME
			mouse_t : 999,					//FRAMES DESDE QUE O MOUSE MEXEU
			indice : -1,					//ULTIMA OPÇAO ESCOLHIDA (PRA SABER QUANDO FOI O TECLADO)
			pisca : 0, pisca_t : 150		//PISCADA DOS OLHOS
		};
	}
	return global.pausa_v;
}

//MOUSE EM PIXELS DA ROOM (A GUI E MAIOR QUE A ROOM)
function pausa_mouse()
{
	var _e = max(.01, gui_esc());
	return [device_mouse_x_to_gui(0) / _e, device_mouse_y_to_gui(0) / _e];
}

//TODO FRAME (STEP DO OBJ_GAME_CONTROL): VÊ SE O MOUSE MEXEU. SEM ISSO O MOUSE PARADO EM CIMA DE UM BOTAO TRAVARIA O TECLADO
function pausa_mouse_atualizar()
{
	var _v = pausa_vis();
	var _m = pausa_mouse();
	_v.moveu = point_distance(_m[0], _m[1], _v.mx, _v.my) > 1;	//(MENOS DE 1 PIXEL NAO CONTA COMO MEXER)
	_v.mx = _m[0];
	_v.my = _m[1];
	_v.mouse_t = _v.moveu ? 0 : min(_v.mouse_t + 1, 999);
}

//ONDE FICA CADA BOTAO: [CENTRO X, CENTRO Y, LARGURA, ALTURA, ANGULO]. O ESCOLHIDO CRESCE (_SEL = 0 A 1) E EMPURRA OS DE BAIXO
function pausa_botoes(_sel)
{
	static _dx  = [0, -10, 12, -6, 7];				//CADA BOTAO UM POUCO PRA UM LADO
	static _ang = [-2, 1.5, -1.2, 1.2, -1.5];		//E UM POUCO TORTO
	var _r = [];
	var _y = 115;
	var _n = array_length(pausa_ids());
	for(var i = 0; i < _n; i++)
	{
		var _s = _sel[i];
		var _h = 32 + 12 * _s;
		array_push(_r, [PAUSA_CX + _dx[i mod 5], _y + _h / 2, 164 + 24 * _s, _h, _ang[i mod 5] * (1 - _s * .5)]);
		_y += _h + 6;
	}
	return _r;
}

//RETANGULO GIRADO. X1/Y1/X2/Y2 SAO LOCAIS (RELATIVOS AO CENTRO _CX/_CY ANTES DE GIRAR), ANGULO EM GRAUS (ANTI-HORARIO, COMO NO DRAW_TEXT_TRANSFORMED).
//_COR E A COR DE CIMA E _COR2 A DE BAIXO (DEGRADE). _BORDA = SO O CONTORNO
function pausa_rect(_cx, _cy, _x1, _y1, _x2, _y2, _ang, _cor, _a, _borda = false, _cor2 = -1)
{
	if(_cor2 == -1) _cor2 = _cor;
	var _c = dcos(_ang), _s = dsin(_ang);
	var _px = [_x1, _x2, _x2, _x1];
	var _py = [_y1, _y1, _y2, _y2];
	draw_primitive_begin(_borda ? pr_linestrip : pr_trianglefan);
	for(var i = 0; i < (_borda ? 5 : 4); i++)
	{
		var _k = i mod 4;
		draw_vertex_color(_cx + _px[_k] * _c + _py[_k] * _s, _cy - _px[_k] * _s + _py[_k] * _c, _k < 2 ? _cor : _cor2, _a);
	}
	draw_primitive_end();
}

//TEXTO GIRADO JUNTO COM O BOTAO (_LX/_LY LOCAIS, IGUAL AO PAUSA_RECT)
function pausa_texto_giro(_cx, _cy, _lx, _ly, _ang, _txt, _cor, _a, _esc)
{
	var _c = dcos(_ang), _s = dsin(_ang);
	draw_text_transformed_color(_cx + _lx * _c + _ly * _s, _cy - _lx * _s + _ly * _c, _txt, _esc, _esc, _ang, _cor, _cor, _cor, _cor, _a);
}

//UM BOTAO. _B = DADOS DO PAUSA_BOTOES, _S = QUANTO ESTA ESCOLHIDO (0 A 1), _ICO = COR DO QUADRADINHO, _PERIGO = BOTAO VERMELHO (SAIR)
function pausa_botao_desenhar(_b, _nome, _s, _a, _ico, _perigo)
{
	var _cx = _b[0], _cy = _b[1], _w = _b[2] / 2, _h = _b[3] / 2, _ang = _b[4];
	var _fundo = _perigo ? #2B1226 : #1A1233;
	var _borda = _perigo ? #FF5A66 : #4CC24C;
	//SOMBRA (SO NO ESCOLHIDO)
	if(_s > .02) pausa_rect(_cx + 3, _cy + 4, -_w, -_h, _w, _h, _ang, #000000, _a * .4 * _s);
	//CONTORNO E CORPO (O ESCOLHIDO VAI FICANDO AMARELO)
	pausa_rect(_cx, _cy, -_w - 2, -_h - 2, _w + 2, _h + 2, _ang, merge_color(_borda, #B8821A, _s), _a);
	pausa_rect(_cx, _cy, -_w, -_h, _w, _h, _ang, merge_color(_fundo, #FFE066, _s), _a, false, merge_color(_fundo, #FFC21E, _s));
	//QUADRADINHO COLORIDO (NO ESCOLHIDO VIRA CARINHA)
	var _is = 18 + 4 * _s;
	var _ix = -_w + 11;
	pausa_rect(_cx, _cy, _ix - 1, -_is / 2 - 1, _ix + _is + 1, _is / 2 + 1, _ang, merge_color(#0E071B, #2A1B3C, _s), _a);
	pausa_rect(_cx, _cy, _ix, -_is / 2, _ix + _is, _is / 2, _ang, _ico, _a);
	if(_s > .5)
	{
		var _ca = _a * ((_s - .5) * 2);
		var _k = _is / 18;
		//OLHOS E SORRISO
		pausa_rect(_cx, _cy, _ix + 4 * _k, -4 * _k, _ix + 7 * _k, -1 * _k, _ang, #1B1038, _ca);
		pausa_rect(_cx, _cy, _ix + 11 * _k, -4 * _k, _ix + 14 * _k, -1 * _k, _ang, #1B1038, _ca);
		pausa_rect(_cx, _cy, _ix + 4 * _k, 2 * _k, _ix + 6 * _k, 4 * _k, _ang, #1B1038, _ca);
		pausa_rect(_cx, _cy, _ix + 6 * _k, 4 * _k, _ix + 12 * _k, 6 * _k, _ang, #1B1038, _ca);
		pausa_rect(_cx, _cy, _ix + 12 * _k, 2 * _k, _ix + 14 * _k, 4 * _k, _ang, #1B1038, _ca);
	}
	//TEXTO
	var _cor = _perigo ? merge_color(#FF6B7D, #5A1020, _s) : merge_color(#C9C5F5, #2A1B3C, _s);
	var _esc = lerp(.85, 1, _s);
	var _tx = _ix + _is + 10;
	pausa_texto_giro(_cx, _cy, _tx, 1, _ang, _nome, _cor, _a, _esc);
}

//ESTRELAS EM MOVIMENTO (SEM ESTADO: A POSIÇAO SAI DO RELOGIO). ANDAM PRA ESQUERDA E PISCAM DE LEVE
function pausa_estrelas_desenhar(_a)
{
	var _v = pausa_vis();
	var _tempo = current_time / 16.67;	//EM FRAMES
	var _w = room_width;
	for(var i = 0; i < array_length(_v.est); i++)
	{
		var _s = _v.est[i];
		var _x = floor(((_s.x - _tempo * _s.v) mod _w + _w) mod _w);
		var _y = floor(_s.y);
		var _tam = _s.v > .25 ? 3 : (_s.v > .1 ? 2 : 1);
		draw_set_alpha(_a * (.55 + .45 * sin(_tempo / 25 + _s.f)));
		draw_set_color(_s.c);
		draw_rectangle(_x, _y, _x + _tam - 1, _y + _tam - 1, false);
	}
	draw_set_alpha(1);
}

//META DA LARGURA DA LUZ NA ALTURA _Y (ABRE DE CIMA PRA BAIXO E "RESPIRA" DE LEVE)
function pausa_feixe_meia(_y, _tp)
{
	return lerp(64, 196 + sin(_tp / 55) * 7, clamp((_y - 98) / (PAUSA_CHAO - 98), 0, 1));
}

//UM PEDAÇO DA LUZ ENTRE AS ALTURAS _YA E _YB. _ENC ENCOLHE A LARGURA (0 A 1). _A1/_A2 = ALPHA EM CIMA E EMBAIXO
function pausa_feixe_faixa(_ya, _yb, _enc, _cor, _a1, _a2, _tp)
{
	var _w1 = pausa_feixe_meia(_ya, _tp) * _enc;
	var _w2 = pausa_feixe_meia(_yb, _tp) * _enc;
	draw_primitive_begin(pr_trianglefan);
	draw_vertex_color(PAUSA_CX - _w1, _ya, _cor, _a1);
	draw_vertex_color(PAUSA_CX + _w1, _ya, _cor, _a1);
	draw_vertex_color(PAUSA_CX + _w2, _yb, _cor, _a2);
	draw_vertex_color(PAUSA_CX - _w2, _yb, _cor, _a2);
	draw_primitive_end();
}

//A LUZ DA NAVE: DUAS CAMADAS QUE PULSAM DE LEVE E FAIXAS CLARAS SUBINDO (COMO UM RAIO TRATOR)
function pausa_feixe_desenhar(_a, _ent)
{
	var _tp = current_time / 16.67;
	var _pulso = .88 + .12 * sin(_tp / 38);
	var _topo = 98;
	var _base = PAUSA_CHAO + 4;
	var _fim = _topo + (_base - _topo) * _ent;		//A LUZ DESCE ATE O CHAO NA ENTRADA
	pausa_feixe_faixa(_topo, _fim, 1, #8FE070, .17 * _a * _pulso, .12 * _a * _pulso, _tp);
	pausa_feixe_faixa(_topo, _fim, .6, #C4F58F, .13 * _a * _pulso, .09 * _a * _pulso, _tp);
	//FAIXAS CLARAS SUBINDO
	for(var k = 0; k < 4; k++)
	{
		var _py = _base - ((_tp * .75 + k * 62) mod 248);
		var _f = sin(pi * (_base - _py) / 248);
		//A FAIXA ACENDE NO MEIO E APAGA NAS PONTAS (DUAS METADES)
		var _ya = max(_topo, _py - 12);
		var _yb = min(_fim, _py + 12);
		if(_yb <= _ya) continue;
		var _yc = clamp(_py, _ya, _yb);
		if(_yc > _ya) pausa_feixe_faixa(_ya, _yc, .92, #E4FFC0, 0, .08 * _f * _a, _tp);
		if(_yb > _yc) pausa_feixe_faixa(_yc, _yb, .92, #E4FFC0, .08 * _f * _a, 0, _tp);
	}
}

//CHAO: MORRINHOS DE PIXEL EM VERDE ESCURO
function pausa_chao_desenhar(_a)
{
	draw_set_alpha(_a);
	draw_set_color(#0F2A1D);
	draw_rectangle(0, PAUSA_CHAO, room_width, room_height, false);
	draw_set_color(#163B27);
	//[X1, X2, TOPO] DE CADA MORRINHO
	var _m = [[48, 88, 330], [150, 195, 331], [394, 432, 330], [516, 553, 331], [615, 666, 328]];
	for(var i = 0; i < array_length(_m); i++) draw_rectangle(_m[i][0], _m[i][2], _m[i][1], PAUSA_CHAO + 1, false);
	draw_set_color(#0C2218);
	draw_rectangle(0, PAUSA_CHAO + 26, room_width, room_height, false);
	draw_set_alpha(1);
}

//OS OLHOS DO ALIEN: OLHAM PRO MOUSE (ENQUANTO ELE MEXE) OU PRA OPÇAO ESCOLHIDA. PISCAM DE VEZ EM QUANDO
function pausa_olhos_atualizar(_alvo_x, _alvo_y)
{
	var _v = pausa_vis();
	var _dx = _alvo_x - PAUSA_CX;
	var _dy = _alvo_y - 41;
	var _d = max(1, point_distance(0, 0, _dx, _dy));
	var _f = min(1, _d / 30);		//PERTO DA CARA, OS OLHOS VOLTAM PRO MEIO
	_v.olho_x = lerp(_v.olho_x, _dx / _d * 3.6 * _f, .2);
	_v.olho_y = lerp(_v.olho_y, _dy / _d * 2.4 * _f, .2);
	if(_v.pisca > 0) _v.pisca--;
	else if(--_v.pisca_t <= 0) { _v.pisca = 6; _v.pisca_t = irandom_range(120, 260); }
}

//A NAVE: CUPULA, ALIEN, PRATO E A PLACA COM O TITULO. DESCE DO TOPO NA ENTRADA E BALANÇA DE LEVE
function pausa_nave_desenhar(_a, _t, _titulo)
{
	var _v = pausa_vis();
	var _ent = 1 - power(1 - clamp(_t / 26, 0, 1), 3);
	var _oy = (1 - _ent) * -90 + sin(current_time / 520) * 1.5;
	var _cx = PAUSA_CX;
	draw_set_alpha(_a);

	//CUPULA (MEIA ELIPSE)
	draw_set_color(#2F5F7A);
	draw_primitive_begin(pr_trianglefan);
	draw_vertex_color(_cx, 70 + _oy, #2F5F7A, _a);
	for(var g = 180; g <= 360; g += 10) draw_vertex_color(_cx + 56 * dcos(g), 70 + _oy + 59 * dsin(g), #2F5F7A, _a);
	draw_primitive_end();
	draw_primitive_begin(pr_linestrip);
	for(var g = 180; g <= 360; g += 10) draw_vertex_color(_cx + 56 * dcos(g), 70 + _oy + 59 * dsin(g), #5E93AE, _a);
	draw_primitive_end();
	draw_set_color(#5E93AE);
	draw_rectangle(_cx - 40, 20 + _oy, _cx - 35, 22 + _oy, false);	//BRILHINHO NO VIDRO

	//ALIEN (CARA VERDE)
	draw_roundrect_color_ext(_cx - 19, 25 + _oy, _cx + 19, 60 + _oy, 8, 8, #8BFF32, #8BFF32, false);
	draw_roundrect_color_ext(_cx - 19, 25 + _oy, _cx + 19, 60 + _oy, 8, 8, #5ECB1E, #5ECB1E, true);
	var _alt = _v.pisca > 0 ? 2 : 9;
	var _ex = round(_cx + _v.olho_x);
	var _ey = round(41 + _oy + _v.olho_y);
	draw_set_color(#0E071B);
	draw_rectangle(_ex - 13, _ey - floor(_alt / 2), _ex - 5, _ey + floor(_alt / 2), false);
	draw_rectangle(_ex + 5, _ey - floor(_alt / 2), _ex + 13, _ey + floor(_alt / 2), false);

	//PRATO (3 CAMADAS: SOMBRA, CORPO E BRILHO EM CIMA)
	draw_set_alpha(_a);
	draw_set_color(#6E74B8);
	draw_ellipse(_cx - 158, 62 + _oy, _cx + 158, 102 + _oy, false);
	draw_set_color(#A9AEE0);
	draw_ellipse(_cx - 158, 58 + _oy, _cx + 158, 96 + _oy, false);
	draw_set_color(#C6CAF2);
	draw_ellipse(_cx - 130, 60 + _oy, _cx + 130, 74 + _oy, false);
	draw_set_color(#7C82C4);
	draw_ellipse(_cx - 158, 58 + _oy, _cx + 158, 96 + _oy, true);
	//BARRIGA ESCURA DA NAVE (DE ONDE SAI A LUZ)
	draw_roundrect_color_ext(_cx - 72, 88 + _oy, _cx + 72, 104 + _oy, 6, 6, #3A4468, #3A4468, false);

	//PLACA COM O TITULO
	draw_set_color(#2A1E5A);
	draw_rectangle(_cx - 70, 63 + _oy, _cx + 70, 89 + _oy, false);
	draw_set_color(#4B3A8F);
	draw_rectangle(_cx - 68, 65 + _oy, _cx + 68, 87 + _oy, false);
	draw_set_font(fnt_table);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	menu_texto(_cx, 77 + _oy, _titulo, #FFD23A, _a, 1);
	var _tw = string_width(_titulo) / 2;
	draw_set_color(#FFD23A);
	draw_rectangle(_cx - _tw - 11, 75 + _oy, _cx - _tw - 7, 79 + _oy, false);
	draw_rectangle(_cx + _tw + 7, 75 + _oy, _cx + _tw + 11, 79 + _oy, false);
	draw_set_alpha(1);
}

//CAIXA ESCURA COM BORDA VERDE (COMANDOS E OPÇOES)
function pausa_painel_desenhar(_x1, _y1, _x2, _y2, _a)
{
	draw_set_alpha(_a * .94);
	draw_set_color(#110B24);
	draw_rectangle(_x1, _y1, _x2, _y2, false);
	draw_set_alpha(_a);
	draw_set_color(#4CC24C);
	draw_rectangle(_x1, _y1, _x2, _y2, true);
	draw_rectangle(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, true);
	draw_set_alpha(1);
}

//TELA DOS COMANDOS (TODAS AS TECLAS; NO COOP/VERSUS UMA COLUNA PRA CADA JOGADOR)
function pausa_comandos_desenhar(_a, _t)
{
	var _pt = global.linguagem == 0;
	var _dois = dois_players();
	var _ca = _a * clamp((_t - 6) / 12, 0, 1);
	var _linhas = pausa_comandos_linhas();
	var _passo = 16;
	var _coop = global.coop and !modo_versus();
	var _x1 = 70, _x2 = room_width - 70, _y1 = 112;
	var _h = 14 + array_length(_linhas) * _passo + (_coop ? 18 : 0) + 28;
	pausa_painel_desenhar(_x1, _y1, _x2, _y1 + _h, _ca);
	draw_set_font(fnt_hud);
	draw_set_valign(fa_middle);
	//CENTRO DE CADA COLUNA E LARGURA DISPONIVEL
	var _cols = _dois ? [[_x1 + 300, 80], [_x1 + 395, 80], [_x1 + 500, 100]] : [[_x1 + 330, 120], [_x1 + 470, 120]];
	var _cores = _dois ? [COOP_COR_P1, COOP_COR_P2, #8BFF32] : [ #8BFF32, #31FCFF];
	for(var i = 0; i < array_length(_linhas); i++)
	{
		var _ly = _y1 + 16 + i * _passo;
		var _cab = i == 0;
		if(!_cab and i mod 2 == 0)
		{
			draw_set_alpha(_ca * .5);
			draw_set_color(#1E1A38);
			draw_rectangle(_x1 + 6, _ly - 7, _x2 - 6, _ly + 7, false);
			draw_set_alpha(1);
		}
		draw_set_halign(fa_left);
		var _l0 = _linhas[i][0];
		menu_texto(_x1 + 18, _ly, _l0, _cab ? #FFE66B : c_white, _ca, min(.8, 190 / max(1, string_width(_l0))));
		draw_set_halign(fa_center);
		for(var c = 0; c < array_length(_cols); c++)
		{
			var _txt = _linhas[i][c + 1];
			menu_texto(_cols[c][0], _ly, _txt, _cores[c], _ca, min(.8, _cols[c][1] / max(1, string_width(_txt))));
		}
	}
	draw_set_halign(fa_left);
	var _fy = _y1 + 16 + array_length(_linhas) * _passo;
	//COOP: UM TELEPORTE DE CADA VEZ
	if(_coop)
	{
		var _v = coop_vez_de();
		var _msg = (_pt ? "TELEPORTE: UM DE CADA VEZ. AGORA É A VEZ DO P" : "DROP: TAKE TURNS. NOW IT IS P") + string(_v);
		menu_texto(_x1 + 18, _fy + 2, _msg, _v == 1 ? COOP_COR_P1 : COOP_COR_P2, _ca, min(.75, (_x2 - _x1 - 36) / max(1, string_width(_msg))));
		_fy += 18;
	}
	menu_texto(_x1 + 18, _fy + 8, texto("dica_especial"), #31FCFF, _ca, min(.75, (_x2 - _x1 - 36) / max(1, string_width(texto("dica_especial")))));
	draw_set_valign(fa_top);
}

//LINHAS DA TELA DE OPÇOES (O TESTE DE DIFICULDADE NAO EXISTE NO VERSUS)
function pausa_opcoes_linhas()
{
	var _pt = global.linguagem == 0;
	var _l = [];
	array_push(_l, { id : "musica",		nome : _pt ? "MÚSICA" : "MUSIC" });
	array_push(_l, { id : "efeitos",	nome : _pt ? "EFEITOS SONOROS" : "SOUND EFFECTS" });
	array_push(_l, { id : "shake",		nome : _pt ? "TREMOR DE TELA" : "SCREEN SHAKE" });
	array_push(_l, { id : "teclas",		nome : _pt ? "TECLAS NA TELA" : "ON-SCREEN KEYS" });
	if(!modo_versus()) array_push(_l, { id : "dificuldade", nome : _pt ? "TESTE DE DIFICULDADE" : "DIFFICULTY TEST" });
	array_push(_l, { id : "voltar",		nome : _pt ? "VOLTAR" : "BACK" });
	return _l;
}

//A CAIXA DAS OPÇOES [X1, Y1, X2, Y2] E O Y DO CENTRO DE CADA LINHA
function pausa_opcoes_geo()
{
	var _n = array_length(pausa_opcoes_linhas());
	return [160, 112, room_width - 160, 112 + 14 + _n * 26 + 8];
}
function pausa_opcoes_y(_i) { return 112 + 21 + _i * 26; }

//TELA DE OPÇOES DA PAUSA
function pausa_opcoes_desenhar(_a, _t)
{
	var _pt = global.linguagem == 0;
	var _ca = _a * clamp((_t - 6) / 12, 0, 1);
	var _l = pausa_opcoes_linhas();
	var _g = pausa_opcoes_geo();
	pausa_painel_desenhar(_g[0], _g[1], _g[2], _g[3], _ca);
	draw_set_font(fnt_hud);
	draw_set_valign(fa_middle);
	for(var i = 0; i < array_length(_l); i++)
	{
		var _y = pausa_opcoes_y(i);
		var _s = (i == opcao_sub) ? 1 : 0;
		if(_s)
		{
			//BARRA AMARELA E SETINHA NA ESCOLHIDA
			draw_set_alpha(_ca);
			draw_rectangle_color(_g[0] + 6, _y - 11, _g[2] - 6, _y + 11, #FFB21E, #FFE66B, #FFE66B, #FFB21E, false);
			var _bob = sin(current_time / 110) * 2;
			draw_set_color(#1B1038);
			draw_triangle(_g[0] + 9 + _bob, _y - 5, _g[0] + 9 + _bob, _y + 5, _g[0] + 15 + _bob, _y, false);
			draw_set_alpha(1);
		}
		draw_set_halign(fa_left);
		var _cor = _s ? #1B1038 : #C9C5F5;
		if(_l[i].id == "voltar" and !_s) _cor = #FF6B7D;
		draw_text_transformed_color(_g[0] + 24, _y + 1, _l[i].nome, .9, .9, 0, _cor, _cor, _cor, _cor, _ca);
		//VALOR NA DIREITA
		draw_set_halign(fa_right);
		var _vx = _g[2] - 16;
		switch(_l[i].id)
		{
			case "musica":
			case "efeitos":
				var _vol = _l[i].id == "musica" ? global.musica : global.som_geral;
				var _bx1 = _g[2] - 190, _bx2 = _g[2] - 70;
				draw_set_alpha(_ca);
				draw_set_color(#0E071B);
				draw_rectangle(_bx1, _y - 5, _bx2, _y + 5, false);
				draw_rectangle_color(_bx1, _y - 5, _bx1 + (_bx2 - _bx1) * _vol, _y + 5, #31FCFF, #8BFF32, #8BFF32, #31FCFF, false);
				draw_set_color(#5A3A8A);
				draw_rectangle(_bx1, _y - 5, _bx2, _y + 5, true);
				draw_set_alpha(1);
				draw_text_transformed_color(_vx, _y + 1, string(round(_vol * 100)) + "%", .85, .85, 0, _cor, _cor, _cor, _cor, _ca);
				break;
			case "shake":
			case "teclas":
			case "dificuldade":
				var _lig = _l[i].id == "shake" ? global.shake : (_l[i].id == "teclas" ? global.mostrar_teclas : global.teste_dif);
				var _tg = _lig ? (_pt ? "LIGADO" : "ON") : (_pt ? "DESLIGADO" : "OFF");
				var _w = string_width(_tg) * .8 + 10;
				draw_set_alpha(_ca);
				draw_set_color(#0E071B);
				draw_rectangle(_vx - _w + 4, _y - 8, _vx + 4, _y + 9, false);
				draw_set_alpha(1);
				var _cp = _lig ? #8BFF32 : #FF5577;
				draw_text_transformed_color(_vx - 1, _y + 1, _tg, .8, .8, 0, _cp, _cp, _cp, _cp, _ca);
				break;
		}
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

//OPÇOES DA PAUSA (STEP DO OBJ_GAME_CONTROL): CIMA/BAIXO ESCOLHE, ESQUERDA/DIREITA MUDA, ENTER LIGA/DESLIGA E O MOUSE FAZ O MESMO.
//DEVOLVE "reiniciar" QUANDO O TESTE DE DIFICULDADE MUDOU (O JOGO PRECISA RECOMEÇAR)
function pausa_opcoes_step(_up, _down, _enter)
{
	var _l = pausa_opcoes_linhas();
	var _n = array_length(_l);
	var _g = pausa_opcoes_geo();
	var _vis = pausa_vis();
	opcao_sub = clamp(opcao_sub, 0, _n - 1);

	//MOUSE: PASSAR POR CIMA ESCOLHE (SO SE MEXEU), CLICAR CONFIRMA
	var _sobre = -1;
	for(var i = 0; i < _n; i++)
	{
		var _y = pausa_opcoes_y(i);
		if(point_in_rectangle(_vis.mx, _vis.my, _g[0] + 6, _y - 12, _g[2] - 6, _y + 12)) _sobre = i;
	}
	if(_vis.moveu and _sobre != -1 and _sobre != opcao_sub)
	{
		opcao_sub = _sobre;
		som_tocar(snd_menu_select_03);
	}
	var _clique = mouse_check_button_pressed(mb_left) and _sobre != -1;
	if(_clique) opcao_sub = _sobre;

	if(_up xor _down)
	{
		opcao_sub = (opcao_sub + _down - _up + _n) mod _n;
		som_tocar(snd_menu_select_03);
	}

	//ESQUERDA/DIREITA (SEGURANDO REPETE)
	var _dir = (keyboard_check_pressed(ord("D")) or keyboard_check_pressed(vk_right)) - (keyboard_check_pressed(ord("A")) or keyboard_check_pressed(vk_left));
	var _seg = (keyboard_check(ord("D")) or keyboard_check(vk_right)) - (keyboard_check(ord("A")) or keyboard_check(vk_left));
	sub_hold = (_seg != 0) ? sub_hold + 1 : 0;
	if(sub_hold > 24 and sub_hold mod 4 == 0) _dir = _seg;

	var _id = _l[opcao_sub].id;
	var _mudar = _enter or _clique or _dir != 0;	//PARA AS CHAVES LIGA/DESLIGA
	switch(_id)
	{
		case "musica":
		case "efeitos":
			var _tc = _id == "musica";
			var _vol = _tc ? global.musica : global.som_geral;
			if(_dir != 0) _vol = clamp(round((_vol + _dir * .1) * 10) / 10, 0, 1);
			//MOUSE NA BARRA: CLICA OU ARRASTA PRA ESCOLHER O VOLUME
			var _bx1 = _g[2] - 190, _bx2 = _g[2] - 70;
			var _yb = pausa_opcoes_y(opcao_sub);
			if(mouse_check_button(mb_left) and point_in_rectangle(_vis.mx, _vis.my, _bx1 - 6, _yb - 12, _bx2 + 6, _yb + 12))
			{
				var _novo = clamp(round((_vis.mx - _bx1) / (_bx2 - _bx1) * 20) / 20, 0, 1);
				if(_novo != _vol) { _vol = _novo; _dir = 1; }
			}
			if(_dir != 0)
			{
				if(_tc) global.musica = _vol; else global.som_geral = _vol;
				som_tocar(snd_menu_select_02);
			}
			break;
		case "shake":
			if(_mudar) { global.shake = !global.shake; som_tocar(snd_menu_select_01); }
			break;
		case "teclas":
			if(_mudar) { global.mostrar_teclas = !global.mostrar_teclas; som_tocar(snd_menu_select_01); }
			break;
		case "dificuldade":
			if(_mudar)
			{
				som_tocar(snd_menu_select_01);
				global.teste_dif = !global.teste_dif;
				jogo_salvar();
				return "reiniciar";
			}
			break;
		case "voltar":
			if(_enter or _clique)
			{
				som_tocar(snd_menu_erro_02);
				ver_opcoes = false;
				jogo_salvar();
			}
			break;
	}
	return "";
}

//DESENHA A PAUSA (CHAMADO NO DRAW GUI DO OBJ_GAME_CONTROL). _A = FADE DA PAUSA, _T = FRAMES DESDE QUE PAUSOU (ANIMA A ENTRADA),
//_SEL = ANIMAÇAO DE CADA OPÇAO (0 A 1), _INDICE = OPÇAO ESCOLHIDA. TUDO EM PIXELS DA ROOM, MENOS O FUNDO (MATRIZ DE ESCALA)
function pausa_menu_desenhar(_a, _t, _sel, _indice)
{
	var _e = gui_esc();
	var _pt = global.linguagem == 0;
	var _v = pausa_vis();
	//O JOGO SOME ATRAS DO ESPAÇO (EM PIXELS DA GUI) E PASSA A DESENHAR EM PIXELS DA ROOM
	var _tl = gui_tela();
	draw_set_alpha(_a);
	draw_set_color(#130F2A);
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(1);
	matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, _e, _e, 1));

	pausa_estrelas_desenhar(_a);

	//SO DESENHA O RESTO ENQUANTO ESTA PAUSADO (FECHANDO, O ESPAÇO SO VAI SUMINDO)
	if(instance_exists(obj_game_control) and obj_game_control.pausado)
	{
		var _ent = 1 - power(1 - clamp(_t / 30, 0, 1), 3);
		pausa_feixe_desenhar(_a, _ent);
		pausa_chao_desenhar(_a);

		//OLHOS: MOUSE (ENQUANTO ELE MEXE) OU A OPÇAO ESCOLHIDA. TROCOU DE OPÇAO PELO TECLADO = VOLTA A OLHAR PRA ELA
		var _bs = pausa_botoes(_sel);
		if(_indice != _v.indice)
		{
			if(_v.mouse_t > 4) _v.mouse_t = 999;
			_v.indice = _indice;
		}
		var _ax = PAUSA_CX, _ay = 230;
		if(_v.mouse_t < 120) { _ax = _v.mx; _ay = _v.my; }
		else if(!ver_comandos and !ver_opcoes and _indice >= 0 and _indice < array_length(_bs)) { _ax = _bs[_indice][0]; _ay = _bs[_indice][1]; }
		pausa_olhos_atualizar(_ax, _ay);

		var _titulo = ver_comandos ? (_pt ? "COMANDOS" : "CONTROLS") : (ver_opcoes ? (_pt ? "OPÇÕES" : "OPTIONS") : texto("pausado"));
		pausa_nave_desenhar(_a, _t, _titulo);

		if(ver_comandos) pausa_comandos_desenhar(_a, _t);
		else if(ver_opcoes) pausa_opcoes_desenhar(_a, _t);
		else
		{
			//OS BOTOES ENTRAM DESLIZANDO DA ESQUERDA, UM DEPOIS DO OUTRO
			draw_set_font(fnt_table);
			draw_set_halign(fa_left);
			draw_set_valign(fa_middle);
			var _nomes = pausa_nomes();
			var _icos = [ #8BFF32, #FF8A1E, #31E8F0, #FF55D0, #FF5A66];
			for(var i = 0; i < array_length(_nomes); i++)
			{
				var _en = 1 - power(1 - clamp((_t - 8 - i * 3) / 12, 0, 1), 3);
				var _b = _bs[i];
				_b[0] -= (1 - _en) * 280;
				pausa_botao_desenhar(_b, _nomes[i], _sel[i], _a * _en, _icos[i mod 5], i == array_length(_nomes) - 1);
			}
		}

		//BARRA DE TECLAS NO CANTO
		if(ver_comandos) menu_dicas([["ESC", _pt ? "VOLTAR" : "BACK"]], true);
		else if(ver_opcoes) menu_dicas([["SETAS", _pt ? "ESCOLHER / MUDAR" : "CHOOSE / CHANGE"], ["ESC", _pt ? "VOLTAR" : "BACK"]], true);
		else menu_dicas([["SETAS", _pt ? "ESCOLHER" : "CHOOSE"], ["ENTER", _pt ? "ABDUZIR" : "ABDUCT"]], true);
	}
	matrix_set(matrix_world, matrix_build_identity());
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

//==================== MENU PRINCIPAL NOVO (OBJ_MENU_PRINCIPAL) ====================
//LISTA UNICA NA ESQUERDA (TODAS AS OPÇOES A VISTA, UMA EMBAIXO DA OUTRA), E NA DIREITA UM CARTAO QUE EXPLICA A OPÇAO SELECIONADA.
//EMBAIXO, A BARRA COM AS TECLAS DE CADA TELA. NAVEGAÇAO: CIMA/BAIXO (OU W/S), ESPAÇO/ENTER ESCOLHE, ESC VOLTA, E O MOUSE TAMBEM FUNCIONA.
//COOP E VERSUS SAEM DIRETO DA LISTA (SEM SUBMENU) E O "TUTORIAL" AGORA ABRE O TUTORIAL DE VERDADE (A TABELA DOS BLOCOS VIROU "BLOCOS").
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
		{ id : "tutorial", grupo : 1, tag : "",
			nome : ["TUTORIAL", "TUTORIAL"],
			desc : ["O TERRÍVEL ZORG NÃO VAI SER NEM UM POUCO GENTIL, ENTÃO VOCÊ PRECISA SABER O QUE FAZER. APRENDA A SOBREVIVER NO DESAFIO DA GRADE!",
					"THE TERRIBLE ZORG WON'T BE KIND AT ALL, SO YOU NEED TO KNOW WHAT TO DO. LEARN TO SURVIVE THE GRID CHALLENGE!"] },
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
	global.tutorial_forcar = false;		//VOLTOU DA SELEÇAO SEM JOGAR: NAO FICA PEDINDO O TUTORIAL NA PROXIMA PARTIDA
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
		case "tutorial":	//VAI ESCOLHER O PERSONAGEM E COMEÇA NO TUTORIAL DA DONA MALHADA (MESMO QUE JA TENHA FEITO)
			som_tocar(snd_menu_select_01);
			global.versus_sel = false;
			global.coop = false;
			global.tutorial_forcar = true;
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
function menu_dicas(_lista)
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
	var _x = room_width / 2 - _larg / 2;
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
	draw_sprite_ext(spr_bg_ape, 0, 128 + 1, 52 + 1, _ls, _ls, angle_title * .6, _sombra, 1);
	draw_sprite_ext(spr_bg_ape, 0, 128, 52, _ls, _ls, angle_title * .6, c_white, 1);
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

		//SELO NA DIREITA: 1P / 2P, E "NOVO!" PISCANDO NO TUTORIAL ENQUANTO ELE NAO FOI FEITO
		var _tag = _it.tag;
		var _novo = (_it.id == "tutorial" and !global.tutorial_feito);
		if(_novo) _tag = _pt ? "NOVO!" : "NEW!";
		if(_tag != "")
		{
			var _tx = MENU_PAINEL_X - 62;
			draw_set_halign(fa_right);
			if(_novo)
			{
				var _w = string_width(_tag) * .8 + 8;
				draw_set_alpha(_a * ((current_time div 350) mod 2 == 0 ? 1 : .55));
				draw_set_color(#E5173A);
				draw_rectangle(_tx - _w + 4, _y - 7, _tx + 4, _y + 8, false);
				draw_set_alpha(1);
				draw_text_transformed_color(_tx, _y + 1, _tag, .8, .8, 0, c_white, c_white, c_white, c_white, _a);
			}
			else
			{
				var _ct = merge_color(#92A1B9, #1B1038, _s);
				draw_text_transformed_color(_tx, _y + 1, _tag, .8, .8, 0, _ct, _ct, _ct, _ct, _a);
			}
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
			if(!global.tutorial_feito) array_push(_ex, [_pt ? "AVISO" : "NOTE", _pt ? "NA PRIMEIRA VEZ, COMEÇA PELO TUTORIAL" : "THE FIRST TIME STARTS WITH THE TUTORIAL", #FFE66B]);
			break;
		case "coop":
			array_push(_ex, [_pt ? "RECORDE" : "RECORD", string(global.record_coop), #8BFF32]);
			break;
		case "tutorial":
			array_push(_ex, [_pt ? "SITUAÇÃO" : "STATUS", global.tutorial_feito ? (_pt ? "JÁ FEITO (PODE REFAZER)" : "DONE (YOU CAN REDO IT)") : (_pt ? "AINDA NÃO FEITO" : "NOT DONE YET"), global.tutorial_feito ? #8BFF32 : #FFE66B]);
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

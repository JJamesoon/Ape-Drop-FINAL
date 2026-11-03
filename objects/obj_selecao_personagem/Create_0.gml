if(MOBILE and !instance_exists(obj_mobile)) instance_create_depth(0, 0, -15000, obj_mobile); //SO NO CELULAR: LAYOUT MOBILE (SCR_MOBILE)
//MUSICA E SAVE
som_iniciar_controle();

//TELA DE ESCOLHER PERSONAGEM (ARCADE, PLAYER 1)
indice = global.skin_player_1;
prox_room = global.coop ? rm_coop : rm_arcade;	//ROOM QUE VAI DEPOIS DE ESCOLHER (O COOP TEM A ARENA LARGA)
timer = 0;	//ANIMAÇAO DE BALANÇO
jogador_escolhendo = 1;	//NO COOP: QUEM TA ESCOLHENDO AGORA (1 E DEPOIS 2)

//ESCALA DE CADA PERSONAGEM (O ESCOLHIDO FICA MAIOR)
esc = [];
repeat(array_length(global.skins)) array_push(esc, 1);

shake_msg = 0; //TREME O PERSONAGEM QUANDO NAO TEM MOEDA PRA COMPRAR

//PAINEIS NO ESTILO SUNSET RIDERS (DRAW): LARGURA, ALTURA, TOPO, ESPAÇO ENTRE ELES E O TAMANHO DO RETRATO
#macro SEL_LARG		148
#macro SEL_ALT		206
#macro SEL_TOPO		74
#macro SEL_ESPACO	164
#macro SEL_RETRATO	2.3
painel_sobe = array_create(array_length(global.skins), 0);	//O PAINEL ESCOLHIDO SOBE UM POUCO

//POSIÇAO X (MEIO DO PAINEL) DE CADA PERSONAGEM NA TELA (USADO NO DRAW E NOS TEXTOS)
x_personagem = function(_i)
{
	return room_width/2 - SEL_ESPACO * (array_length(global.skins) - 1) / 2 + SEL_ESPACO * _i;
}

//CORES DO PAINEL DE CADA PERSONAGEM: [FAIXA DE CIMA, FUNDO, MOLDURA DE DENTRO]
selecao_cores = function(_i)
{
	switch(_i)
	{
		case personagem.macaco:		return [ #FF5A78, #8A1428, #FF9AAA];
		case personagem.tartaruga:	return [ #6CE04A, #1C5A24, #A8F08C];
		case personagem.falcao:		return [ #FFC83C, #6E3C14, #FFE08C];
		case personagem.dino:		return [ #4AB4FF, #1C2C6E, #9AD4FF];
	}
	return [ #C7CFDD, #2E2A4A, c_white];
}

//==================== ANIMAÇAO DA ESCOLHA (CONFIRMAR) E ENFEITES ====================
//AO CONFIRMAR: CLARAO, ANEIS DE ONDA, FAGULHAS, O PAINEL ESCOLHIDO SOBE E VAI PRO MEIO (OS OUTROS ESCURECEM E CAEM),
//O PERSONAGEM DA UM PULO E O NOME CARIMBA NUMA FAIXA ("O ESCOLHIDO"). SO ENTAO COMEÇA A TRANSIÇAO PRO JOGO
conf = -1;				//FRAMES DA ANIMAÇAO DE CONFIRMAR (-1 = NAO ESTA CONFIRMANDO)
conf_i = 0;				//QUEM FOI CONFIRMADO
conf_longo = true;		//A ESCOLHA FINAL (VAI PRO JOGO) TEM A ANIMAÇAO COMPLETA. A DO PLAYER 1 NO COOP E CURTA
conf_dur = 0;			//DURAÇAO DA ANIMAÇAO
conf_saiu = false;		//A TRANSIÇAO PRO JOGO JA COMEÇOU?
out_k = 0;				//0 A 1: QUANTO OS OUTROS PAINEIS JA ESCURECERAM/CAIRAM
sel_dx = 0;				//QUANTO O PAINEL CONFIRMADO JA ANDOU PRO MEIO DA TELA
flash = 0;				//CLARAO BRANCO
brilho_t = 0;			//TEMPO DO BRILHO QUE PASSA NO PAINEL ESCOLHIDO
aneis = [];				//ANEIS DE ONDA { X, Y, R, V, A, COR, ATRASO }
fagulhas = [];			//PARTICULAS { X, Y, VX, VY, LIFE, DUR, COR, T }
ativa = array_create(array_length(global.skins), 0);	//0 A 1: QUANTO O PAINEL ESTA "ACESO" (LUZ E BRILHO)

//SAI ATE UM TETO DE ALTURA E VOLTA COM UM LEVE ESTOURO (EFEITO "CARIMBO")
ease_back = function(_k)
{
	var _c1 = 1.70158;
	return 1 + (_c1 + 1) * power(_k - 1, 3) + _c1 * power(_k - 1, 2);
}

//FAGULHAS PARA TODOS OS LADOS
selecao_explodir = function(_x, _y, _n, _cores)
{
	repeat(_n)
	{
		var _d = random(360);
		var _v = random_range(1.5, 5);
		array_push(fagulhas, { x : _x, y : _y, vx : lengthdir_x(_v, _d), vy : lengthdir_y(_v, _d) - 1, life : irandom_range(28, 56), dur : 56, cor : _cores[irandom(array_length(_cores) - 1)], t : choose(2, 2, 3, 4) });
	}
}

//ANEL DE ONDA QUE ABRE
selecao_anel = function(_x, _y, _cor, _atraso = 0)
{
	array_push(aneis, { x : _x, y : _y, r : 4, v : 7, a : 1, cor : _cor, atraso : _atraso });
}

//CONFIRMOU O PERSONAGEM (O PAINEL JA ESTA LIBERADO)
selecao_confirmar = function()
{
	conf_i = indice;
	conf = 0;
	conf_saiu = false;
	conf_longo = !(global.coop and jogador_escolhendo == 1);
	conf_dur = conf_longo ? 100 : 44;
	if(jogador_escolhendo == 2) global.skin_player_2 = indice;
	else global.skin_player_1 = indice;
	var _c = selecao_cores(indice);
	var _x = x_personagem(indice);
	var _y = SEL_TOPO + SEL_ALT / 2;
	flash = 1;
	esc[indice] = 1.3;
	som_tocar(snd_menu_confirm_01);
	audio_play_sound(snd_jingle_poder, 1, false, .55, 0, 1.25);
	audio_play_sound(snd_hit2, 1, false, .6, 0, 1.3);
	selecao_explodir(_x, _y, 40, [_c[0], _c[2], c_white, #FFE66B]);
	selecao_anel(_x, _y, _c[2], 0);
	selecao_anel(_x, _y, c_white, 5);
	selecao_anel(_x, _y, _c[0], 10);
	if(conf_longo) jogo_salvar();
}

//TODO FRAME DA ANIMAÇAO DE CONFIRMAR
selecao_conf_passo = function()
{
	conf = min(conf + 1, conf_dur + 60);
	var _c = selecao_cores(conf_i);
	var _inicio = conf_longo ? 14 : 7;		//QUANDO O NOME CARIMBA
	if(conf == _inicio)
	{
		flash = max(flash, .5);
		audio_play_sound(snd_hit2, 1, false, .85, 0, .95);
		selecao_explodir(room_width / 2, 366, 30, [_c[0], c_white, #FFE66B]);
		selecao_anel(room_width / 2, 366, c_white, 0);
	}
	//COMEÇA A TRANSIÇAO PRO JOGO COM A ANIMAÇAO QUASE NO FIM
	if(conf_longo and conf >= conf_dur - 22 and !conf_saiu)
	{
		conf_saiu = true;
		scr_trans(prox_room);
	}
	//COOP: ACABOU A ESCOLHA DO PLAYER 1, AGORA E A DO PLAYER 2
	if(!conf_longo and conf >= conf_dur)
	{
		jogador_escolhendo = 2;
		indice = global.pers_liberados[global.skin_player_2] ? global.skin_player_2 : personagem.macaco;
		conf = -1;
	}
}

//VERSUS: OS DOIS ESCOLHEM AO MESMO TEMPO (SCR_COOP, VERSUS_SEL_*)
versus_sel_criar();

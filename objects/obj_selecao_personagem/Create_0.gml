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

//NO CELULAR O MENU E O RM_MENU_MOBILE (SO TEM O ARCADE)
if(MOBILE)
{
	instance_destroy();
	room_goto(rm_menu_mobile);
	exit;
}
//MENU DO PC (RM_MENU): TELA DE TITULO, MENU PRINCIPAL, VERSUS/COOP, CONFIGURAÇOES E CREDITOS
//MUSICA E SAVE (E NO TESTE AUTOMATICO PULA DIRETO PRO ARCADE)
som_iniciar_controle();
if(TESTE_AUTO) room_goto(rm_arcade);

enum menu
{
	inicio,		//TELA DE TITULO ("APERTE ESPAÇO")
	principal,	//ARCADE, VERSUS, TUTORIAL, RANKS, STEAM, EXIT + CONFIG E CREDITOS NOS LADOS
	versus,		//ESCOLHER ENTRE VERSUS E COOP
	config,		//CONFIGURAÇOES
	creditos,
	ranks,		//RECORDES SALVOS NESSE COMPUTADOR (MESMO PAINEL DAS CONFIGURAÇOES)
	blocos		//TABELA DOS BLOCOS (BOTAO TUTORIAL): OS DESCOBERTOS MOSTRAM O QUE FAZEM
}

//BOTOES DO MENU PRINCIPAL (MESMA ORDEM DOS FRAMES DA SPR_MENU)
enum menu_pri
{
	arcade,
	versus,
	tutorial,
	ranks,
	steam,
	sair
}

//OPÇOES DAS CONFIGURAÇOES
enum menu_conf
{
	audio,
	controles,
	jogo,
	idioma,
	total
}

//COMEÇA NA TELA DE TITULO
estado = menu.inicio;

//VOLTANDO DE OUTRA ROOM (EX: SELEÇAO DE PERSONAGEM) JA CAI NO MENU PRINCIPAL
if(variable_global_exists("menu_principal") and global.menu_principal) estado = menu.principal;
global.menu_principal = false;

timer_inicio = 10; //IMPEDE DE PULAR A TELA DE TITULO SEM QUERER

//FUNDO E TITULO
esc_fundo = .5;
esc_fundo_lerp = esc_fundo;
_alpha = 0;
alpha_bg_blocos = 0;
y_title = -100;
angle_title = 30;
alpha_title = 1;
timer_title = 0;

//MENU PRINCIPAL
indice = 0;		//BOTAO DO MEIO SELECIONADO
indice_h = 0;	//-1 = CONFIG, 0 = BOTOES DO MEIO, 1 = CREDITOS
array_y_menu = [];
array_alpha = [];
shake_msg = [];		//TREMIDA NO BOTAO DE MODO INDISPONIVEL
alpha_fog_msg = [];	//BRILHO VERMELHO NO BOTAO DE MODO INDISPONIVEL
repeat(sprite_get_number(spr_menu))
{
	array_push(array_y_menu, 0);
	array_push(array_alpha, .5);
	array_push(shake_msg, 0);
	array_push(alpha_fog_msg, 0);
}
array_x_menu_h = [0, 0];
array_alpha_hor = [.5, .5];

//MENSAGEM "MODO INDISPONIVEL"
mostrar_msg = 0;
alpha_msg = 0;

//VERSUS / COOP
indice_versus = 0;
y_versus = [0, 0];

//CONFIGURAÇOES
conf_sub = noone;	//SUBMENU ABERTO (NOONE = LISTA PRINCIPAL)
conf_indice = 0;
conf_x = [];		//POSIÇAO X DE CADA LINHA (ANIMAÇAO)
conf_alpha = [];
timer_press = 0;	//SEGURAR ESQUERDA/DIREITA NO VOLUME
alpha_conf = 0;

//RANKS (PAINEL APARECE SUAVE)
alpha_ranks = 0;
alpha_blocos = 0;	//TABELA DOS BLOCOS
blocos_sel = 0;		//BLOCO SELECIONADO NA TABELA

//CREDITOS
creditos_y = 0;
alpha_img_creditos = 0;

//FRASE QUE PASSA NO TOPO
frase_x = 30;

//PERSONAGENS CORRENDO PELA BORDA NA TELA DE TITULO
players = [];

//ADICIONA UM PERSONAGEM CORRENDO PELA BORDA DA TELA
criar_player = function(_x, _y, _skin)
{
	array_push(players, {
		x		: _x,
		y		: _y,
		vel		: .5,
		angle	: 90,
		dir		: 270,
		jump	: 0,
		estado	: "Run",
		skin	: _skin
	});
}

//UM DE CADA SKIN, UM ATRAS DO OUTRO
for(var i = 0; i < array_length(global.skins); i++)
{
	criar_player(room_width, room_height/2 + 25 - 30 * i, i);
}

//ANDA O PERSONAGEM PELA BORDA: CHEGOU NUMA QUINA, DA UM PULINHO E VIRA 90 GRAUS
mover_player = function(p)
{
	p.x += lengthdir_x(p.vel, p.dir);
	p.y += lengthdir_y(p.vel, p.dir);

	//SALTO NA HORA DE VIRAR A QUINA
	p.x += lengthdir_x(p.jump, p.dir - 90);
	p.y += lengthdir_y(p.jump, p.dir - 90);
	if(p.jump > 0) p.jump -= .2;

	if(p.estado == "Run")
	{
		if		(p.dir == 270 and p.y >= room_height - 10)	{ p.estado = "Jump"; p.jump = 2; }
		else if (p.dir == 180 and p.x <= 10)				{ p.estado = "Jump"; p.jump = 2; }
		else if (p.dir == 90  and p.y <= 10)				{ p.estado = "Jump"; p.jump = 2; }
		else if (p.dir == 0   and p.x >= room_width - 10)	{ p.estado = "Jump"; p.jump = 2; }
	}
	else
	{
		switch(p.dir)
		{
			case 270:
				p.angle = lerp(p.angle, 0, .2);
				if(p.y >= room_height - 1) { p.y = room_height; p.dir = 180; p.angle = 0; p.estado = "Run"; p.jump = 0; }
				break;
			case 180:
				p.angle = lerp(p.angle, -90, .2);
				if(p.x <= 1) { p.x = 0; p.dir = 90; p.angle = -90; p.estado = "Run"; p.jump = 0; }
				break;
			case 90:
				p.angle = lerp(p.angle, -180, .2);
				if(p.y <= 1) { p.y = 0; p.dir = 0; p.angle = 180; p.estado = "Run"; p.jump = 0; }
				break;
			case 0:
				p.angle = lerp(p.angle, 90, .2);
				if(p.x >= room_width - 1) { p.x = room_width; p.dir = 270; p.angle = 90; p.estado = "Run"; p.jump = 0; }
				break;
		}
	}
}

//LISTA DE LINHAS DA CONFIGURAÇAO ATUAL
conf_linhas = function()
{
	switch(conf_sub)
	{
		case menu_conf.audio:		return [texto("musica"), texto("som_geral")];
		case menu_conf.controles:	return [texto("layout"), texto("mover"), texto("pular"), texto("soco"), texto("soco_forte"), texto("giro"), texto("queda_livre"), texto("dash"), texto("especial")];
		case menu_conf.jogo:		return [texto("tela_cheia"), texto("tremor"), texto("teclas_tela")];
	}
	return [texto("audio"), texto("control"), texto("op_game"), texto("language")];
}

//ZERA A ANIMAÇAO DAS LINHAS QUANDO TROCA DE TELA NAS CONFIGURAÇOES
conf_resetar_anim = function()
{
	conf_x = [];
	conf_alpha = [];
	repeat(array_length(conf_linhas()))
	{
		array_push(conf_x, 0);
		array_push(conf_alpha, .5);
	}
}
conf_resetar_anim();

//INDISPONIVEL: TREME O BOTAO E MOSTRA A MENSAGEM
modo_indisponivel = function(_i)
{
	shake_msg[_i] = 4;
	alpha_fog_msg[_i] = 1;
	mostrar_msg = room_speed * .8;
	som_tocar(snd_menu_erro_04);
}

//LISTA NOVA DO MENU PRINCIPAL (SCR_MENU)
menu_novo_criar();

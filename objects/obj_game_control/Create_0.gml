if(MOBILE and !instance_exists(obj_mobile)) instance_create_depth(0, 0, -15000, obj_mobile); //SO NO CELULAR: LAYOUT MOBILE (SCR_MOBILE)
pause_timer = 0;

som_iniciar_controle();
if(TESTE_AUTO) instance_create_depth(0, 0, 0, obj_teste_auto);

//FUNDO DO JOGO (PAREDE DE AZULEJOS, CHIADO NA COR DO LEVEL E VINHETA): SCR_GAMEFEEL
fundo_xiado = -1;
if(modo_arcade()) fundo_iniciar();

//TESTE: A PARTIDA JA COMEÇA NUM LEVEL E COM UM TEMPO DE JOGO (GLOBAIS: TESTE_INICIO_*). O TEMPO LIBERA OS BLOCOS DAQUELE MINUTO
if(modo_arcade() and !TESTE_AUTO)
{
	//PAUSA > TESTE DE DIFICULDADE: LEVEL 3 E 20 MINUTOS DE JOGO (PRA TODOS OS BLOCOS JA APARECEREM)
	if(global.teste_dif and !modo_versus()) { global.level = 3; global.nivel_vel = 3; global.tempo_partida = 20 * 60; }
	if(TESTE_INICIO_LEVEL > 1) { global.level = TESTE_INICIO_LEVEL; global.nivel_vel = TESTE_INICIO_LEVEL; }
	if(TESTE_INICIO_MINUTOS > 0) global.tempo_partida = TESTE_INICIO_MINUTOS * 60;
}

//PAUSE (ESC) E FIM DE JOGO
pausado = false;
ver_comandos = false;	//PAUSA: TELA COM OS COMANDOS (TECLADO E CONTROLE)
menu_debug = false;	//MENU DE DEBUG DOS BLOCOS (ENTER) ABERTO
debug_opcao = 0;	//BLOCO SELECIONADO NO MENU DE DEBUG
fim_jogo = false;		//TELA DE GAME OVER APARECENDO
timer_fim = 0;			//ESPERA A ANIMAÇAO DE MORTE ANTES DO GAME OVER
alpha_fim = 0;
novo_recorde = false;
recorde_inicio = recorde_atual(); //PRA SABER SE BATEU O RECORDE NESSA PARTIDA
alpha_pause = 0;

//MENUS
opcao_pause = 0;	//0 CONTINUAR, 1 REINICIAR, 2 MENU
opcao_fim = 0;		//0 JOGAR DE NOVO, 1 MENU
frase_fim = 0;		//FRASE MOTIVACIONAL SORTEADA NO FIM
timer_menu_fim = 0;
pontos_anim = 0;	//PONTOS CONTANDO NA TELA DE RESULTADO
timer_marcar = 0;	//DE QUANTO EM QUANTO TEMPO MARCA OS GRUPOS DO ESPECIAL

//ONDA DE PEÇAS (SCR_PONTOS)
onda_proxima	= ONDA_PRIMEIRA;	//FRAMES ATE A PROXIMA ONDA
laser_proxima	= LASER_ONDA_PRIMEIRA;	//FRAMES ATE A PROXIMA ONDA DE LASER
dupla_proxima	= DUPLA_PRIMEIRA;	//FRAMES ATE AS PROXIMAS PEÇAS DUPLAS
onda_restantes	= 0;				//PEÇAS QUE AINDA VAO CAIR NA ONDA ATUAL
onda_espera		= 0;				//FRAMES ATE A PROXIMA PEÇA DA ONDA
onda_falhas		= 0;				//FRAMES SEM ESPAÇO PRA PEÇA DA ONDA (ARENA MUITO CHEIA: DESISTE)

//GAMEFEEL (SCR_GAMEFEEL): A TELA E DESENHADA NO POST DRAW, COM O SHADER DA ONDA DE CHOQUE
application_surface_draw_enable(false);
global.ondas_choque = [];
global.calor = [];
//ENDEREÇOS DOS UNIFORMS DO SHADER DA ONDA DE CHOQUE
u_onda_tela		= shader_get_uniform(sh_onda_choque, "u_tela");
u_onda_dados	= shader_get_uniform(sh_onda_choque, "u_ondas");
u_onda_largura	= shader_get_uniform(sh_onda_choque, "u_largura");
u_calor			= shader_get_uniform(sh_onda_choque, "u_calor");
u_calor_info	= shader_get_uniform(sh_onda_choque, "u_calor_info");
u_parado		= shader_get_uniform(sh_onda_choque, "u_parado");
u_parado_info	= shader_get_uniform(sh_onda_choque, "u_parado_info");

//LETRAS D R O P E MENU DE PODER (SCR_PODERES)
letra_timer		= LETRA_PRIMEIRA;	//TEMPO ATE APARECER A PROXIMA LETRA
menu_poder		= false;	//MENU DE ESCOLHER PODER ABERTO?
poder_opcoes	= [];	//IDS DOS PODERES SORTEADOS
poder_opcao		= 0;	//CARD SELECIONADO
timer_menu_poder = 0;	//ESPERA UM POUCO ANTES DE ACEITAR TECLA (PRA NAO ESCOLHER SEM QUERER)
alpha_menu		= 0;	//TRANSPARENCIA DO MENU
palavra_festejada = false;	//A FESTA DA PALAVRA COMPLETA JA ACONTECEU (AGORA ABRE OS PODERES)

//COMPLETOU APEDROP: PAUSA E SORTEIA 3 PODERES QUE O JOGADOR AINDA NAO TEM
poder_menu_abrir = function()
{
	menu_poder = true;
	poder_opcao = 0;
	timer_menu_poder = room_speed * .6;
	var _disp = [];
	for(var i = 0; i < array_length(global.poderes_lista); i++)
	{
		if(!tem_poder(global.poderes_lista[i].id)) array_push(_disp, global.poderes_lista[i].id);
	}
	array_shuffle_ext(_disp);
	poder_opcoes = [];
	for(var i = 0; i < min(3, array_length(_disp)); i++) array_push(poder_opcoes, _disp[i]);
	//PRIMEIRO PODER DA PARTIDA: O PRIMEIRO CARD E SEMPRE ASAS (PULO DUPLO) OU DASH
	if(array_length(global.poderes) == 0 and array_length(poder_opcoes) > 0)
	{
		var _mov = choose("asas", "dash");
		var _onde = -1;
		for(var i = 0; i < array_length(poder_opcoes); i++) if(poder_opcoes[i] == "asas" or poder_opcoes[i] == "dash") { _onde = i; break; }
		if(_onde == -1) poder_opcoes[0] = _mov;	//NENHUM DOS DOIS VEIO: ENTRA NO LUGAR DO PRIMEIRO
		else { var _tmp = poder_opcoes[0]; poder_opcoes[0] = poder_opcoes[_onde]; poder_opcoes[_onde] = _tmp; }
	}
	//NENHUM PODER NOVO PRA OFERECER (JA TEM TODOS): NAO ABRE, SO ZERA AS LETRAS
	if(array_length(poder_opcoes) == 0)
	{
		menu_poder = false;
		letras_reiniciar();
		exit;
	}
	som_tocar(snd_new_level);
}

//ESCOLHEU: GANHA O PODER, ZERA AS LETRAS E MOSTRA O NOME DO PODER EM CIMA DO PLAYER
poder_menu_escolher = function()
{
	if(array_length(poder_opcoes) == 0) { menu_poder = false; exit; }
	var _op = poder_opcoes[clamp(poder_opcao, 0, array_length(poder_opcoes) - 1)];
	
	poder_ganhar(_op);
	letras_reiniciar(); //DEPOIS DO 1O PODER A PALAVRA VIRA DROP
	menu_poder = false;
	som_tocar(snd_certo);
	if(instance_exists(obj_player)) efeito_texto(poder_nome(_op), obj_player.x, obj_player.y - 34, poder_info(_op).cor, 1.3);
}

//REINICIA A PARTIDA (SALVA O RECORDE ANTES)
reiniciar = function()
{
	recorde_checar();
	jogo_salvar();
	restart_globais();
	room_restart();
}

//VOLTA PRO MENU (SALVA O RECORDE ANTES). NO CELULAR VAI PRO MENU DO CELULAR
voltar_menu = function()
{
	recorde_checar();
	jogo_salvar();
	restart_globais();
	global.menu_principal = true;
	scr_trans(menu_room());
}

//COMEÇOU A PARTIDA: ZERA O QUE O JOGADOR "JA DESCOBRIU" (TIRA DE COMANDOS E GUIA DA 1A LINHA, SCR_PODERES)
if(modo_arcade()) habil_zerar();
min_aviso = floor(global.tempo_partida / 60);	//ULTIMO MINUTO DE PARTIDA QUE JA AVISOU "PEÇAS MAIS RAPIDAS"

//ZORG, O ALIEN QUE CONTROLA A GRADE (SCR_PODERES): ZERA O ESTADO DELE NA PARTIDA
zorg_iniciar();

//AS 5 PRIMEIRAS PEÇAS DO ARCADE SAO SEMPRE AS MESMAS (CRIAR_PECAS)
abertura_iniciar();

//EFEITO DE AMBIENTE: FRIO (CRIAR_PECAS)
frio_iniciar_partida();

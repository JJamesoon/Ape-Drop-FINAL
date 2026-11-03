//SAVE DO JOGO==================================
#macro ARQUIVO_SAVE "ApeDrop_save.ini"

//VALORES PADRAO (USADOS NA PRIMEIRA VEZ QUE O JOGO ABRE, QUANDO AINDA NAO TEM SAVE)
global.record_1		= 0;	//RECORDE DO ARCADE
global.record_2		= 0;	//RECORDE DO PLAYER 2
global.record_coop	= 0;	//RECORDE DO COOP

global.som_geral	= 1;	//VOLUME GERAL (0 A 1)
global.musica		= .5;	//VOLUME DA MUSICA (0 A 1)
global.tutorial_feito = false;	//JA FEZ O TUTORIAL DA DONA MALHADA (SALVO)
global.teste_dif = false;	//PAUSA > TESTE DE DIFICULDADE: A PARTIDA COMEÇA COM 20 MIN E LEVEL 3 (TODOS OS BLOCOS). NAO CONTA RECORDE. SOBREVIVE AO REINICIAR
global.tutorial_forcar = false;	//A PAUSA PEDIU PRA REFAZER O TUTORIAL (VALE SO NA PROXIMA PARTIDA)
global.mostrar_teclas = true;	//TIRA DE COMANDOS NO RODAPE DA PARTIDA LIGADA (CONFIGURAÇOES E PAUSA)
global.shake		= true;	//TREMIDA DA TELA LIGADA
global.full_screen	= false;	//TELA CHEIA
global.linguagem	= 0;	//0 = PT_BR, 1 = INGLES
global.tempo_de_jogo = 0;	//SEGUNDOS JOGADOS NO TOTAL
global.moedas		= 0;	//MOEDAS GUARDADAS (COMPRAM PERSONAGENS)
global.pers_liberados = [true, false, false, false]; //MACACO JA VEM LIBERADO

//GRAVA TUDO NO ARQUIVO .INI (EM %LOCALAPPDATA%\<NOME DO PROJETO>)
function jogo_salvar()
{
	ini_open(ARQUIVO_SAVE);

	//RECORDES
	ini_write_real("recordes", "arcade",	global.record_1);
	ini_write_real("recordes", "player_2",	global.record_2);
	ini_write_real("recordes", "coop",		global.record_coop);

	//CONFIGURAÇOES
	ini_write_real("config", "som_geral",	global.som_geral);
	ini_write_real("config", "musica",		global.musica);
	ini_write_real("config", "shake",		global.shake);
	ini_write_real("config", "teclas_tela",	global.mostrar_teclas ? 1 : 0);
	ini_write_real("config", "tutorial_feito", global.tutorial_feito ? 1 : 0);
	ini_write_real("config", "tela_cheia",	global.full_screen);
	ini_write_real("config", "idioma",		global.linguagem);
	ini_write_real("config", "controles",	global.meus_imputs);

	//PERSONAGEM ESCOLHIDO
	ini_write_real("personagem", "player_1", global.skin_player_1);
	ini_write_real("personagem", "player_2", global.skin_player_2);

	//TEMPO DE JOGO, MOEDAS E PERSONAGENS LIBERADOS
	ini_write_real("geral", "tempo_de_jogo", global.tempo_de_jogo);
	ini_write_real("geral", "moedas", global.moedas);
	for(var i = 0; i < array_length(global.pers_liberados); i++)
	{
		ini_write_real("personagem", "liberado_" + string(i), global.pers_liberados[i]);
	}

	//BLOCOS QUE O JOGADOR JA DESCOBRIU (TABELA DO MENU)
	var _cat = blocos_catalogo();
	for(var i = 0; i < array_length(_cat); i++) ini_write_real("blocos", _cat[i].id, bloco_visto(_cat[i].id));

	ini_close();
}

//LE O ARQUIVO .INI (CHAMADO UMA VEZ, QUANDO O OBJ_CONTROLA_SOM NASCE)
function jogo_carregar()
{
	ini_open(ARQUIVO_SAVE);

	//O TERCEIRO VALOR E O PADRAO: SE AINDA NAO TIVER SAVE, FICA O VALOR DE CIMA
	global.record_1		= ini_read_real("recordes", "arcade",	global.record_1);
	global.record_2		= ini_read_real("recordes", "player_2",	global.record_2);
	global.record_coop	= ini_read_real("recordes", "coop",		global.record_coop);

	global.som_geral	= ini_read_real("config", "som_geral",	global.som_geral);
	global.musica		= ini_read_real("config", "musica",		global.musica);
	global.shake		= ini_read_real("config", "shake",		global.shake);
	global.mostrar_teclas = ini_read_real("config", "teclas_tela", 1) == 1;
	global.tutorial_feito = ini_read_real("config", "tutorial_feito", 0) == 1;
	global.full_screen	= ini_read_real("config", "tela_cheia",	global.full_screen);
	global.linguagem	= ini_read_real("config", "idioma",		global.linguagem);
	global.meus_imputs	= ini_read_real("config", "controles",	global.meus_imputs);

	global.skin_player_1 = ini_read_real("personagem", "player_1", global.skin_player_1);
	global.skin_player_2 = ini_read_real("personagem", "player_2", global.skin_player_2);

	global.tempo_de_jogo = ini_read_real("geral", "tempo_de_jogo", global.tempo_de_jogo);
	global.moedas		 = ini_read_real("geral", "moedas", global.moedas);
	for(var i = 0; i < array_length(global.pers_liberados); i++)
	{
		global.pers_liberados[i] = ini_read_real("personagem", "liberado_" + string(i), global.pers_liberados[i]);
	}
	//O MACACO E SEMPRE LIBERADO
	global.pers_liberados[personagem.macaco] = true;

	//BLOCOS JA DESCOBERTOS (O NORMAL SEMPRE)
	global.blocos_vistos = { normal : true };
	var _cat = blocos_catalogo();
	for(var i = 0; i < array_length(_cat); i++) if(ini_read_real("blocos", _cat[i].id, 0) == 1) global.blocos_vistos[$ _cat[i].id] = true;

	ini_close();

	//GARANTINDO QUE O PERSONAGEM SALVO AINDA EXISTE
	global.skin_player_1 = clamp(global.skin_player_1, 0, personagem.total - 1);
	global.skin_player_2 = clamp(global.skin_player_2, 0, personagem.total - 1);
	if(!global.pers_liberados[global.skin_player_1]) global.skin_player_1 = personagem.macaco;
	if(!global.pers_liberados[global.skin_player_2]) global.skin_player_2 = personagem.macaco;
	
	//APLICANDO AS CONFIGURAÇOES CARREGADAS
	trocar_comandos(global.meus_imputs);
	window_set_fullscreen(global.full_screen);
}

//ATUALIZA OS RECORDES SE A PONTUAÇAO ATUAL PASSOU. RETORNA TRUE SE BATEU ALGUM
function recorde_checar()
{
	if(room == rm_versus or global.teste_dif) return false; //O VERSUS E O TESTE DE DIFICULDADE NAO TEM RECORDE
	var _novo = false;

	//CADA MODO TEM O SEU RECORDE
	//NO COOP OS PONTOS DO TIME (PONTOS_1) VAO PRO RECORDE DO COOP
	if(global.coop)
	{
		if(global.pontos_1 > global.record_coop)
		{
			global.record_coop = global.pontos_1;
			_novo = true;
		}
	}
	else if(global.pontos_1 > global.record_1)
	{
		global.record_1 = global.pontos_1;
		_novo = true;
	}
	if(global.pontos_2 > global.record_2)
	{
		global.record_2 = global.pontos_2;
		_novo = true;
	}
	if(global.pontos_coop > global.record_coop)
	{
		global.record_coop = global.pontos_coop;
		_novo = true;
	}

	return _novo;
}

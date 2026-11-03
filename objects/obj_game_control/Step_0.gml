//CONTROLADOR DA PARTIDA: GAME OVER, PAUSA, MENU DE PODER, TIMERS, ONDAS, PERIGO E TELEPORTE
//O EMPURRAOZINHO DA TELA DO TELEPORTE VOLTA PRO ZERO
global.lerp_y = lerp(global.lerp_y, 0, .1);
global.lerp_y_2 = lerp(global.lerp_y_2, 0, .1);

//FUNDO: O CHIADO ANIMA E VAI PRA COR DO LEVEL (RODA ATE NA PAUSA)
fundo_atualizar();

//TODOS OS PLAYERS ESTAO NA ANIMAÇAO DE MORTE? (NO COOP, SO QUANDO OS DOIS MORREM)
var _player_morto = todos_mortos();

//IMPUTS DOS MENUS (PAUSA E RESULTADO)
var _up		= keyboard_check_pressed(ord("W")) or keyboard_check_pressed(vk_up);
var _down	= keyboard_check_pressed(ord("S")) or keyboard_check_pressed(vk_down);
var _enter	= keyboard_check_pressed(vk_space) or keyboard_check_pressed(vk_enter) or (MOBILE and keyboard_check_pressed(global.imputs.soco));
var _voltar	= keyboard_check_pressed(vk_escape);

//ZORG: A FRASE NO TOPO DA TELA (SCR_PODERES)
if(!pausado and !menu_poder) zorg_atualizar();

#region FIM DE JOGO (TELA DE RESULTADO)
if(_player_morto and !fim_jogo)
{
	//ESPERA 1.5S DA ANIMAÇAO DE MORTE E ABRE A TELA DE RESULTADO (SALVA O RECORDE E SORTEIA A FRASE)
	timer_fim++;
	if(timer_fim > room_speed * 1.5)
	{
		fim_jogo = true;
		if(modo_versus() and !global.vs_contou and global.vs_perdedor > 0) { global.vs_contou = true; global.vs_vitorias[2 - global.vs_perdedor]++; } //VERSUS: UMA VITORIA PRA QUEM FICOU
		zorg_falar("morte", true);
		recorde_checar();
		novo_recorde = recorde_atual() > recorde_inicio and global.pontos_1 > 0;
		jogo_salvar();
		som_tocar(novo_recorde ? snd_new_level : snd_menu_erro_04);
		
		var _frases = texto("frases_fim");
		frase_fim = irandom(array_length(_frases) - 1);
		opcao_fim = 0;
		timer_menu_fim = room_speed * .8; //ESPERA UM POUCO ANTES DE ACEITAR TECLA (PRA NAO PULAR SEM QUERER)
	}
}
alpha_fim = lerp(alpha_fim, fim_jogo ? 1 : 0, .1);

if(fim_jogo)
{
	//OS NUMEROS VAO CONTANDO
	pontos_anim = lerp(pontos_anim, global.pontos_1, .08);
	if(abs(pontos_anim - global.pontos_1) < 1) pontos_anim = global.pontos_1;
	
	//DEPOIS DA ESPERA: CIMA/BAIXO ESCOLHE, R REINICIA, ESC VAI PRO MENU, ENTER CONFIRMA
	if(timer_menu_fim > 0) timer_menu_fim--;
	else if(!instance_exists(obj_transisao))
	{
		if(_up xor _down)
		{
			opcao_fim = !opcao_fim;
			som_tocar(snd_menu_select_03);
		}
		if(keyboard_check_pressed(ord("R"))) { reiniciar(); exit; }
		if(_voltar) { voltar_menu(); exit; }
		if(_enter)
		{
			som_tocar(snd_menu_select_01);
			if(opcao_fim == 0) reiniciar();
			else voltar_menu();
			exit;
		}
	}
	//NA TELA DE RESULTADO O RESTO DO JOGO NAO RODA
	exit;
}
#endregion

#region MENU DE DEBUG DOS BLOCOS (ENTER)
//ENTER NO ARCADE: PAUSA O JOGO E ABRE A LISTA DE BLOCOS. SETAS ESCOLHEM, ENTER FAZ ESSE BLOCO NASCER AGORA, ESC FECHA
if(DEBUG_BLOCOS and modo_arcade() and !modo_versus())
{
	//TECLA APERTADA (NO TESTE AUTOMATICO O OBJ_TESTE_AUTO "APERTA" PELA GLOBAL.TESTE_TECLA, QUE E GASTA AQUI)
	var _tecla = function(_k)
	{
		if(keyboard_check_pressed(_k)) return true;
		if(TESTE_AUTO and variable_global_exists("teste_tecla") and global.teste_tecla == _k) { global.teste_tecla = -1; return true; }
		return false;
	};
	if(!menu_debug and !pausado and !menu_poder and !_player_morto and !instance_exists(obj_transisao) and _tecla(vk_enter))
	{
		menu_debug = true;
		som_tocar(snd_menu_select_01);
		global.game_pause = true;
		exit;
	}
	if(menu_debug)
	{
		//OS ALARMES CONTINUAM CORRENDO NA PAUSA: SEGURA A PROXIMA PEÇA ENQUANTO O MENU TA ABERTO
		with(obj_area) if(alarm[0] > 0) alarm[0]++;
		with(obj_cria_peca) if(alarm[0] > 0) alarm[0]++;
		//DUAS COLUNAS: CIMA/BAIXO ANDA NA LISTA, ESQUERDA/DIREITA PULA DE COLUNA
		var _lista = debug_lista_blocos();
		var _n = array_length(_lista);
		var _metade = ceil(_n / 2);
		var _esq = keyboard_check_pressed(ord("A")) or _tecla(vk_left);
		var _dir = keyboard_check_pressed(ord("D")) or _tecla(vk_right);
		var _cima = _up or _tecla(vk_up);
		var _baixo = _down or _tecla(vk_down);
		var _antes = debug_opcao;
		if(_cima)	debug_opcao = (debug_opcao - 1 + _n) mod _n;
		if(_baixo)	debug_opcao = (debug_opcao + 1) mod _n;
		if(_esq and debug_opcao >= _metade)	debug_opcao -= _metade;
		if(_dir and debug_opcao + _metade < _n)	debug_opcao += _metade;
		if(debug_opcao != _antes) som_tocar(snd_menu_select_03);
		if(_voltar or _tecla(vk_escape))
		{
			menu_debug = false;
			som_tocar(snd_menu_erro_02);
		}
		else if(_tecla(vk_enter))
		{
			//O BLOCO ESCOLHIDO NASCE JA (SE O TOPO TIVER OCUPADO, NASCE NA PROXIMA VEZ)
			menu_debug = false;
			som_tocar(snd_menu_select_01);
			debug_preparar(_lista[debug_opcao]);
			with(obj_area)
			{
				criar_bloco();
				alarm[0] = instance_exists(obj_cria_peca) ? peca_tempo_criar() : 10; //TOPO OCUPADO: TENTA DE NOVO LOGO
			}
		}
		global.game_pause = true;
		exit;
	}
}
#endregion

#region PAUSA (ESC)
if(!_player_morto and !instance_exists(obj_transisao) and !menu_poder)
{
	//ESC OU P ABRE/FECHA A PAUSA (NA TELA DOS COMANDOS O ESC SO VOLTA PRA PAUSA)
	if(pausado and ver_comandos and _voltar)
	{
		ver_comandos = false;
		som_tocar(snd_menu_erro_02);
	}
	else if(_voltar or keyboard_check_pressed(ord("P")))
	{
		pausado = !pausado;
		opcao_pause = 0;
		som_tocar(pausado ? snd_menu_select_01 : snd_menu_erro_02);
	}
	//PAUSADO: CIMA/BAIXO ESCOLHE (CONTINUAR, COMANDOS, REINICIAR, MENU), R REINICIA, Q VAI PRO MENU
	//NA TELA DOS COMANDOS QUALQUER TECLA DE CONFIRMAR OU VOLTAR FECHA ELA (O ESC NAO TIRA DA PAUSA)
	else if(pausado and ver_comandos)
	{
		if(_enter or keyboard_check_pressed(vk_backspace)) { ver_comandos = false; som_tocar(snd_menu_erro_02); }
	}
	else if(pausado)
	{
		if(_up xor _down)
		{
			opcao_pause = (opcao_pause + _down - _up + 6) mod 6;
			som_tocar(snd_menu_select_03);
		}
		if(keyboard_check_pressed(ord("R"))) { reiniciar(); exit; }
		if(keyboard_check_pressed(ord("Q"))) { voltar_menu(); exit; }
		if(_enter)
		{
			som_tocar(snd_menu_select_01);
			switch(opcao_pause)
			{
				case 0: pausado = false; break;
				case 1: ver_comandos = true; break;
				case 2: global.mostrar_teclas = !global.mostrar_teclas; jogo_salvar(); break; //LIGA/DESLIGA A TIRA DE COMANDOS
				case 3:	//TESTE DE DIFICULDADE: LIGA/DESLIGA E REINICIA NA HORA (LIGADO: LEVEL 3 E 20 MIN, TODOS OS BLOCOS)
					if(modo_versus() or MOBILE) { som_tocar(snd_menu_erro_04); break; }
					global.teste_dif = !global.teste_dif;
					reiniciar();
					exit;
				case 4: reiniciar(); exit;
				case 5: voltar_menu(); exit;
			}
		}
	}
	//R REINICIA A QUALQUER HORA
	else if(keyboard_check_pressed(ord("R"))) { reiniciar(); exit; }
}
alpha_pause = lerp(alpha_pause, pausado ? 1 : 0, .25);
#endregion

#region MENU DE PODER (COMPLETOU D R O P)
//JUNTOU TODAS AS LETRAS: ABRE O MENU PRA ESCOLHER UM PODER
//ANTES: O JOGO PARA E AS LETRAS DO PAINEL FAZEM FESTA (GLOBAL.PALAVRA_FESTA, DESENHADA NO OBJ_BORDA). DEPOIS ABRE OS PODERES
if(global.palavra_festa > 0 and !pausado)
{
	global.palavra_festa--;
	with(obj_area) if(alarm[0] > 0) alarm[0]++;
	with(obj_cria_peca) if(alarm[0] > 0) alarm[0]++;
}
if(!menu_poder and !pausado and !_player_morto and modo_arcade() and !modo_versus() and (letras_completas() or (global.coop and letras_completas(2))) and global.palavra_festa <= 0)
{
	if(!palavra_festejada)
	{
		palavra_festejada = true;
		zorg_falar("palavra");
		global.palavra_festa = PALAVRA_FESTA;
		shakes(6, 2);
		with(obj_borda) onda_choque(x + dx_hud + 212, y + 215, 70, 5, 30);
	}
	else
	{
		palavra_festejada = false;
		poder_menu_abrir();
	}
}
if(menu_poder)
{
	//ESQUERDA/DIREITA ESCOLHE O CARD, ENTER OU SOCO CONFIRMA (DEPOIS DE UMA ESPERINHA)
	var _n = array_length(poder_opcoes);
	var _esq = keyboard_check_pressed(global.imputs.left) or keyboard_check_pressed(vk_left);
	var _dir = keyboard_check_pressed(global.imputs.rigth) or keyboard_check_pressed(vk_right);
	if(_esq xor _dir)
	{
		poder_opcao = (poder_opcao + _dir - _esq + _n) mod _n;
		som_tocar(snd_menu_select_03);
	}
	if(timer_menu_poder > 0) timer_menu_poder--;
	else if(_enter or keyboard_check_pressed(global.imputs.soco)) poder_menu_escolher();
}
alpha_menu = lerp(alpha_menu, menu_poder ? 1 : 0, .25);

#region PODER DE PARAR O TEMPO (ENERGIA CHEIA + TECLA 1, SCR_PODERES)
if(TESTE_ENERGIA and global.tempo_fase == "") global.energia = ENERGIA_MAX; //TESTE: BARRA SEMPRE CHEIA
if(keyboard_check_pressed(ord("2")) and global.tempo_fase == "") global.energia = ENERGIA_MAX; //TESTE: TECLA 2 ENCHE A BARRA DO ESPECIAL
if(modo_arcade() and !modo_versus() and !pausado and !menu_poder and !_player_morto and global.palavra_festa <= 0 and global.andar_pausa <= 0 and !global.quebra_parado and keyboard_check_pressed(TEMPO_TECLA))
{
	if(global.tempo_fase == "" and global.energia >= ENERGIA_MAX) tempo_parar();
	else if(global.tempo_fase == "parado") tempo_encerrar(); //APERTOU DE NOVO: ENCERRA ANTES E POUPA A ENERGIA
	else if(global.tempo_fase == "") som_tocar(snd_menu_erro_04); //SEM A ENERGIA CHEIA
}
if(!pausado and !menu_poder and !_player_morto and global.congelar <= 0) tempo_atualizar();
#endregion

//HITSTOP: CONGELA ALGUNS FRAMES NOS IMPACTOS FORTES (SCR_GAMEFEEL)
if(global.congelar > 0) global.congelar--;

//O JOGO PARA QUANDO TA PAUSADO, QUANDO O PLAYER MORRE, NO MENU DE PODER, NO HITSTOP OU NO QUEBRA-CABEÇA
//SUBIU DE ANDAR: O JOGO PARA ENQUANTO A REGUA SOBE (A PROXIMA PEÇA ESPERA A PAUSA ACABAR)
if(global.andar_pausa > 0 and !pausado and !menu_poder)
{
	global.andar_pausa--;
	with(obj_area) if(alarm[0] > 0) alarm[0]++;
	with(obj_cria_peca) if(alarm[0] > 0) alarm[0]++;
}
global.pausa_real = pausado or _player_morto or menu_poder or global.congelar > 0 or global.quebra_parado or global.andar_pausa > 0 or global.palavra_festa > 0;
global.game_pause = global.pausa_real or tempo_ativo(); //TEMPO PARADO: TUDO PARA MENOS O PLAYER (TEMPO_PLAYER_LIVRE)
if(global.game_pause) exit;

//PAUSA CURTA ANTIGA (PAUSAR_SEG)
if(pause_timer > 0)
{
	pause_timer--;
	global.pause_timer = true;
}else global.pause_timer = false;

//TIMERS
//TEMPO DE PARTIDA (SEGUNDOS) E OS EFEITOS QUE ACABAM SOZINHOS
global.tempo_partida += 1 / room_speed;
global.ensino_t++;
//A CADA MINUTO DE PARTIDA (ATE O TEMPO PARAR DE ACELERAR AS PEÇAS) AVISA QUE FICOU MAIS RAPIDO
var _min_atual = floor(global.tempo_partida / 60);
if(_min_atual > min_aviso)
{
	min_aviso = _min_atual;
	if(modo_arcade() and !modo_versus() and _min_atual <= TEMPO_ACELERA_MAX / TEMPO_ACELERA) velocidade_aviso();
}
if(global.efeito_lento > 0)	global.efeito_lento--;
if(global.efeito_rapido > 0)	global.efeito_rapido--;
if(global.raio > 0)				global.raio--;
if(global.bonus_moedas > 0)		global.bonus_moedas--;
if(global.febre > 0)			global.febre--;
if(global.febre <= 0)			global.febre_rapida = false;

//MODO QUEBRA-CABEÇA: PODE APARECER SOZINHO (SCR_QUEBRA_CABECA)
if(modo_arcade() and !modo_versus()) qc_sortear();

//CONTAGEM DE 3S ANTES DE ACELERAR: BIPA A CADA SEGUNDO E NO FIM ACELERA
if(global.contagem > 0)
{
	global.contagem--;
	if(global.contagem > 0 and global.contagem mod room_speed == 0) som_tocar(Bip_2);
	if(global.contagem == 0)
	{
		som_tocar(snd_certo);
		if(is_callable(global.contagem_acao)) global.contagem_acao();
		global.contagem_acao = undefined;
	}
}
//TEMPO DA ONDA RAPIDA E DO BRILHO DE PEÇA ACELERADA
if(global.onda_timer > 0)		global.onda_timer--;
if(global.peca_acelerada_timer > 0) global.peca_acelerada_timer--;

//LETRAS D R O P (SO NO ARCADE): DE TEMPOS EM TEMPOS APARECE UMA QUE FALTA
if(modo_arcade() and !modo_versus())
{
	letra_timer--;
	if(letra_timer <= 0)
	{
		letra_timer = letra_intervalo();
		letra_aparecer();
	}
}

//ONDA DE PEÇAS (SO NO ARCADE): AVISO, DEPOIS VARIAS PEÇAS EM SEQUENCIA, DEPOIS ACALMA
if(modo_arcade() and !modo_versus() and instance_exists(obj_area))
{
	//ONDA EM ANDAMENTO: SOLTA UMA PEÇA A CADA ONDA_ESPACO FRAMES
	if(onda_restantes > 0)
	{
		if(onda_espera > 0) onda_espera--;
		else if(obj_area.criar_peca_onda())
		{
			onda_restantes--;
			onda_espera = ONDA_ESPACO;
			onda_falhas = 0;
			if(onda_restantes == 0) with(obj_area) alarm[0] = max(alarm[0], room_speed * 2); //ACALMA ANTES DA PROXIMA PEÇA NORMAL
		}
		else
		{
			onda_falhas++;
			if(onda_falhas > room_speed * 3) onda_restantes = 0; //SEM ESPAÇO NENHUM: DESISTE DO RESTO DA ONDA
		}
	}
	//SEM ONDA: CONTA ATE A PROXIMA
	else
	{
		onda_proxima--;
		if(onda_proxima <= 0)
		{
			onda_proxima = ONDA_INTERVALO;
			onda_restantes = irandom_range(ONDA_PECAS_MIN, ONDA_PECAS_MAX);
			onda_espera = ONDA_AVISO;
			onda_falhas = 0;
			onda_iniciar();
		}
	}
}

//PEÇAS DUPLAS (SO NO ARCADE): DE TEMPOS EM TEMPOS, POR DUPLA_DURACAO, CADA PEÇA VEM COM OUTRA LOGO ATRAS (OBJ_AREA)
if(modo_arcade() and !modo_versus())
{
	if(global.dupla_timer > 0) global.dupla_timer--;
	else if(onda_restantes == 0 and global.contagem <= 0 and !desafio_ativo() and !instance_exists(obj_onda_laser))
	{
		dupla_proxima--;
		if(dupla_proxima <= 0)
		{
			dupla_proxima = DUPLA_INTERVALO;
			global.dupla_timer = DUPLA_DURACAO;
			if(instance_exists(obj_area)) efeito_texto(global.linguagem == 0 ? "PEÇAS DUPLAS!" : "DOUBLE PIECES!", obj_area.x + obj_area.sprite_width / 2, obj_area.y + 40, #FF9A3C, 1.4);
			som_tocar(snd_menu_erro_03);
			shakes(6, 2);
		}
	}
}

//ONDA DE LASER (SO NO ARCADE): NAO VEM JUNTO COM A ONDA DE PEÇAS, A CONTAGEM OU UM DESAFIO (ESPERA ELES ACABAREM)
if(modo_arcade() and !modo_versus() and !instance_exists(obj_onda_laser))
{
	if(laser_proxima > 0) laser_proxima--;
	else if(onda_restantes == 0 and global.contagem <= 0 and global.onda_timer <= 0 and !desafio_ativo())
	{
		laser_proxima = LASER_ONDA_INTERVALO;
		instance_create_depth(0, 0, -2050, obj_onda_laser);
		zorg_falar("laser");
	}
}

//FRIO (SO NO ARCADE): "ESTA FICANDO MUITO FRIO" E OS BLOCOS VIRAM GELO POR UM TEMPO (CRIAR_PECAS, FRIO_*)
if(modo_arcade() and !modo_versus()) frio_atualizar();

//BLOCO NOVO DESCOBERTO (PRIMEIRA VEZ QUE O JOGADOR VE ESSE BLOCO, EM QUALQUER PARTIDA): AVISO NA TELA
if(modo_arcade() and !modo_versus() and (current_time div 166) mod 2 == 0) blocos_procurar_novos();

//MARCANDO OS GRUPOS QUE O ESPECIAL PODE DESTRUIR (BRILHO AZUL NOS BLOCOS)
timer_marcar++;
if(timer_marcar >= 8)
{
	timer_marcar = 0;
	especial_marcar();
}

//COMBO DE LINHAS: SE O TEMPO ACABAR, ZERA
if(global.combo_timer > 0) global.combo_timer--;
else global.combo_seq = 0;

//BLOCO PARADO MAIS ALTO DA ARENA
if(instance_exists(obj_area))
{
	var _antes = global.perigo;
	var _fundo = obj_area.y + obj_area.sprite_height;
	var _mais_alto = _fundo;
	with(obj_peca) if(estou_parado and !andar and velv == 0) _mais_alto = min(_mais_alto, y);
	
	//PERIGO: TEM BLOCO PARADO NAS 4 LINHAS DE CIMA DA ARENA
	global.perigo = _mais_alto < obj_area.y + CEL * 4;
	if(global.perigo and !_antes) { som_tocar(snd_menu_erro_03); zorg_falar("perigo"); }
	
	//ALTURA DA PILHA (0 VAZIA, 1 NO TOPO): A MUSICA ACELERA CONFORME ELA SOBE
	global.altura_pilha = (_fundo - _mais_alto) / obj_area.sprite_height;
}

#region TELEPORTE DA PEÇA ATUAL
//TECLA DE TELEPORTE: A PEÇA ATUAL CAI NA HORA ATE ONDE DER (SCR_FILA)
if(modo_versus())
{
	for(var _n = 1; _n <= 2; _n++)
	{
		if(global.vs_perdedor != 0) break;
		if(keyboard_check_pressed(imputs_jogador(_n).acelerar)) versus_teleporte(_n);
		if(keyboard_check_pressed(versus_tecla_poder(_n))) versus_poder_alternar(_n); //PODER DO FANTASMA (SCR_COOP)
	}
}
else if(keyboard_check_pressed(global.imputs.acelerar))
{
	teleporte_acionar();
	habil_aprender("teleporte"); //TIRA DE COMANDOS: DESCOBRIU O TELEPORTE
}
#endregion

//RECORDE (ATUALIZA NA HORA, SALVA QUANDO SAI DA ROOM)
recorde_checar();

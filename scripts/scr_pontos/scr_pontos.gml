//PONTUAÇAO==================================
//LINHA COMPLETA:	PONTOS_LINHA FIXO. SO APARECE O NUMERO GRANDE NO CENTRO DA TELA, QUE DEPOIS VOA PRO SCORE
//IRMANDADE:		PEÇA QUE AINDA TAVA INTEIRA NA LINHA E DESTRUIDA TODA. CADA BLOCO DELA VIRA UM QUADRADO
//					VERMELHO COM "10" E ESSE 10 VOA PRO NUMERO DO CENTRO (1000 -> 1010 -> 1020...)

#macro PONTOS_LINHA			1000	//CADA LINHA COMPLETA (VALOR FIXO)
#macro PONTOS_IRMANDADE		10		//CADA BLOCO DE UMA PEÇA INTEIRA DESTRUIDA NA LINHA
#macro PONTOS_UMA_COR		1000	//BONUS DA LINHA DE UMA COR SO
#macro PONTOS_BLOCO_PLAYER	25		//BLOCO QUEBRADO PELO GIRO
#macro PONTOS_FANTASMA		100		//BLOCO FANTASMA QUEBRADO PELO GIRO (SO O GIRO QUEBRA ELE)
#macro PONTOS_INIMIGO		300		//BLOCO INIMIGO MORTO PELO PLAYER (PISAO, GIRO OU SOCO)
#macro PONTOS_INIMIGO_PECA	150		//BLOCO INIMIGO ESMAGADO POR UMA PEÇA
#macro PONTOS_ESPECIAL		1000	//BLOCO ESPECIAL (ARCO-IRIS) QUANDO SORTEIA PONTOS

//BLOCO DE PEDRA (SOLIDO): AGUENTA UM GOLPE DO PLAYER (RACHA) E QUEBRA NO SEGUNDO
#macro PEDRA_CHANCE			4					//CHANCE (0-100) DE CADA BLOCO NOVO VIRAR PEDRA (SORTEIO PROPRIO)
#macro PEDRA_IMUNE			15					//FRAMES DEPOIS DE RACHAR ATE PODER LEVAR O SEGUNDO GOLPE (O MESMO GIRO NAO TIRA AS DUAS)

//O PLAYER BATEU NO BLOCO (GIRO, QUIQUE, CABEÇADA): QUEBRA. O BLOCO DE PEDRA SO RACHA NO PRIMEIRO GOLPE
//E PRECISA DE OUTRO PRA QUEBRAR. RETORNA TRUE SE QUEBROU
function bloco_golpe(_peca)
{
	if(!instance_exists(_peca)) return false;
	if(_peca.sou_pedra)
	{
		if(_peca.pedra_imune > 0) return false;
		if(_peca.vida_pedra > 1)
		{
			_peca.vida_pedra--;
			_peca.pedra_imune = PEDRA_IMUNE;
			_peca.esc = 1.2;
			_peca.alpha_fog = 1;
			efeito_morte_linha(_peca.x, _peca.y, 6); //LASQUINHAS CINZA
			audio_play_sound(snd_hit, 1, false, 1, 0, .6);
			shakes(3, 1);
			return false;
		}
	}
	_peca.destruido_por = "player";
	instance_destroy(_peca);
	return true;
}

//BLOCO RAIO E MODO BONUS
#macro RAIO_CHANCE			2.5					//CHANCE (0-100) DE CADA BLOCO NOVO VIRAR O BLOCO RAIO (SORTEIO PROPRIO)
#macro RAIO_TEMPO			(room_speed * 8)	//QUANTO TEMPO TUDO FICA AQUA COM OS PONTOS DOBRADOS
#macro RAIO_PONTOS			2					//MULTIPLICADOR DE PONTOS DO RAIO (SOMA COM A FEBRE: OS DOIS = X4)
#macro BONUS_TEMPO			(room_speed * 10)	//QUANTO TEMPO DURA O MODO BONUS (TODO BLOCO SOLTA MOEDA)
#macro BONUS_CHANCE			35					//CHANCE (0-100) DO BONUS ENTRAR NO SORTEIO DO BLOCO ESPECIAL (MAIS RARO QUE OS OUTROS PREMIOS)

//BLOCO FUJAO (TEM MOEDA DENTRO E FOGE DO PLAYER)
#macro FUJAO_CHANCE			3					//CHANCE (0-100) DE CADA BLOCO NOVO VIRAR FUJAO (SORTEIO PROPRIO)
#macro FUJAO_PERTO			44					//PLAYER MAIS PERTO QUE ISSO (PX): ELE ACORDA E FOGE
#macro FUJAO_LONGE			96					//PLAYER MAIS LONGE QUE ISSO: VOLTA A SER UM BLOCO NORMAL
#macro FUJAO_PASSO			8					//FRAMES PARADO EM CADA CASA ANTES DE IR PRA PROXIMA
#macro FUJAO_VEL			2					//PX POR FRAME DESLIZANDO DE UMA CASA PRA OUTRA
#macro FUJAO_MOEDAS			3					//MOEDAS QUE ELE SOLTA QUANDO E DESTRUIDO

//LIBERAÇAO DOS BLOCOS PELO TEMPO DE PARTIDA (EM MINUTOS). NO PRIMEIRO MINUTO SO TEM O BLOCO NORMAL (E AS LETRAS):
//NADA DE ARMADILHA, SO COISA BOA PRO JOGADOR. DEPOIS CADA BLOCO VAI SENDO LIBERADO AOS POUCOS
#macro LIBERA_RAIO			1
#macro LIBERA_ESPECIAL		2
#macro LIBERA_RAIVOSO		2
#macro LIBERA_PEDRA			2.5
#macro LIBERA_GELO			(TESTE_BLOCOS ? 0 : 2.5)	//(NO TESTE_BLOCOS OS BLOCOS NOVOS JA VEM DESDE O COMEÇO)
#macro LASER_LADO_CHANCE	40	//CHANCE (0-100) DE UM BLOCO LASER SER O LASER LATERAL
#macro LIBERA_FUJAO			6	//(HORARIOS DO USUARIO EM 2026-10-02: LASER, SNIPER E BOMBA VIERAM PRO 6)
#macro LIBERA_COLMEIA		(TESTE_BLOCOS ? 0 : 6)
#macro LIBERA_FANTASMA		8.5
#macro LIBERA_INIMIGO		8.5
#macro LIBERA_LASER			6	//(O LASER LATERAL VEM JUNTO: E UMA VARIANTE DELE)
#macro LIBERA_SNIPER		6
#macro LIBERA_BOMBA			6
#macro LIBERA_LENTO			(TESTE_BLOCOS ? 0 : 14)
#macro LIBERA_GELATINA		(TESTE_BLOCOS ? 0 : 18)
#macro LIBERA_BURACO		(TESTE_BLOCOS ? 0 : 20)
#macro LIBERA_CABECUDO		(TESTE_BLOCOS ? 0 : 8.5)	//JUNTO COM O INIMIGO (E UMA VARIAÇAO DELE)

//ESSE BLOCO JA PODE APARECER? (_MINUTOS = O LIBERA_ DELE). FORA DO ARCADE (VERSUS) FICA TUDO COMO ANTES
function bloco_liberado(_minutos)
{
	if(!modo_arcade()) return true;
	return global.tempo_partida >= _minutos * 60;
}

//GELO: A PEÇA INTEIRA (OS 4 BLOCOS) VEM DE GELO. EM CIMA DELE O PLAYER ESCORREGA
#macro GELO_CHANCE			(TESTE_BLOCOS ? 20 : 10)		//CHANCE (0-100) DA PROXIMA PEÇA VIR DE GELO (A PRIMEIRA E A DO TESTE_BLOCOS)
#macro GELO_ATRITO			.04		//EM CIMA DO GELO O PLAYER ACELERA E FREIA BEM DEVAGAR (NO CHAO NORMAL E DE .1 A .7)
#macro GELO_PAREDE_VEL		2		//AGARRADO NUMA PAREDE DE GELO ELE ESCORREGA PRA BAIXO NESSA VELOCIDADE (NA PAREDE NORMAL .3)
#macro GELO_PAREDE_PULO		1.5		//WALL JUMP NA PAREDE DE GELO: SO UM PULINHO PRO LADO (NAO DA PRA ESCALAR)

//COLMEIA: PARADA, SOLTA UMA ABELHA DE TEMPOS EM TEMPOS (OBJ_ABELHA). A ABELHA VAI NO BLOCO MAIS PERTO E SE DESTROI COM ELE
#macro COLMEIA_CHANCE		(TESTE_BLOCOS ? 5 : 2)		//CHANCE (0-100) DE CADA BLOCO NOVO VIRAR COLMEIA (NO MAXIMO UMA NA ARENA)
#macro COLMEIA_PRIMEIRA		(room_speed * 2)	//DEPOIS DE CAIR E ASSENTAR, TEMPO ATE AS PRIMEIRAS ABELHAS
#macro COLMEIA_TEMPO		(room_speed * 3)	//DEPOIS, ABELHAS DE NOVO A CADA... (ERA 5S)
#macro ABELHA_POR_VEZ		2		//ABELHAS QUE SAEM DE CADA VEZ
#macro ABELHA_MAX			4		//ABELHAS DE UMA COLMEIA VOANDO AO MESMO TEMPO
#macro ABELHA_VEL			.855	//VELOCIDADE DA ABELHA (PX POR FRAME. ERA .9, FICOU 5% MAIS DEVAGAR)

//LENTO: SE O PLAYER QUEBRAR ELE, NADA ACONTECE. SE ELE FOR DESTRUIDO DE OUTRO JEITO (LINHA, LASER, BOMBA...),
//JOGA UM FEITIÇO NO PLAYER E TODOS OS MOVIMENTOS DELE FICAM LENTOS (O JOGADOR TEM QUE QUEBRAR ELE ANTES)
#macro LENTO_CHANCE			(TESTE_BLOCOS ? 5 : 2.5)	//CHANCE (0-100) DE CADA BLOCO NOVO VIRAR LENTO (NO MAXIMO UM NA ARENA)
#macro LENTO_TEMPO			(room_speed * 5)	//QUANTO TEMPO O PLAYER FICA LENTO
#macro LENTO_MULT			.55		//O PLAYER SE MOVE NESSA FRAÇAO DA VELOCIDADE (O PULO CONTINUA DA MESMA ALTURA, SO MAIS DEVAGAR)
#macro RAPIDO_TEMPO			(room_speed * 5)	//O PLAYER QUEBROU O BLOCO LENTO: FICA RAPIDO POR ESSE TEMPO
#macro RAPIDO_MULT			1.35	//E SE MOVE ESSE TANTO MAIS RAPIDO (O PULO CONTINUA DA MESMA ALTURA)

//GELATINA: BLOCO SOZINHO. PRO PLAYER E UM TRAMPOLIM (PISOU, E JOGADO PRA CIMA) E, SE ELE ENCOSTAR NA LATERAL, E JOGADO
//UM POUCO PRO LADO. O BLOCO QUE CAI EM CIMA DELA SAI DA PEÇA E FICA QUICANDO ATE TER OUTRO BLOCO EM CIMA DELE
#macro GELATINA_CHANCE		(TESTE_BLOCOS ? 12 : 5)		//CHANCE (0-100) DA PROXIMA PEÇA SER UM BLOCO DE GELATINA
#macro GELATINA_MAX			2		//GELATINAS NA ARENA AO MESMO TEMPO
#macro GEL_IMPULSO			2.4		//VELOCIDADE PRA CIMA DO BLOCO QUICANDO (SOBE UM POUCO MAIS QUE 1 BLOCO. ERA 3.1, 2 BLOCOS)
#macro GEL_GRAVIDADE		.15		//GRAVIDADE DO BLOCO QUICANDO (ELE SOBE E CAI COMO UMA BOLA, SEM PARAR NAS CASAS)
#macro GEL_PESO				2		//BLOCO A ATE ESSAS CASAS ACIMA DO QUE TA QUICANDO SEGURA ELE (PARA DE QUICAR E ASSENTA)
#macro GEL_TRAMPOLIM		1.05	//PLAYER PISANDO NA GELATINA: PULO DESSE TANTO X O PULO NORMAL... (ERA 1.25)
#macro GEL_TRAMPOLIM_FORTE	1.25	//...E DESSE TANTO SEGURANDO O PULO (ERA 1.5)
#macro GEL_EMPURRAO			1.45	//PLAYER ENCOSTOU NA LATERAL: VELOCIDADE PRO LADO (COM 1 IA 9PX PRA TRAS; 1.45 VAI ~13PX, 4PX A MAIS)

//BURACO: BLOCO SOZINHO. O BLOCO QUE CAI EM CIMA DELE E ENGOLIDO (SAI DA PEÇA) E VOLTA PELO TOPO DA ARENA, EM CIMA
//DO PLAYER, PEGANDO FOGO (OBJ_BLOCO_FOGO): CAI DIRETO QUEBRANDO TUDO ATE O CHAO E DA DANO NO PLAYER
#macro BURACO_CHANCE		(TESTE_BLOCOS ? 10 : 4)		//CHANCE (0-100) DA PROXIMA PEÇA SER UM BURACO
#macro BURACO_MAX			1		//BURACOS NA ARENA AO MESMO TEMPO
#macro BURACO_ESPERA		(room_speed * 3)	//DEPOIS DE ENGOLIR, O BURACO RECARREGA ESSE TEMPO ATE PODER ENGOLIR O PROXIMO
#macro FOGO_ENGOLIR			(room_speed * .4)	//TEMPO DO BLOCO SENDO ENGOLIDO (GIRA E ENCOLHE PRA DENTRO DO REDEMOINHO)
#macro FOGO_PORTAL			(room_speed * .3)	//TEMPO DO PORTAL ABRINDO NO TOPO DA ARENA (O BLOCO SAI DE DENTRO DELE)
#macro FOGO_AVISO			(room_speed * .7)	//O BLOCO EM CHAMAS FICA ESSE TEMPO NO TOPO MOSTRANDO ONDE VAI CAIR
#macro FOGO_VEL				1.2		//VELOCIDADE DA QUEDA DO BLOCO EM CHAMAS (A MESMA DA PEÇA RAIVOSA)

//CABEÇUDO: O INIMIGO COM CHIFRES (OBJ_INIMIGO COM { CABECUDO : TRUE }). CAI E ANDA IGUAL AO INIMIGO, MAS NAO DA MEIA-VOLTA:
//NO BLOCO DA FRENTE DA UMA CABEÇADA E EMPURRA ELE UMA CASA (SE NAO DER, O BLOCO QUEBRA) E SEGUE. NA PAREDE DA CABEÇADAS
//COM UM INTERVALO E NA CABECUDO_BATIDAS ELE MORRE. MORRE TAMBEM COMO O INIMIGO (PISAO, GIRO OU PEÇA CAINDO EM CIMA)
#macro CABECUDO_CHANCE		(TESTE_BLOCOS ? 12 : 5)	//CHANCE (0-100) DA PROXIMA PEÇA SER UM CABEÇUDO
#macro CABECUDO_MAX			2		//CABEÇUDOS NA ARENA AO MESMO TEMPO
#macro CABECUDO_VEL			.3		//PX POR FRAME ANDANDO (O INIMIGO ANDA A .45)
#macro CABECUDO_PASSO		(room_speed * .5)	//PARADO DEPOIS DE UMA CABEÇADA NUM BLOCO (OU NO PLAYER)
#macro CABECUDO_BATIDA		(room_speed * .9)	//NA PAREDE: TEMPO ENTRE UMA CABEÇADA E OUTRA
#macro CABECUDO_JOGA_H		3		//PLAYER PRENSADO NA PAREDE PELO CABEÇUDO: VELOCIDADE PRO OUTRO LADO
#macro CABECUDO_JOGA_V		3.6		//E O PULO (PASSA POR CIMA DO CABEÇUDO)
#macro CABECUDO_BATIDAS		3		//NA 3A CABEÇADA NA PAREDE ELE MORRE

//QUANTOS CABEÇUDOS VIVOS TEM NA ARENA
function cabecudos_contar()
{
	var _n = 0;
	with(obj_inimigo) if(cabecudo and vivo()) _n++;
	return _n;
}

//QUANTOS BLOCOS DESSE TIPO TEM NA ARENA (_VAR = NOME DA VARIAVEL, EX: "sou_buraco")
function blocos_contar(_var)
{
	var _n = 0;
	with(obj_peca) if(variable_instance_get(id, _var)) _n++;
	return _n;
}

//BLOCO LENTO DESTRUIDO: O FEITIÇO PEGA NO PLAYER (NO COOP, NOS DOIS)
function lento_lancar(_x, _y)
{
	som_tocar(snd_feitico);
	with(obj_player)
	{
		if(estado == state.morte) continue;
		lento = LENTO_TEMPO;
		alpha_fog = 1;
		efeito_texto(global.linguagem == 0 ? "LENTO!" : "SLOW!", x, bbox_top - 14, #B07CFF, 1.3); //O AVISO SAI EM CIMA DO PLAYER
		var _anel = instance_create_depth(x, y - 10, depth - 1, obj_efeito_pontos);
		_anel.modo = "anel";
		_anel.timer = 14;
	}
}

//O PLAYER QUEBROU O BLOCO LENTO: O FEITIÇO VIRA A FAVOR DELE E ELE FICA RAPIDO (SO QUEM QUEBROU, O MAIS PERTO NO COOP)
function rapido_lancar(_x, _y)
{
	var _p = player_perto(_x, _y);
	if(_p == noone) exit;
	som_tocar(snd_feitico);
	with(_p)
	{
		lento = 0;
		rapido = RAPIDO_TEMPO;
		alpha_fog = 1;
		efeito_texto(global.linguagem == 0 ? "RÁPIDO!" : "FAST!", x, bbox_top - 14, #FFE600, 1.3);
		var _anel = instance_create_depth(x, y - 10, depth - 1, obj_efeito_pontos);
		_anel.modo = "anel";
		_anel.timer = 14;
	}
}

//MULTIPLICADOR DE PONTOS PELO ANDAR (ANDAR 2 = 1.5X, ANDAR 3 = 3X)
function pontos_mult_andar()
{
	switch(global.andar)
	{
		case 2: return 1.5;
		case 3: return 3;
	}
	return 1;
}
//SOMA OS PONTOS NO JOGADOR CERTO E MOSTRA O NUMERO AMARELO VOANDO ATE O SCORE DO HUD
//O PONTO REAL E SOMADO NA HORA (NAO SE PERDE SE A PARTIDA ACABAR NO MEIO DO VOO),
//MAS O NUMERO DO HUD SO SOBE QUANDO O TEXTO CHEGA LA (GLOBAL.PONTOS_PENDENTES)
function pontos_somar(_pontos, _x, _y, _cor = c_yellow, _esc = 1)
{
	//NA FEBRE OS PONTOS DOBRAM
	_pontos = round(_pontos * febre_mult());
	if(_pontos <= 0) exit;
	
	//CADA MODO GUARDA OS PONTOS NUM LUGAR
	if(room == rm_versus and _x > room_width/2)		global.pontos_2		+= _pontos;
	else												global.pontos_1		+= _pontos;
	
	//NO ARCADE O NUMERO VOA ATE O SCORE DO HUD
	var _e = efeito_texto("+" + string(_pontos), _x, _y, c_yellow, _esc);
	if(modo_arcade() and instance_exists(obj_borda))
	{
		_e.modo = "voar";
		_e.valor = _pontos;
		global.pontos_pendentes += _pontos;
	}
}

//TIRA PONTOS (BLOCO QUEBRADO PELOS ESPINHOS DO QUEBRA-CABEÇA): NUMERO VERMELHO. O PLACAR NAO FICA NEGATIVO
function pontos_tirar(_pontos, _x, _y)
{
	_pontos = min(round(_pontos), global.pontos_1);
	if(_pontos <= 0) exit;
	global.pontos_1 -= _pontos;
	efeito_texto("-" + string(_pontos), _x, _y, c_red, .8);
}

//NUMERO DA LINHA NO CENTRO DA TELA==================================
//CADA FECHAMENTO DE LINHA TEM O SEU NUMERO. SO APARECE UM POR VEZ: SE OUTRA LINHA FECHA,
//O NUMERO ANTERIOR VAI DIRETO PRO SCORE E O NOVO APARECE NO CENTRO.
function coletor_obter()
{
	var _atual = global.coletor;
	if(instance_exists(_atual) and _atual.modo == "coletor" and _atual.fase == "recebendo" and _atual.evento == global.evento_linha) return _atual;
	
	//NUMERO ANTERIOR: MANDA O QUE JA CHEGOU PRO SCORE AGORA (OS 10 QUE AINDA TAO VOANDO VAO DIRETO PRO SCORE)
	with(obj_efeito_pontos)
	{
		if(modo == "coletor")
		{
			if(global.coletor == id) global.coletor = noone;
			modo = "voar";
			valor = total_real - real_pendente;
			mensagem = "+" + string(valor);
			cor = c_yellow;
			timer_voo = 18;
			vel_voo = 2;
			dir_voo = 90;
			esc = 1.8;
			esc_final = 1.2;
			if(valor <= 0) instance_destroy();
		}
	}
	
	//NUMERO NOVO NO CENTRO DA TELA
	var _c = instance_create_depth(room_width/2, room_height/2 - 40, -2100, obj_efeito_pontos);
	_c.modo = "coletor";
	_c.fase = "recebendo";
	_c.evento = global.evento_linha;
	_c.esc = 1.9;		//APARECE GRANDE E ENCOLHE RAPIDO ("BATE" NA TELA)
	_c.esc_final = 1;
	global.coletor = _c;
	return _c;
}

//SOMA NO PLACAR REAL NA HORA E GUARDA PRO NUMERO DO CENTRO
function coletor_somar(_c, _pontos)
{
	global.pontos_1 += _pontos;
	global.pontos_pendentes += _pontos;
	_c.total_real += _pontos;
}

//LINHA COMPLETA: O NUMERO DO CENTRO GANHA OS PONTOS DA LINHA NA HORA
//(RETORNA O NUMERO PRA IRMANDADE DESSA LINHA SOMAR NO MESMO)
function coletor_linha()
{
	var _c = coletor_obter();
	var _novo = _c.total_real == 0;
	var _pontos = PONTOS_LINHA * febre_mult();
	coletor_somar(_c, _pontos);
	if(_novo) _c.total_mostrado = _pontos; //JA APARECE COM O VALOR DA LINHA (SEM CONTAR DO ZERO)
	_c.esc_pop = 1.5;
	_c.timer_espera = 0;
	return _c;
}

//LINHA DE UMA COR SO: BONUS NO MESMO NUMERO
function coletor_uma_cor(_c = noone)
{
	if(!instance_exists(_c)) _c = coletor_obter();
	coletor_somar(_c, PONTOS_UMA_COR * febre_mult());
	_c.esc_pop = 1.5;
	_c.timer_espera = 0;
}

//BLOCO DA IRMANDADE: VIRA UM QUADRADO VERMELHO COM "10" NO LUGAR DO BLOCO E O 10 VOA PRO NUMERO DO CENTRO
//_ESPERA = FRAMES A MAIS QUE O QUADRADO FICA NA TELA ANTES DO 10 SAIR VOANDO (UM DE CADA VEZ)
//_RESERVADO = O BLOCO JA TINHA RESERVADO LUGAR NO NUMERO (BLOCOS DE FORA DA LINHA, QUE QUEBRAM DEPOIS)
function pontos_irmandade(_x, _y, _espera = 0, _c = noone, _reservado = false)
{
	if(!modo_arcade() or !instance_exists(obj_borda))
	{
		pontos_somar(PONTOS_IRMANDADE, _x, _y);
		exit;
	}
	if(!instance_exists(_c) or _c.modo != "coletor" or _c.fase != "recebendo")
	{
		_c = coletor_obter();
		_reservado = false;
	}
	var _pontos = PONTOS_IRMANDADE * febre_mult();
	coletor_somar(_c, _pontos);
	_c.real_pendente += _pontos;
	if(!_reservado) _c.esperando++;
	
	var _e = instance_create_depth(_x, _y, -2000, obj_efeito_pontos);
	_e.modo = "coletar";
	_e.alvo = _c;
	_e.valor = _pontos;
	_e.mensagem = string(_pontos);
	_e.cor = c_yellow;
	_e.esc = 1;
	_e.esc_final = 1;
	_e.atraso = _espera;
}

//TEXTO FLUTUANTE (PONTOS, LEVEL UP, EFEITOS DO BLOCO ESPECIAL...)
function efeito_texto(_texto, _x, _y, _cor = c_white, _esc = 1)
{
	var _e = instance_create_depth(_x, _y, -2000, obj_efeito_pontos);
	_e.mensagem = _texto;
	_e.cor = _cor;
	_e.esc_final = _esc;
	return _e;
}

//BLOCO ESPECIAL: SORTEIA O QUE ACONTECE (0 PONTOS, 1 DEVAGAR, 2 VIDA, 3 RAPIDO, 4 QUEBRA-CABEÇA, 5 BONUS DE MOEDAS)
//A VIDA SO ENTRA NO SORTEIO SE O PLAYER NAO TIVER COM A VIDA CHEIA
function especial_sortear()
{
	//PONTOS, DEVAGAR E RAPIDO SEMPRE PODEM SAIR
	var _opcoes = [0, 1, 3];
	if(alguem_sem_vida_cheia()) array_push(_opcoes, 2);
	if(modo_arcade() and desafio_liberado()) array_push(_opcoes, 4); //O CUBO SO DEPOIS DE 3 MINUTOS (IGUAL AOS DESAFIOS)
	if(modo_arcade() and random(100) < BONUS_CHANCE) array_push(_opcoes, 5);
	return _opcoes[irandom(array_length(_opcoes) - 1)];
}

//BLOCO ESPECIAL DESTRUIDO: SORTEIA ALGO BOM OU RUIM
//_PREMIO = O QUE O BLOCO JA TINHA SORTEADO (A VISAO ESPIRITUAL MOSTRA). VIDA COM A VIDA CHEIA SORTEIA DE NOVO
function especial_ativar(_x, _y, _premio = -1)
{
	som_tocar(snd_certo);
	if(_premio == 2 and !alguem_sem_vida_cheia()) _premio = -1;
	if(_premio == 4 and (!desafio_pode() or !desafio_liberado())) _premio = -1; //JA TEM UM DESAFIO RODANDO
	if(_premio < 0) _premio = especial_sortear();
	if(_premio == 4 and !desafio_pode()) _premio = 3;
	switch(_premio)
	{
		case 0: //BOM: PONTOS
			pontos_somar(PONTOS_ESPECIAL * global.level, _x, _y, c_aqua, 1.4);
			break;
		case 1: //BOM: PEÇAS DEVAGAR
			global.efeito_lento = room_speed * 8;
			global.efeito_rapido = 0;
			efeito_texto(global.linguagem == 0 ? "DEVAGAR!" : "SLOW!", _x, _y, c_aqua, 1.2);
			som_tocar(snd_lentidao); //SOM QUE TAVA SEM USO NO PROJETO
			break;
		case 2: //BOM: VIDA
			with(obj_player) vida_atual = min(vida_atual + 1, vida_total);
			efeito_texto(global.linguagem == 0 ? "+1 VIDA" : "+1 LIFE", _x, _y, c_lime, 1.2);
			break;
		case 3: //RUIM: PEÇAS RAPIDAS
			global.efeito_rapido = room_speed * 6;
			global.efeito_lento = 0;
			efeito_texto(global.linguagem == 0 ? "RAPIDO!" : "FAST!", _x, _y, c_red, 1.2);
			som_tocar(snd_menu_erro_04);
			break;
		case 4: //RUIM: QUEBRA-CABEÇA (O AVISO DELE JA APARECE NA TELA)
			qc_iniciar();
			break;
		case 5: //BOM: MODO BONUS (TODOS OS BLOCOS FICAM COM MOEDA)
			bonus_ativar(_x, _y);
			break;
	}
}

//QUANTO O TIMER DAS PEÇAS DIMINUI POR FRAME (MUDA COM OS EFEITOS DO BLOCO ESPECIAL)
function peca_velocidade_tempo()
{
	if(global.efeito_lento > 0) return .5;
	if(global.efeito_rapido > 0 or global.onda_timer > 0) return 2;
	if(global.febre > 0 and global.febre_rapida) return FEBRE_QUEDA; //SO DEPOIS DA CONTAGEM
	return 1;
}

//DIFICULDADE==================================
//A PRESSAO SOBE AOS POUCOS:
//	LEVEL:	PEÇAS CAEM E NASCEM MAIS RAPIDO (COMO ANTES)
//	2O ANDAR: O COMEÇO (ANDAR 1 E 2) E TRANQUILO. DEPOIS QUE O JOGADOR COMPLETA O 2O ANDAR PELA PRIMEIRA VEZ,
//			AS PEÇAS FICAM MAIS RAPIDAS PELO RESTO DA PARTIDA (O LEVEL E O TEMPO CONTINUAM SOMANDO POR CIMA)
//	TEMPO:	CADA MINUTO DE PARTIDA AS PEÇAS NASCEM UM POUCO MAIS RAPIDO
//	PERIGO:	CHANCE DE BLOCO LASER E RAIVOSO SOBE A CADA LEVEL
#macro DEPOIS_ANDAR2_ACELERA	.2		//DEPOIS DE COMPLETAR O 2O ANDAR: PEÇAS 20% MAIS RAPIDAS (QUEDA E NASCIMENTO)
#macro TEMPO_ACELERA		.05		//CADA MINUTO DE PARTIDA: PEÇAS NASCEM 5% MAIS RAPIDO...
#macro TEMPO_ACELERA_MAX	.25		//...ATE NO MAXIMO 25%
#macro PERIGO_CHANCE_INICIO	5		//CHANCE DE LASER E DE RAIVOSO NO LEVEL 1 (ANTES ERA 10 E 8 FIXO)
#macro PERIGO_CHANCE_LEVEL	2		//+ ISSO A CADA LEVEL...
#macro PERIGO_CHANCE_MAX	15		//...ATE ESSE MAXIMO
#macro FANTASMA_CHANCE		15		//CHANCE (0-100) DA PEÇA VIR COM BLOCOS FANTASMA (1, 2 GRUDADOS OU ELA INTEIRA)
#macro INIMIGO_CHANCE_INICIO	4	//CHANCE DA PROXIMA PEÇA SER UM BLOCO INIMIGO NO COMEÇO...
#macro INIMIGO_CHANCE_ANDAR2	8	//...DEPOIS DE COMPLETAR O 2O ANDAR...
#macro INIMIGO_CHANCE_LEVEL		1	//...+ ISSO A CADA LEVEL...
#macro INIMIGO_CHANCE_MAX		14	//...ATE ESSE MAXIMO
#macro INIMIGO_MAX				3	//NUNCA TEM MAIS QUE ISSO DE INIMIGOS NA ARENA
#macro BOMBA_CHANCE				35	//CHANCE (0-100) DO INIMIGO SORTEADO SER UMA BOMBA
#macro SNIPER_EXTRA				10	//O BLOCO SNIPER (SOU_SENSOR) TEM ESSA CHANCE A MAIS QUE O LASER/RAIVOSA
#macro LASER_MAX					2	//BLOCOS LASER NA ARENA AO MESMO TEMPO (MAIS QUE ISSO FICA ROUBADO)

//FATOR DO TEMPO DAS PEÇAS PELO 2O ANDAR (1 = NORMAL, MENOR = MAIS RAPIDO)
function dificuldade_fator_andar()
{
	return global.passou_andar2 ? 1 - DEPOIS_ANDAR2_ACELERA : 1;
}

//FATOR DO TEMPO DAS PEÇAS PELO TEMPO DE PARTIDA (PERDE 5% A CADA MINUTO, ATE 25%)
function dificuldade_fator_tempo()
{
	return 1 - min(TEMPO_ACELERA_MAX, TEMPO_ACELERA * floor(global.tempo_partida / 60));
}

//CHANCE (0-100) DA PEÇA TER BLOCOS FANTASMA
function chance_fantasma()
{
	return FANTASMA_CHANCE;
}

//CHANCE (0-100) DA PROXIMA PEÇA SER UM BLOCO INIMIGO
function chance_inimigo()
{
	var _base = global.passou_andar2 ? INIMIGO_CHANCE_ANDAR2 : INIMIGO_CHANCE_INICIO;
	return min(INIMIGO_CHANCE_MAX, _base + INIMIGO_CHANCE_LEVEL * (global.level - 1));
}

//CHANCE (0-100) DE UM BLOCO VIRAR LASER OU DE UMA PEÇA VIRAR RAIVOSA (USADO NO ESCOLHENDO_TIPO_DO_BLOCO)
function chance_perigo()
{
	return min(PERIGO_CHANCE_MAX, PERIGO_CHANCE_INICIO + PERIGO_CHANCE_LEVEL * (global.level - 1));
}

//TEMPO QUE A PEÇA ESPERA ANTES DE DESCER UMA CASA (FICA MAIS RAPIDO A CADA LEVEL E DEPOIS DO 2O ANDAR)
function peca_tempo_queda()
{
	var _base = max(.25, .7 - .06 * (global.nivel_vel - 1)); //NIVEL_VEL = LEVEL DEPOIS DA CONTAGEM DE 3S
	return room_speed * max(.25, _base * dificuldade_fator_andar());
}

//TEMPO ENTRE UMA PEÇA NOVA E OUTRA (FICA MAIS RAPIDO A CADA LEVEL, DEPOIS DO 2O ANDAR E COM O TEMPO DE PARTIDA)
function peca_tempo_criar()
{
	var _base = max(.9, 2 - .15 * (global.nivel_vel - 1));
	return room_speed * max(.8, _base * dificuldade_fator_andar() * dificuldade_fator_tempo());
}

//ENERGIA E ESPECIAL==================================
//A ENERGIA ENCHE FECHANDO LINHAS E SUBINDO DE ANDAR/LEVEL. CADA 1 INTEIRO E UMA CARGA.
//ESPECIAL (BAIXO + SOCO EM CIMA DE UM BLOCO): GASTA 1 CARGA E DESTROI, EM ONDA, TODOS OS BLOCOS
//DA MESMA COR CONECTADOS AO BLOCO (PRECISA DE PELO MENOS ESPECIAL_MIN). DA PONTOS E MOEDAS.

#macro ENERGIA_MAX			3
#macro ENERGIA_LINHA		.25		//CADA LINHA FECHADA
#macro ENERGIA_UMA_COR		1		//LINHA DE UMA COR SO
#macro ENERGIA_ANDAR		.5		//SUBIU DE ANDAR
#macro ENERGIA_LEVEL		1		//SUBIU DE LEVEL
#macro ESPECIAL_MIN			5		//BLOCOS DA MESMA COR CONECTADOS PRA USAR O ESPECIAL
#macro PONTOS_BLOCO_ESPECIAL 100
#macro MOEDAS_POR_BLOCO		1
#macro MOEDAS_INIMIGO		2

//SOMA ENERGIA (ATE O MAXIMO). QUANDO COMPLETA UMA CARGA AVISA NA TELA
function energia_ganhar(_qtd)
{
	var _antes = floor(global.energia);
	global.energia = min(ENERGIA_MAX, global.energia + _qtd);
	
	//COMPLETOU UMA CARGA
	if(floor(global.energia) > _antes and instance_exists(obj_area))
	{
		som_tocar(snd_certo);
		efeito_texto(texto("energia_cheia"), obj_area.x - 10, obj_area.y + obj_area.sprite_height - global.energia / ENERGIA_MAX * obj_area.sprite_height, c_aqua, 1);
	}
}

//TODOS OS BLOCOS PARADOS DA MESMA COR CONECTADOS (CIMA, BAIXO, ESQUERDA, DIREITA)
//RETORNA [BLOCOS, DISTANCIA DE CADA UM ATE O BLOCO INICIAL] (A DISTANCIA FAZ O EFEITO DE ONDA)
function especial_grupo(_inicio)
{
	//BUSCA EM LARGURA: COMEÇA NO BLOCO E VAI OLHANDO OS VIZINHOS DE CADA BLOCO DA LISTA
	var _cor = _inicio.coloracao;
	var _grupo = [_inicio];
	var _dist = [0];
	var _visitado = ds_map_create();
	ds_map_add(_visitado, _inicio, true);
	
	var _dx = [CEL, -CEL, 0, 0];
	var _dy = [0, 0, CEL, -CEL];
	
	for(var i = 0; i < array_length(_grupo); i++)
	{
		var _b = _grupo[i];
		for(var d = 0; d < 4; d++)
		{
			var _v = collision_point(_b.x + _dx[d], _b.y + _dy[d], obj_peca, false, true);
			if(_v == noone or ds_map_exists(_visitado, _v)) continue;
			ds_map_add(_visitado, _v, true);
			
			if(_v.coloracao == _cor and _v.estou_parado and !_v.andar and _v.destruido_por == noone and !_v.sou_fantasma)
			{
				array_push(_grupo, _v);
				array_push(_dist, _dist[i] + 1);
			}
		}
	}
	ds_map_destroy(_visitado);
	return [_grupo, _dist];
}

//ESPECIAL (BAIXO + SOCO): PRECISA DE 1 CARGA DE ENERGIA E DE UM GRUPO DE PELO MENOS ESPECIAL_MIN BLOCOS
function especial_usar(_bloco)
{
	if(!instance_exists(_bloco)) exit;
	
	if(global.energia < 1)
	{
		som_tocar(snd_menu_erro_01);
		efeito_texto(texto("sem_energia"), x, y - 30, c_red, .9);
		exit;
	}
	
	if(_bloco.sou_fantasma or _bloco.coloracao < 0) exit; //O FANTASMA SO QUEBRA NO GIRO. BLOCO SEM COR NAO TEM GRUPO
	var _res = especial_grupo(_bloco);
	var _grupo = _res[0];
	var _dist = _res[1];
	if(array_length(_grupo) < ESPECIAL_MIN)
	{
		som_tocar(snd_menu_erro_01);
		efeito_texto(texto("poucos_blocos"), x, y - 30, c_red, .9);
		exit;
	}
	
	//GASTA A CARGA E FAZ O IMPACTO: ONDA DE CHOQUE, HITSTOP, SOM, TREMIDA E O NOME DO ESPECIAL
	global.energia -= 1;
	global.especial_cadeia = 0;
	global.especial_restantes = array_length(_grupo);
	emocao_mostrar(4, room_speed * 1.5); //RETRATO DO HUD FICA AZUL (PODER)
	onda_choque(_bloco.x, _bloco.y, 140, 8, 36);
	hitstop(5);
	som_tocar(snd_destroi_parede);
	shakes(12, 3);
	efeito_texto(texto("especial_nome"), x, y - 34, c_aqua, 1.4);
	
	//CADA BLOCO MORRE UM POUCO DEPOIS DO ANTERIOR (ONDA SAINDO DO BLOCO QUE O PLAYER SOCOU)
	for(var i = 0; i < array_length(_grupo); i++)
	{
		with(_grupo[i])
		{
			destruido_por = "especial";
			alpha_fog = 1;
			esc = 1.3;
			alarm[3] = 1 + _dist[i] * 4; //O ALARM 3 DA PEÇA SO DA INSTANCE_DESTROY()
		}
	}
}

//SOLTA MOEDAS: ELAS PULAM PRA FORA DO BLOCO E O PLAYER TEM QUE CORRER ATRAS (SOMEM DEPOIS DE 4S).
//A MOEDA SO CONTA QUANDO O PLAYER PEGA (OBJ_MOEDA)
function moeda_criar(_x, _y, _qtd = 1)
{
	repeat(_qtd) instance_create_depth(_x, _y, -2500, obj_moeda);
}

//BLOCO RAIO DESTRUIDO: CAI UM RAIO NO BLOCO (FLASH, TREMIDA, ONDA DE CHOQUE) E POR RAIO_TEMPO
//OS OBJETOS FICAM AZUL AQUA (AQUA_INICIO) E OS PONTOS DOBRAM (FEBRE_MULT)
function raio_ativar(_x, _y)
{
	global.raio = RAIO_TEMPO;
	instance_create_depth(_x, _y, -2100, obj_efeito_raio);
	onda_choque(_x, _y, 150, 8, 36);
	hitstop(6);
	shakes(14, 3);
	som_tocar(snd_trovao);
	som_tocar(zap1);
	emocao_mostrar(4, room_speed * 2); //RETRATO DO HUD COM PODER (AZUL)
	efeito_texto(global.linguagem == 0 ? "RAIO! PONTOS X2" : "LIGHTNING! X2 POINTS", _x, _y - 24, c_aqua, 1.3);
}

//BLOCO RAIO LIGADO: OS BLOCOS COLORIDOS VIRAM TODOS O BLOCO AZUL (FRAME 3 DA SPR_PECA). NOS ULTIMOS 2S PISCA
//(VOLTA A COR DE VERDADE DE VEZ EM QUANDO) AVISANDO QUE VAI ACABAR
function raio_azul()
{
	return global.raio > 0 and !(global.raio < room_speed * 2 and (global.raio div 8) mod 2 == 0);
}

//BLOCO RAIO LIGADO: O QUE FOR DESENHADO ENTRE O AQUA_INICIO E O AQUA_FIM SAI AZUL AQUA (SHADER SH_AQUA).
//USADO NO PLAYER E NO INIMIGO (OS BLOCOS USAM O BLOCO AZUL: RAIO_AZUL). O FUNDO E O HUD FICAM NORMAIS
function aqua_inicio()
{
	if(global.raio_mix <= 0) exit;
	shader_set(sh_aqua);
	shader_set_uniform_f(shader_get_uniform(sh_aqua, "u_raio"), global.raio_mix);
}
function aqua_fim()
{
	if(shader_current() == sh_aqua) shader_reset();
}

//MODO BONUS (BLOCO ESPECIAL): POR BONUS_TEMPO TODOS OS BLOCOS FICAM COM MOEDA E CADA BLOCO DESTRUIDO SOLTA UMA
function bonus_ativar(_x, _y)
{
	global.bonus_moedas = BONUS_TEMPO;
	som_tocar(snd_bonus);
	shakes(6, 2);
	efeito_texto(global.linguagem == 0 ? "BÔNUS DE MOEDAS!" : "COIN BONUS!", _x, _y, c_yellow, 1.3);
}

//COMBO DE LINHAS EM SEQUENCIA==================================
//FECHAR OUTRA LINHA ANTES DO TEMPO ACABAR AUMENTA O COMBO (APARECE NA LATERAL E O SOM DE FECHAR LINHA
//VAI FICANDO MAIS AGUDO). OS PONTOS DA LINHA SAO SEMPRE PONTOS_LINHA (O COMBO NAO MULTIPLICA)
#macro COMBO_TEMPO			(room_speed * 4)

//FEBRE==================================
//FECHAR FEBRE_LINHAS LINHAS SEGUIDAS (DENTRO DO TEMPO DO COMBO, CONTANDO DUPLA/TRIPLA) LIGA A FEBRE:
//PONTOS X2, PEÇAS CAINDO MAIS RAPIDO, MUSICA ACELERADA, BORDA PISCANDO E O RETRATO COM PODER (AZUL)
#macro FEBRE_LINHAS			3
#macro FEBRE_TEMPO			(room_speed * 8)
#macro FEBRE_PONTOS			2		//MULTIPLICADOR DE PONTOS
#macro FEBRE_QUEDA			1.5		//AS PEÇAS ESPERAM MENOS ENTRE UMA CASA E OUTRA

//MULTIPLICADOR DE PONTOS: FEBRE (2X) E RAIO (2X). OS DOIS JUNTOS = 4X
function febre_mult()
{
	var _m = global.febre > 0 ? FEBRE_PONTOS : 1;
	if(global.raio > 0) _m *= RAIO_PONTOS;
	return _m;
}

function febre_ativar()
{
	//OS PONTOS X2 JA VALEM NA HORA. AS PEÇAS SO FICAM MAIS RAPIDAS DEPOIS DA CONTAGEM DE 3S
	global.febre = FEBRE_TEMPO + CONTAGEM_TEMPO;
	global.febre_rapida = false;
	contagem_iniciar(texto("febre"), function() { global.febre_rapida = true; });
	global.combo_linhas = 0;
	som_tocar(zap1); //O "FEBRE! X2" APARECE NA CONTAGEM
	som_tocar(snd_febre); //ESCALA SUBINDO ATE O ACORDE
	if(instance_exists(obj_area)) onda_choque(obj_area.x + obj_area.sprite_width/2, obj_area.y + obj_area.sprite_height/2, 160, 6, 40);
	shakes(10, 3);
}

//ONDA DE PEÇAS==================================
//DE TEMPOS EM TEMPOS APARECE "ONDA!" E CAEM VARIAS PEÇAS EM SEQUENCIA (LADO A LADO), COM TUDO CAINDO 2X MAIS RAPIDO.
//DEPOIS O JOGO ACALMA. QUEM CONTROLA E O OBJ_GAME_CONTROL (AS PEÇAS NASCEM PELO OBJ_AREA.CRIAR_PECA_ONDA)
#macro ONDA_INTERVALO		(room_speed * 40)	//TEMPO ENTRE UMA ONDA E OUTRA
#macro ONDA_PRIMEIRA		(room_speed * 75)	//A PRIMEIRA ONDA DA PARTIDA (O PRIMEIRO MINUTO E TRANQUILO)
#macro DUPLA_PRIMEIRA		(room_speed * 110)	//PEÇAS DUPLAS: A PRIMEIRA VEZ NA PARTIDA
#macro DUPLA_INTERVALO		(room_speed * 70)	//DEPOIS, UMA A CADA...
#macro DUPLA_DURACAO		(room_speed * 15)	//QUANTO TEMPO DURA (CADA PEÇA QUE NASCE VEM COM OUTRA)
#macro DUPLA_ESPACO			(room_speed * .5)	//TEMPO ENTRE A PRIMEIRA E A SEGUNDA PEÇA DO PAR
#macro ONDA_PECAS_MIN		4
#macro ONDA_PECAS_MAX		5
#macro ONDA_AVISO			CONTAGEM_TEMPO		//TEMPO ENTRE O "ONDA!" E A PRIMEIRA PEÇA (A CONTAGEM DE 3S)
#macro ONDA_ESPACO			20					//FRAMES ENTRE UMA PEÇA DA ONDA E OUTRA
#macro ONDA_RAPIDA			(room_speed * 5)	//QUANTO TEMPO TUDO CAI 2X MAIS RAPIDO DEPOIS DO AVISO

//ONDA DE LASER (OBJ_ONDA_LASER): DE TEMPOS EM TEMPOS VEM 1 A 3 LASERS VERTICAIS NA COLUNA ONDE O PLAYER ESTA.
//CADA UM AVISA ANTES (LASER_AVISO) E DEPOIS DISPARA: DANO NO PLAYER E QUEBRA OS BLOCOS DA COLUNA
#macro LASER_ONDA_PRIMEIRA	(room_speed * 60)	//PRIMEIRA ONDA DE LASER DA PARTIDA
#macro LASER_ONDA_INTERVALO	(room_speed * 50)	//DEPOIS, UMA A CADA...
#macro LASER_ONDA_MIN		1					//LASERS EM CADA ONDA (SORTEADO ENTRE OS DOIS)
#macro LASER_ONDA_MAX		3
#macro LASER_AVISO			(room_speed * .8)	//TEMPO MOSTRANDO ONDE VAI CAIR
#macro LASER_ATIVO			(room_speed * .35)	//TEMPO LIGADO (DANDO DANO E QUEBRANDO BLOCOS)
#macro LASER_ESPACO			(room_speed * .7)	//TEMPO ENTRE UM LASER E OUTRO DA MESMA ONDA
#macro LASER_LARGURA		12					//LARGURA DO FEIXE QUE DA DANO (PX)

//COMEÇA UMA ONDA DE PEÇAS (AVISO + CONTAGEM)
function onda_iniciar()
{
	//TUDO SO CAI 2X MAIS RAPIDO DEPOIS DA CONTAGEM (AS PEÇAS DA ONDA TAMBEM SO COMEÇAM DEPOIS DELA)
	contagem_iniciar(texto("onda"), function() { global.onda_timer = ONDA_RAPIDA; });
	shakes(8, 2);
}

//CONTAGEM DE 3S ANTES DE O JOGO FICAR MAIS RAPIDO (ONDA, FEBRE, 2O ANDAR, LEVEL)================
//MOSTRA "3, 2, 1" NO MEIO DA ARENA (OBJ_GAME_CONTROL DRAW_64) E SO DEPOIS RODA _ACAO (QUE ACELERA O JOGO).
//SE JA TIVER UMA CONTAGEM RODANDO, A AÇAO DELA ACONTECE NA HORA E COMEÇA A NOVA
#macro CONTAGEM_TEMPO		(room_speed * 3)

function contagem_iniciar(_texto, _acao)
{
	if(global.contagem > 0 and is_callable(global.contagem_acao)) global.contagem_acao();
	global.contagem = CONTAGEM_TEMPO;
	global.contagem_texto = _texto;
	global.contagem_acao = _acao;
	som_tocar(Bip_2);
}

//CHAMADO UMA VEZ POR LINHA (OU GRUPO DE LINHAS) FECHADA
function combo_linha(_linhas, _x, _y)
{
	global.evento_linha++; //CADA FECHAMENTO DE LINHA ABRE O SEU QUADRO DE PONTOS
	emocao_mostrar(1); //RETRATO DO HUD COMEMORA
	with(obj_player) reflexo_energia = min(100, reflexo_energia + REFLEXO_LINHA); //PODER DO REFLEXO RECUPERA
	
	//FECHOU DENTRO DO TEMPO DO COMBO: SOMA NA SEQUENCIA. SENAO COMEÇA DE NOVO
	if(global.combo_timer > 0)
	{
		global.combo_seq++;
		global.combo_linhas += _linhas;
	}
	else
	{
		global.combo_seq = 1;
		global.combo_linhas = _linhas;
	}
	global.combo_timer = COMBO_TEMPO;
	//CHEGOU EM FEBRE_LINHAS SEGUIDAS: LIGA A FEBRE
	if(global.febre <= 0 and global.combo_linhas >= FEBRE_LINHAS) febre_ativar();
	
	//PALAVRA PELA QUANTIDADE DE LINHAS DE UMA VEZ
	var _palavra = "";
	if(_linhas == 2)		_palavra = texto("dupla");
	else if(_linhas == 3)	_palavra = texto("tripla");
	else if(_linhas >= 4)	_palavra = texto("incrivel");
	if(_palavra != "") efeito_texto(_palavra, _x, _y - 22, c_orange, 1.4 + .2 * (_linhas - 2));
	
	//COMBO DE 2 OU MAIS: MOSTRA O "COMBO XN"
	if(global.combo_seq >= 2)
	{
		efeito_texto("COMBO x" + string(global.combo_seq), _x, _y - 42, c_aqua, 1.2 + .1 * min(global.combo_seq, 6));
	}
	
	//TREMIDA MAIS FORTE COM MAIS LINHAS
	shakes(6 + 3 * _linhas, 1 + .7 * _linhas);
	
	//SATISFAÇAO DE FECHAR LINHA: FLASH BRANCO SUTIL NA TELA E O SOM DE LINHA DO JOGO ANTIGO POR BAIXO DA NOTA
	global.flash_linha = min(.35, .15 + .07 * (_linhas - 1));
	audio_play_sound(snd_fechar_linhas_bloco, 1, false, .8);
}

//CADEIA DO ESPECIAL: CADA BLOCO DA ONDA VALE UM POUCO MAIS QUE O ANTERIOR E O SOM VAI SUBINDO
//(GRUPO GRANDE VALE MUITO MAIS QUE VARIOS PEQUENOS)
function especial_bloco_destruido(_x, _y)
{
	global.especial_cadeia++;
	var _n = global.especial_cadeia;
	
	pontos_somar(PONTOS_BLOCO_ESPECIAL * global.level * pontos_mult_andar() * (1 + .1 * (_n - 1)), _x, _y - 8);
	moeda_criar(_x, _y, MOEDAS_POR_BLOCO);
	audio_play_sound(snd_peca_destroy, 1, false, .7, 0, 1 + min(_n, 15) * .03);
	som_nota(min(_n - 1, 14), .45); //CADA BLOCO DA ONDA E A PROXIMA NOTA DA ESCALA
	shakes(4, 1.5);
	
	//ULTIMO BLOCO DO GRUPO: MOSTRA QUANTOS QUEBROU
	global.especial_restantes--;
	if(global.especial_restantes <= 0 and _n >= ESPECIAL_MIN)
	{
		efeito_texto(string(_n) + "x!", _x, _y - 24, c_orange, 1.2 + .05 * min(_n, 12));
	}
}

//MARCA OS BLOCOS QUE O ESPECIAL PODE DESTRUIR AGORA (TEM ENERGIA E O GRUPO DA MESMA COR TEM ESPECIAL_MIN+)
//CHAMADO PELO OBJ_GAME_CONTROL A CADA POUCOS FRAMES. A PEÇA DESENHA O BRILHO E O PLAYER MOSTRA A TECLA
function especial_marcar()
{
	with(obj_peca) pode_especial = false;
	if(global.energia < 1) exit;
	
	//CADA GRUPO SO E CALCULADO UMA VEZ (OS BLOCOS JA VISITADOS SAO PULADOS)
	var _visitado = ds_map_create();
	with(obj_peca)
	{
		if(ds_map_exists(_visitado, id)) continue;
		if(!estou_parado or andar or destruido_por != noone or sou_fantasma or coloracao < 0) continue;
		
		var _grupo = especial_grupo(id)[0];
		var _pode = array_length(_grupo) >= ESPECIAL_MIN;
		for(var i = 0; i < array_length(_grupo); i++)
		{
			ds_map_set(_visitado, _grupo[i], true);
			if(_pode) _grupo[i].pode_especial = true;
		}
	}
	ds_map_destroy(_visitado);
}

//MORTE DOS BLOCOS DA IRMANDADE (DIFERENTE DA MORTE NORMAL):
//UM ANEL BRANCO CRESCE NO LUGAR DO BLOCO E ELE EXPLODE EM MINI-BLOCOS DA COR DELE, QUE SAEM GIRANDO E CAEM
//_FRAME = FRAME DA SPR_PECA DA COR DO BLOCO (0 VERDE, 1 AMARELO, 2 ROXO, 3 AZUL, 4 VERMELHO)
function efeito_morte_irmandade(_x, _y, _frame)
{
	var _anel = instance_create_depth(_x, _y, -1900, obj_efeito_pontos);
	_anel.modo = "anel";
	_anel.timer = 14;
	
	//6 MINI-BLOCOS VOANDO PRA TODOS OS LADOS
	repeat(6)
	{
		var _e = instance_create_depth(_x + random_range(-4, 4), _y + random_range(-4, 4), -1900, obj_efeito_pontos);
		_e.modo = "estilhaco";
		_e.frame = _frame;
		_e.dir_voo = random(360);
		_e.vel_voo = random_range(1.2, 3);
		_e.velv = -random_range(1.5, 3);
		_e.ang = random(360);
		_e.giro = random_range(-15, 15);
		_e.esc = random_range(.25, .4);
		_e.timer = irandom_range(26, 38);
	}
}

//MORTE DOS BLOCOS DE UMA LINHA: 3 MINI-BLOCOS DA COR DELE SUBINDO (MENOR QUE A DA IRMANDADE, PRA NAO POLUIR)
function efeito_morte_linha(_x, _y, _frame)
{
	repeat(3)
	{
		var _e = instance_create_depth(_x + random_range(-3, 3), _y + random_range(-3, 3), -1900, obj_efeito_pontos);
		_e.modo = "estilhaco";
		_e.frame = _frame;
		_e.dir_voo = random_range(40, 140); //PRA CIMA
		_e.vel_voo = random_range(.8, 2);
		_e.velv = -random_range(2, 3.2);
		_e.ang = random(360);
		_e.giro = random_range(-12, 12);
		_e.esc = random_range(.2, .3);
		_e.timer = irandom_range(22, 30);
	}
}

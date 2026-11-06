//PLAYER (O MACACO OU A SKIN ESCOLHIDA). O MOVIMENTO E A MAQUINA DE ESTADOS FICAM NO STEP
//MOVIMENTO
velh = 0;	//VELOCIDADE HORIZONTAL
velv = 0;	//VELOCIDADE VERTICAL (NEGATIVO = SUBINDO)
vel_jump = 4.5; //PADRAO = 4, MAX = 5.5 INICIO = 3.2
vel_jump_max = 5.5;	//PULO MAXIMO
vel_run = 1.4; //1.5 - 2,3;  
vel_giro = 2; //1.5 - 2,3;  
velv_max = 4.5;	//QUEDA MAXIMA
velh_acl = 0;	//ACELERAÇAO HORIZONTAL (NAO USADA)
no_gelo = false;	//EM PE NUM BLOCO DE GELO (ESCORREGA: ACELERA E FREIA DEVAGAR)
lento = 0;		//FRAMES QUE AINDA FALTAM DO FEITIÇO DO BLOCO LENTO (TUDO DO PLAYER FICA LENTO)
rapido = 0;		//FRAMES QUE AINDA FALTAM DA VELOCIDADE (QUEBROU O BLOCO LENTO)
pulo_trampolim = false;	//SUBINDO PELO TRAMPOLIM (OU PELO EMPURRAO) DA GELATINA: SOLTAR O PULO NAO CORTA A SUBIDA

//TIMERS
timer_mover = 0;	//DEPOIS DO WALL JUMP NAO DA PRA CONTROLAR UNS FRAMES
timer_push = 0;	//TEMPO EMPURRANDO UMA PEÇA ANTES DO EMPURRAO
timer_jump = 0;	//COYOTE JUMP RESTANTE
coyote_timer = 10;	//FRAMES DE COYOTE JUMP

//SPRITE
//SPR_PLAYER = GLOBAL.SKIN_PLAYER_1;

//GIRO (VARIAVEIS ANTIGAS)
timer_giro = 0;
super_giro = false;

//VARIAVEIS DE PULO
girar_jump = false;	//FAZ O GIRINHO NO TOPO DO PULO

//GERAL
estado = state.idle;	//ESTADO ATUAL (ENUM STATE)
estado_jump = "Jump";
estado_anim = noone;
giro_ar = false;	//O GIRO COMEÇOU NO AR
dano = noone;	//AREA DE DANO DO GOLPE ATUAL (OBJ_DANO)
soco_fail = false;	//O SOCO VAI FALHAR (ANIMAÇAO DIFERENTE)
subir_climb = false; //CLIMB CONTROL


//VARIAVEIS DE DRAW
alpha_fog = 0;	//BRILHO BRANCO (DANO, DASH...)
esc_y = 1;	//ESTICA/ACHATA (SQUASH AND STRETCH)
esc_x = 1;

//VIDA
imune = 0;	//FRAMES INVENCIVEL
vida_total = 3; //3
vida_atual = vida_total;
meu_climb = noone;
//ESTADOS DO PLAYER (ALGUNS SAO ANTIGOS E NAO SAO MAIS USADOS)
enum state
{
	idle,
	idle_mudar_lado,
	down,
	in_run,
	run,
	run_stop,
	jump,
	wall,
	climb,
	soco,
	super_soco,
	soco_baixo,
	giro,
	morte,
	ocioso,
	bunda_chao,
	dano,
	//
	super_giro,
	teleporte,
	animacao,
	dash,
	push

}


//*************FUNÇOES*************
//ANDA PRO LADO DAS TECLAS (_LERP = QUAO RAPIDO CHEGA NA VELOCIDADE)
mover = function(_vel, _lerp = .7)
{
	if(giro_lat_trava > 0 or global.gorz_trava or vs_parado or amassado > 0) exit; //SEM CONTROLE (RECUO DO GIRO LATERAL): NAO ANDA PELAS TECLAS
	
	var _left, _right;
	
	 _left	= keyboard_check(imp.left);
	 _right	= keyboard_check(imp.rigth);
	
	if(tempo_player_livre()) _vel += TEMPO_VEL_EXTRA; //TEMPO PARADO: ANDA MAIS RAPIDO
	var _velh = (_right - _left) * _vel;
	if(no_gelo) _lerp = min(_lerp, GELO_ATRITO); //NO GELO ACELERA E FREIA DEVAGAR
	velh = lerp(velh, _velh, _lerp)
}

//*************FUNÇOES*************



//SKIN (PERSONAGEM ESCOLHIDO NA TELA DE SELEÇAO)
//JOGADOR 1 OU 2 (O PLAYER 2 DO COOP JA NASCE COM JOGADOR = 2). CADA UM TEM AS SUAS TECLAS E A SUA SKIN
if(!variable_instance_exists(id, "jogador")) jogador = 1;
imp = imputs_jogador(jogador);
skin = jogador == 2 ? global.skin_player_2 : global.skin_player_1;
//VERSUS: O FANTASMA DO PODER (NASCE NA ARENA DO ADVERSARIO COM O STRUCT { VS_FANTASMA : TRUE }), O CORPO PARADO E O AMASSADO
if(!variable_instance_exists(id, "vs_fantasma")) vs_fantasma = false;
vs_parado = false;		//O DONO USOU O PODER: O CORPO FICA PARADO E IMUNE ATE O FANTASMA SAIR
amassado = 0;			//FRAMES QUE FALTAM PRA SE LEVANTAR (O FANTASMA DO ADVERSARIO PULOU EM CIMA)
amasso_imune = 0;		//DEPOIS DE SE LEVANTAR, UM TEMPO SEM SER AMASSADO DE NOVO
reviver = 0;	//COOP: FRAMES QUE FALTAM PRA VOLTAR DEPOIS DE MORRER

//SONS: GUARDA O ULTIMO ESTADO PRA SABER QUANDO ENTROU EM UM NOVO
estado_som = estado;


//DASH
#macro DASH_VEL		4.5		//VELOCIDADE
#macro DASH_TEMPO	10		//DURAÇAO EM FRAMES
#macro DASH_RECARGA	40		//TEMPO ATE PODER DAR OUTRO
timer_dash = 0;
recarga_dash = 0;

timer_morte = 0;	//TEMPO DESDE QUE MORREU (ANIMAÇAO DE MORTE)

//QUALQUER DANO (ESMAGADO, TIRO, LASER, BOMBA, INIMIGO...): NO SOLO, NO COOP E NO VERSUS O JOGADOR SO PERDE DANO_PONTOS PONTOS (DO PLACAR DELE).
//SE O PLACAR ESTA ZERADO (NADA PRA PERDER), ENTAO PERDE UM CORAÇAO. COM POUCOS PONTOS PERDE O QUE TEM
//(O CORAÇAO SO VAI QUANDO NAO SOBRA NADA). O GAME OVER VEM DE ARENA CHEIA OU DE ACABAR OS CORAÇOES
#macro DANO_PONTOS	100		//SOLO, COOP E VERSUS: CADA UM PERDE SO 100 (SE TIVER MENOS QUE ISSO, PERDE O QUE TEM; SE TIVER ZERO, PERDE CORAÇAO)
dano_cobrar = function()
{
	//NO COOP CADA UM PERDE OS SEUS PONTOS (SE OS DELE ACABARAM, PERDE CORAÇAO MESMO QUE O OUTRO TENHA PONTOS)
	//NO VERSUS CADA UM TEM O SEU PLACAR (PONTOS_1 E PONTOS_2)
	var _meus = global.pontos_1;
	if(coop_pontos_ativo()) _meus = global.coop_pts[clamp(jogador, 1, 2) - 1];
	else if(room == rm_versus and jogador == 2) _meus = global.pontos_2;
	if(modo_arcade() and _meus > 0)
	{
		pontos_tirar(DANO_PONTOS, x, bbox_top - 14, jogador); //(NO MODO IMORTAL OS PONTOS TAMBEM CAEM: SO OS CORAÇOES FICAM PROTEGIDOS)
		return;
	}
	if(IMORTAL) exit; //MODO DE TESTE: LEVA O DANO (EMPURRAO) MAS NAO PERDE CORAÇAO
	vida_atual--;
}

//LEVAR DANO (LASER). DEPOIS FICA IMUNE UM TEMPO, PISCANDO
levar_dano = function(_dir, _dano = ESCUDO_DANO)
{
	if(imune > 0 or estado == state.morte or vs_fantasma or vs_parado) exit;
	
	//ESCUDO: SEGURA O ATAQUE E PERDE RESISTENCIA (ZEROU: QUEBRA ATE ENCHER DE NOVO)
	if(tem_poder("escudo") and !escudo_quebrado)
	{
		escudo_vida -= _dano;
		if(escudo_vida <= 0)
		{
			escudo_vida = 0;
			escudo_quebrado = true;
			som_tocar(snd_desfazer_irmandade);
		}
		else som_tocar(snd_hit, .1);
		//BLOQUEOU: SO UM TEMPINHO IMUNE SEM PISCAR (NAO LEVOU DANO) E O EFEITO DO BLOQUEIO NA BOLHA
		imune = room_speed * .5;
		imune_escudo = true;
		escudo_bloqueio = 20;
		escudo_lado = -_dir;
		som_tocar(snd_escudo, .05);
		efeito_texto(global.linguagem == 0 ? "BLOQUEOU!" : "BLOCKED!", x, y - 30, #5CC8FF, .8);
		velh = 1.5 * _dir;
		shakes(5, 2);
		exit;
	}
	
	//SEM ESCUDO: PERDE PONTOS (OU UM CORAÇAO SE NAO TIVER PONTOS). SEM CORAÇOES: MORRE
	dano_cobrar();
	if(vida_atual <= 0)
	{
		morrer();
		exit;
	}
	//LEVOU DANO: FICA IMUNE, E EMPURRADO PRA TRAS E PRA CIMA (E AS BORDAS DA TELA PISCAM VERMELHO)
	imune = room_speed * 1.5;
	global.fundo_dano = 1;
	imune_escudo = false;
	estado = state.dano;
	timer_dano = 0;
	hitstop(4);
	velh = 2.5 * _dir;
	velv = -2.5;
	alpha_fog = 1;
	shakes(8, 2);
}

//COOP: O PARCEIRO PISOU NA CABEÇA. SO O EFEITO DO DANO (EMPURRAO, PISCADA, TREMIDA): NAO PERDE VIDA E NAO FICA IMUNE
efeito_dano = function(_dir)
{
	if(estado == state.morte or vs_fantasma) exit;
	estado = state.dano;
	timer_dano = 0;
	velh = 2 * _dir;
	velv = -1.5;
	alpha_fog = 1;
	pisca_dano = room_speed * .5;
	shakes(4, 1);
	audio_play_sound(snd_hit, 1, false, .7, 0, 1.15);
}

//MORRER (ESMAGADO, SEM VIDA OU ARENA CHEIA). O OBJ_GAME_CONTROL MOSTRA O GAME OVER
morrer = function(_forcar = false)
{
	if(estado == state.morte or vs_fantasma or (IMORTAL and !_forcar)) exit; //(_FORCAR: VERSUS, ARENA CHEIA)
	if(room == rm_versus and global.vs_perdedor == 0) global.vs_perdedor = jogador; //VERSUS: QUEM MORRE PERDE
	if(TESTE_AUTO) show_debug_message("[TESTE] player morreu: " + string(debug_get_callstack()));
	
	//ANIMAÇAO DE MORTE: ONDA DE CHOQUE GRANDE, PULO PRA CIMA E TREMIDA FORTE
	vida_atual = 0;
	estado = state.morte;
	onda_choque(x, y - 10, 110, 7, 40);
	velh = 0;
	velv = -4;
	timer_morte = 0;
	alpha_fog = 1;
	shakes(15, 3);
	reviver = COOP_REVIVER; //COOP: VOLTA DEPOIS DE UM TEMPO (SE O PARCEIRO TIVER VIVO)
}

//AMASSADO: FICA ACHATADO NO CHAO E SEM CONTROLE POR UM TEMPO. VERSUS: O FANTASMA DO ADVERSARIO PULOU EM CIMA.
//COOP: O PARCEIRO PULOU (OU CAIU GIRANDO) EM CIMA. _IMUNE_TOTAL = TEMPO (FRAMES) EM QUE FICA INVULNERAVEL (PRA NAO LEVAR OUTRO PISAO E
//NEM DANO NA HORA), CONTADO DESDE O PISAO. 0 = SO A IMUNIDADE CURTA DE DEPOIS DE SE LEVANTAR
amassar = function(_imune_total = 0)
{
	if(estado == state.morte or vs_fantasma or amassado > 0 or amasso_imune > 0) exit;
	if(_imune_total > 0)
	{
		imune = max(imune, _imune_total);
		imune_escudo = false;
		amasso_imune = _imune_total;
	}
	amassado = global.coop ? VS_AMASSO * .5 : VS_AMASSO; //NO COOP O AMASSADO DURA METADE DO VERSUS
	velh = 0;
	estado = state.idle;
	esc_x = 1.8 * sign(image_xscale);
	esc_y = .3;
	alpha_fog = 1;
	poeira(x, y + 6, 10);
	onda_choque(x, y, 70, 5, 24);
	shakes(10, 3);
	audio_play_sound(snd_hit2, 1, false, .8, 0, .7);
	if(!global.coop) efeito_texto(global.linguagem == 0 ? "AMASSADO!" : "SQUASHED!", x, y - 28, #FF5577, 1.2); //NO COOP NAO MOSTRA O TEXTO
}

quique_seq = 0; //QUANTOS BLOCOS QUEBROU QUICANDO COM O GIRO NO AR SEM PISAR NO CHAO

//GIRO DE FOGO: QUEBRAR GIRO_FOGO_SEGUIDOS BLOCOS COM O GIRO, SEGUIDOS (CADA QUEBRADA ATE GIRO_FOGO_JANELA DEPOIS DA ANTERIOR).
//SO GIRAR NAO ACENDE O FOGO: TEM QUE QUEBRAR. OUTRO JEITO: GIRAR NO AR DEPOIS DE CAIR DE MUITO ALTO (GIRO_FOGO_ALTURA).
//BOTA FOGO NO GIRO: EFEITO DE FOGO NO PERSONAGEM E CADA BLOCO QUEBRADO GIRANDO VALE GIRO_FOGO_PONTOS A MAIS.
//PAROU DE QUEBRAR POR MAIS QUE A JANELA: O FOGO APAGA
#macro GIRO_FOGO_SEGUIDOS	3
#macro GIRO_FOGO_JANELA		(room_speed * 1.2)	//TEMPO MAXIMO ENTRE UMA QUEBRADA E OUTRA PRA CONTAR COMO SEGUIDA
#macro GIRO_FOGO_PONTOS		5					//PONTOS A MAIS POR BLOCO QUEBRADO NO GIRO DE FOGO
#macro GIRO_FOGO_ALTURA		128					//CAIR DE PELO MENOS ISSO (PX) E GIRAR NO AR ACENDE O FOGO DIRETO (8 CASAS)
giro_seq = 0;		//BLOCOS QUEBRADOS COM O GIRO, SEGUIDOS
giro_janela = 0;	//FRAMES QUE AINDA DA PRA EMENDAR A PROXIMA QUEBRADA (NAO CONTA ENQUANTO TA GIRANDO)
queda_dist = 0;		//QUANTO JA CAIU (PX) SEM TOCAR NO CHAO NEM SUBIR (PRA GIRO DE FOGO DE QUEDA ALTA)

//TA COM O GIRO DE FOGO?
em_fogo = function() { return giro_seq >= GIRO_FOGO_SEGUIDOS; }

//EFEITO DE ACABAR DE PEGAR FOGO
giro_fogo_efeito = function()
{
	efeito_texto(global.linguagem == 0 ? "GIRO DE FOGO!" : "FIRE SPIN!", x, y - 32, c_orange, 1);
	audio_play_sound(snd_Giro, 1, false, 1, 0, .7);
	som_nota(7, .5);
	som_nota(9, .4);
	alpha_fog = 1;
}

//QUEBROU UM BLOCO COM O GIRO: CONTA OS SEGUIDOS (CHAMADO NO MOMENTO DA QUEBRA)
giro_contar = function()
{
	if(giro_janela > 0) giro_seq++;
	else giro_seq = 1;
	giro_janela = GIRO_FOGO_JANELA;
	//ACABOU DE PEGAR FOGO
	if(giro_seq == GIRO_FOGO_SEGUIDOS) giro_fogo_efeito();
}

//COMEÇOU UM GIRO NO AR DEPOIS DE UMA QUEDA ALTA: ACENDE O FOGO DIRETO
giro_fogo_queda = function()
{
	var _ja = em_fogo();
	giro_seq = max(giro_seq, GIRO_FOGO_SEGUIDOS);
	giro_janela = GIRO_FOGO_JANELA;
	if(!_ja) giro_fogo_efeito();
}

timer_dano = 0; //TEMPO NO ESTADO DE DANO (SEGURANÇA PRA NAO FICAR PRESO)
pisca_dano = 0; //COOP: PISCANDO DEPOIS DO PISAO DO PARCEIRO (SO VISUAL)


//ESMAGADO POR UMA PEÇA CAINDO (PRENSADO CONTRA O CHAO OU OUTRO BLOCO):
//PERDE PONTOS (OU UM CORAÇAO SE NAO TIVER PONTOS, VER DANO_COBRAR) SE NAO TIVER IMUNE E E EXPULSO PRA CIMA DA PEÇA QUE ESMAGOU.
//SE LA TIVER OCUPADO, VAI SUBINDO CASA POR CASA OU TENTA AS COLUNAS DO LADO. SO MORRE SE ERA A ULTIMA VIDA
//(OU SE NAO TIVER NENHUM LUGAR LIVRE PRA ONDE IR)
esmagado = function(_bloco)
{
	if(estado == state.morte) exit;
	
	if(imune <= 0)
	{
		dano_cobrar(); //PERDE PONTOS (OU UM CORAÇAO SE NAO TIVER PONTOS)
		if(vida_atual <= 0)
		{
			morrer();
			exit;
		}
		imune = room_speed * 1.5;
		imune_escudo = false;
		alpha_fog = 1;
		global.fundo_dano = 1;
		shakes(10, 3);
	}
	
	//PROCURANDO UM LUGAR LIVRE: EM CIMA DA PEÇA, SUBINDO, OU NAS COLUNAS DO LADO (O FANTASMA CONTA COMO LIVRE)
	var _y_base = instance_exists(_bloco) ? _bloco.bbox_top : y - CEL;
	var _xs = [x, x - CEL, x + CEL, x - CEL * 2, x + CEL * 2];
	var _achou = false;
	for(var k = 0; k < array_length(_xs) and !_achou; k++)
	{
		for(var d = 0; d < 6 and !_achou; d++)
		{
			var _ty = _y_base - d * CEL;
			if(!solido(_xs[k], _ty))
			{
				x = _xs[k];
				y = _ty;
				_achou = true;
			}
		}
	}
	if(!_achou)
	{
		morrer();
		exit;
	}
	
	//ACHOU: VAI PRA LA EM ESTADO DE DANO
	estado = state.dano;
	timer_dano = 0;
	velh = 0;
	velv = -2;
}

//QUICANDO EM CIMA DO INIMIGO (PISAO OU GIRO NO AR). SEGURANDO O PULO, QUICA MAIS ALTO
quicar = function()
{
	velv = keyboard_check(imp.jump_press) ? -vel_jump * 1.15 : -vel_jump;
	estado = state.jump;
	giro_ar = false;
	esc_x = .8 * image_xscale;
	esc_y = 1.3;
}


//COLISAO DO PLAYER COM BLOCOS==================================
//O PLAYER PASSA POR DENTRO DO BLOCO FANTASMA. TODA COLISAO DO PLAYER COM BLOCO PASSA POR ESSAS FUNÇOES
//(OBJ_BLOCK OU PEÇA QUE NAO SEJA FANTASMA). OBS: OS *_LIST DO GML NAO ACEITAM LISTA DE OBJETOS

//PEÇA SOLIDA (NAO FANTASMA) NA POSIÇAO, OU NOONE
peca_solida = function(_x, _y)
{
	var _lista = ds_list_create();
	var _n = instance_place_list(_x, _y, obj_peca, _lista, false);
	var _r = noone;
	for(var k = 0; k < _n; k++)
	{
		if(!_lista[| k].sou_fantasma)
		{
			_r = _lista[| k];
			break;
		}
	}
	ds_list_destroy(_lista);
	return _r;
}

//BLOCO OU PEÇA SOLIDA NA POSIÇAO, OU NOONE
solido_inst = function(_x, _y)
{
	var _b = instance_place(_x, _y, obj_block);
	if(_b != noone) return _b;
	return peca_solida(_x, _y);
}

//TEM QUALQUER COISA SOLIDA NA POSIÇAO? (TRUE/FALSE)
solido = function(_x, _y)
{
	return solido_inst(_x, _y) != noone;
}

//TEM BLOCO OU PEÇA SOLIDA NA LINHA ENTRE OS DOIS PONTOS?
solido_linha = function(_x1, _y1, _x2, _y2)
{
	if(collision_line(_x1, _y1, _x2, _y2, obj_block, false, true) != noone) return true;
	var _lista = ds_list_create();
	var _n = collision_line_list(_x1, _y1, _x2, _y2, obj_peca, false, true, _lista, false);
	var _r = false;
	for(var k = 0; k < _n; k++)
	{
		if(!_lista[| k].sou_fantasma)
		{
			_r = true;
			break;
		}
	}
	ds_list_destroy(_lista);
	return _r;
}

//ANDAR DURANTE O SOCO (FRAÇAO DA CORRIDA). PRA CONSEGUIR ALCANÇAR O BLOCO QUE ACABOU DE EMPURRAR
#macro SOCO_ANDAR	.35
#macro SOCO_ALCANCE	2		//LARGURA DA HITBOX DO SOCO (1 = 4PX, O ORIGINAL). CRESCE SO PRA FRENTE
#macro GIRO_QUIQUE_FORTE	1.35	//QUIQUE DO GIRO NO AR EM CIMA DE UMA PEÇA SEGURANDO O PULO (ERA 1.15)
giro_baixo = false; //GIRO DO BAIXO + GIRO (QUEBRA SO O BLOCO DE BAIXO)

//GIRO LATERAL (NO AR: SEGURA SHIFT + GIRO): O PLAYER SE JOGA GIRANDO PRO LADO ESCOLHIDO. NO FIM DA ANIMAÇAO VOLTA A CAIR.
//SE BATER NUM BLOCO, QUEBRA ELE E VOLTA PRO PULO (DA PRA EMENDAR OUTRO GIRO LATERAL E IR QUEBRANDO OS BLOCOS DO LADO).
//BATEU NA PAREDE/CHAO SOLIDO OU ACABOU SEM BATER: SO PODE GIRAR DE LADO DE NOVO DEPOIS DE PISAR NO CHAO
giro_lat_vel = 3.8;	//VELOCIDADE PRO LADO DURANTE O GIRO LATERAL
giro_lat_tempo = 8;	//FRAMES MAXIMOS DO GIRO LATERAL (VEL * TEMPO = DISTANCIA)
giro_lat_pulo = 3.4;	//PULINHO QUE DA AO QUEBRAR UM BLOCO (VOLTA PRO PULO)
giro_lat_recuo = 2.8;	//QUANTO VOLTA PRA TRAS AO QUEBRAR (PRA CONSEGUIR ENGATAR OUTRO GIRO NOS BLOCOS SEGUINTES)
giro_lat_trava_tempo = (room_speed * .15);	//TEMPO SEM CONTROLE DO PLAYER DEPOIS DE QUEBRAR UM BLOCO COM O GIRO LATERAL
giro_lat_hitstop = 5;	//FRAMES DE HITSTOP (O JOGO CONGELA UM INSTANTE) AO QUEBRAR UM BLOCO COM O GIRO LATERAL
giro_lat_anim = 1.7;	//VELOCIDADE DA ANIMAÇAO DO GIRO LATERAL
giro_lat = false;		//ESTOU NO GIRO LATERAL?
giro_lat_livre = true;	//PODE COMEÇAR UM GIRO LATERAL AGORA? (VOLTA A TRUE AO PISAR NO CHAO OU AO QUEBRAR UM BLOCO)
giro_lat_dir = 1;		//LADO DO GIRO LATERAL (-1 ESQUERDA, 1 DIREITA)
giro_lat_t = 0;			//FRAMES QUE JA PASSARAM NO GIRO LATERAL
giro_lat_trava = 0;		//FRAMES QUE AINDA FALTAM SEM CONTROLE (DEPOIS DE QUEBRAR UM BLOCO)
chao_antes = true;	//GAMEFEEL: TAVA NO CHAO NO FRAME ANTERIOR (POEIRA NO PULO E NA ATERRISSAGEM)
velv_antes = 0;	//VELOCIDADE VERTICAL NO FRAME ANTERIOR
rastro_dash = [];	//GAMEFEEL: SOMBRAS DO DASH

//PODERES DO DROP (SCR_PODERES)
pulo_duplo_usado = false;	//ASAS: JA USOU O SEGUNDO PULO NESSE AR
dash_dx = 1;				//DASH: DIREÇAO (COM O PODER DO DASH PODE SER QUALQUER UMA DAS 8)
dash_dy = 0;
dash_ang = 0;				//DASH: ANGULO DA SPRITE (INCLINA PRA DIREÇAO DO DASH E VOLTA SUAVE QUANDO ACABA)
reflexo_energia = 100;		//REFLEXO: CADA ESQUIVA GASTA REFLEXO_CUSTO
escudo_vida = 100;			//ESCUDO: RESISTENCIA
escudo_quebrado = false;	//QUEBROU: SO VOLTA QUANDO A BARRA ENCHER DE NOVO
escudo_bloqueio = 0;		//FRAMES DO EFEITO DE BLOQUEIO (A BOLHA BRILHA E SOLTA UM ANEL)
escudo_lado = 1;			//LADO DE ONDE VEIO O ATAQUE BLOQUEADO (-1 ESQUERDA, 1 DIREITA)
imune_escudo = false;		//A IMUNIDADE ATUAL VEIO DO ESCUDO (NAO PISCA: O PLAYER NAO LEVOU DANO)
mortal = 0;					//ANIMAÇAO DO MORTAL DA ESQUIVA (FRAMES QUE FALTAM)

//REFLEXO: DA UM MORTAL PRA ESQUIVAR DO TIRO
esquivar = function()
{
	mortal = 18;
	alpha_fog = .7;
	imune = max(imune, 20);
	som_tocar(snd_roll, .1);
}

//COOP: VOLTA NO LUGAR DO PARCEIRO (QUE TA VIVO), COM A VIDA CHEIA E UM TEMPINHO INVENCIVEL
reviver_agora = function()
{
	var _p = noone;
	with(obj_player) if(id != other.id and estado != state.morte) _p = id;
	if(_p == noone) exit;
	x = _p.x;
	y = _p.y;
	estado = state.jump;
	velh = 0;
	velv = -2;
	vida_atual = vida_total;
	imune = room_speed * 2;
	timer_morte = 0;
	alpha_fog = 1;
	var _anel = instance_create_depth(x, y - 10, depth - 1, obj_efeito_pontos);
	_anel.modo = "anel";
	_anel.timer = 16;
	efeito_texto("P" + string(jogador) + "!", x, y - 30, jogador == 2 ? COOP_COR_P2 : COOP_COR_P1, 1.3);
	som_tocar(snd_certo);
}

//COOP: O PLAYER 1 CRIA O PLAYER 2 DO LADO DELE (O STRUCT JA DA O JOGADOR = 2 ANTES DO CREATE DELE RODAR)
if(global.coop and jogador == 1 and instance_number(obj_player) == 1)
{
	instance_create_layer(x + CEL * 2, y, layer, obj_player, { jogador : 2 });
}

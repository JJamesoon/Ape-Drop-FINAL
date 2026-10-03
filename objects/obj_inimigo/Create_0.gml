//BLOCO INIMIGO: UM BLOCO SOZINHO QUE CAI DIRETO, CRIA PERNINHAS QUANDO BATE NO CHAO
//E ANDA DE UM LADO PRO OUTRO (TIPO O GOOMBA DO MARIO). NAO ENTRA NA GRADE, NAS LINHAS NEM NA FILA DO TELEPORTE
//
//ESTADOS: "AVISO" (TREME ONDE NASCEU) -> "CAINDO" -> "BROTANDO" (AS PERNAS CRESCEM) -> "ANDANDO"
//         "PRESO" (ENTRE 2 BLOCOS, SEM PRA ONDE ANDAR): PARA, RECOLHE AS PERNAS E VIRA UM BLOCO NORMAL
//MORTES:  "AMASSADO" (PISAO: ACHATA E SOME) OU "NOCAUTE" (GIRO, SOCO OU PEÇA: VIRA DE PONTA CABEÇA E CAI PRA FORA DA TELA)
//
//PLAYER: PISAR EM CIMA, GIRAR OU SOCAR MATA. ENCOSTAR DE LADO OU POR BAIXO TIRA UMA VIDA
//PEÇAS: SE UMA PEÇA ENTRAR NO LUGAR DELE (CAINDO EM CIMA, TELEPORTADA OU EMPURRADA PELO SOCO), ELE MORRE

#macro INIMIGO_AVISO		24		//FRAMES TREMENDO ANTES DE CAIR
#macro INIMIGO_GRAV			.3
#macro INIMIGO_QUEDA_MAX	6		//VELOCIDADE MAXIMA DA QUEDA
#macro INIMIGO_VEL			.45		//VELOCIDADE ANDANDO (PX POR FRAME)
#macro INIMIGO_PERNAS		3		//ALTURA DAS PERNAS (O CORPO SOBE ISSO)
#macro INIMIGO_BROTAR		16		//FRAMES PRAS PERNAS CRESCEREM
#macro INIMIGO_PRESO		40		//FRAMES PARADO ENTRE 2 BLOCOS ANTES DE VIRAR UM BLOCO NORMAL

//BOMBA: O MESMO INIMIGO (CRIADO COM { BOMBA : TRUE }). ANDA IGUAL, MAS DEPOIS DE BOMBA_TEMPO EXPLODE:
//DESTROI OS BLOCOS EM VOLTA (OS PONTOS DELES SAO TIRADOS DO JOGADOR) E DA DANO NO PLAYER PERTO.
//NOS ULTIMOS BOMBA_AVISO ELA PULSA (CADA VEZ MAIS RAPIDO). MATAR ELA ANTES (PISAO, GIRO, SOCO) DESARMA.
//ESMAGADA POR UMA PEÇA OU UMA EXPLOSAO DO LADO: EXPLODE NA HORA
#macro BOMBA_TEMPO			(room_speed * 7)	//TEMPO DO PAVIO (CONTA DEPOIS QUE ELA PISA NO CHAO)
#macro BOMBA_AVISO			(room_speed * 3)	//ULTIMOS FRAMES: PULSA AVISANDO
#macro BOMBA_RAIO			30					//BLOCOS COM O MEIO A MENOS DISSO (PX) EXPLODEM (AS 8 CASAS EM VOLTA)
#macro BOMBA_DANO_RAIO		34					//PLAYER A MENOS DISSO LEVA DANO

if(!variable_instance_exists(id, "bomba")) bomba = false; //E UMA BOMBA? (VEM NO INSTANCE_CREATE)

//CABEÇUDO: O MESMO INIMIGO (CRIADO COM { CABECUDO : TRUE }), COM CHIFRES E CARA BRAVA (SPR_BLOCO_CABECUDO). CAI E ANDA
//IGUAL, MAS NAO DA MEIA-VOLTA NOS BLOCOS: DA UMA CABEÇADA E EMPURRA O BLOCO UMA CASA (SE NAO DER, O BLOCO QUEBRA) E SEGUE.
//NA PAREDE DA CABEÇADAS COM UM INTERVALO E NA CABECUDO_BATIDAS MORRE. NO PLAYER DE LADO: CABEÇADA QUE EMPURRA, SEM DANO
//(AS MACROS CABECUDO_* FICAM NO SCR_PONTOS)
if(!variable_instance_exists(id, "cabecudo")) cabecudo = false;
cab_espera	= 0;	//FRAMES PARADO DEPOIS DE UMA CABEÇADA
cab_batidas	= 0;	//CABEÇADAS NA PAREDE
cab_bump	= 0;	//ANIMAÇAO DA CABEÇADA (1 NA HORA, VOLTA PRO 0)
bomba_timer = BOMBA_TEMPO;	//PAVIO
bomba_tic = 0;				//TIC-TAC DO AVISO

sprite_index = cabecudo ? spr_bloco_cabecudo : spr_inimigo;
mask_index = spr_peca; //COLISAO DO TAMANHO DE UMA CELULA, IGUAL AOS BLOCOS
image_speed = 0;

estado = "aviso";	//ESTADO ATUAL
timer = 0;	//TEMPO NO ESTADO
velh = 0;
velv = 0;
resto_x = 0; //SOBRA DO MOVIMENTO (A POSIÇAO FICA SEMPRE INTEIRA, IGUAL A DOS BLOCOS)
resto_y = 0;
dir = choose(-1, 1); //LADO PRA ONDE ANDA

//DRAW
pernas = 0;		//ALTURA ATUAL DAS PERNAS (0 ATE INIMIGO_PERNAS)
passo = 0;		//ANIMAÇAO DOS PES
esc_x = 1;	//SQUASH/STRETCH
esc_y = 1;
alpha = 1;	//TRANSPARENCIA (SOME NO AMASSADO)
alpha_fog = 0;	//BRILHO BRANCO
shake_x = 0;	//TREMIDA


//FUNÇOES========================================

//ESTA VIVO? (NAO ESTA MORRENDO)
vivo = function()
{
	return estado != "amassado" and estado != "nocaute";
}

//OUTRO INIMIGO VIVO NA POSIÇAO (IGNORA QUEM JA ESTA ENCAVALADO NELE, PRA NAO TRAVAREM UM NO OUTRO)
inimigo_em = function(_x, _y)
{
	var _lista = ds_list_create();
	var _n = instance_place_list(_x, _y, obj_inimigo, _lista, false);
	var _achou = noone;
	for(var k = 0; k < _n; k++)
	{
		var _o = _lista[| k];
		if(_o.vivo() and !place_meeting(x, y, _o))
		{
			_achou = _o;
			break;
		}
	}
	ds_list_destroy(_lista);
	return _achou;
}

//SOLIDO PRO INIMIGO: BLOCO/PAREDE, QUALQUER PEÇA (ATE O FANTASMA) E OUTRO INIMIGO
solido = function(_x, _y)
{
	return place_meeting(_x, _y, obj_block) or place_meeting(_x, _y, obj_peca) or inimigo_em(_x, _y) != noone;
}

//MOVE DE PIXEL EM PIXEL. RETORNA TRUE SE BATEU EM ALGO
mover_x = function(_vel)
{
	//JUNTA A FRAÇAO DO MOVIMENTO E SO ANDA OS PIXELS INTEIROS
	resto_x += _vel;
	var _px = round(resto_x);
	resto_x -= _px;
	repeat(abs(_px))
	{
		if(solido(x + sign(_px), y))
		{
			resto_x = 0;
			return true;
		}
		x += sign(_px);
	}
	return false;
}

//IGUAL AO MOVER_X, NA VERTICAL (BATEU: ZERA A QUEDA)
mover_y = function(_vel)
{
	resto_y += _vel;
	var _px = round(resto_y);
	resto_y -= _px;
	repeat(abs(_px))
	{
		if(solido(x, y + sign(_px)))
		{
			resto_y = 0;
			velv = 0;
			return true;
		}
		y += sign(_px);
	}
	return false;
}

//PRESO ENTRE 2 BLOCOS (OS DOIS LADOS FECHADOS)
preso = function()
{
	return solido(x - 1, y) and solido(x + 1, y);
}

//VIRA UM BLOCO NORMAL (DE COR ALEATORIA) NO LUGAR DELE. NAO DA PONTOS
virar_bloco = function()
{
	criar_bloco_solto(x, y, irandom(cores.total - 1));
	var _anel = instance_create_depth(x, y, -1900, obj_efeito_pontos);
	_anel.modo = "anel";
	_anel.timer = 14;
	som_tocar(snd_peca_encaixar, .1);
	instance_destroy();
}

//GRAVIDADE DEPOIS QUE JA PISOU (O CHAO PODE SUMIR OU ELE PODE SAIR DA BEIRADA)
gravidade = function()
{
	if(solido(x, y + 1))
	{
		velv = 0;
		exit;
	}
	velv = min(velv + INIMIGO_GRAV, INIMIGO_QUEDA_MAX);
	if(mover_y(velv))
	{
		esc_x = 1.2;
		esc_y = .8;
	}
}

//BATEU NO CHAO NA QUEDA: AMASSADINHO, SOM E COMEÇA A CRIAR AS PERNAS (JA VIRADO PRO PLAYER)
pousar = function()
{
	estado = "brotando";
	timer = 0;
	esc_x = 1.35;
	esc_y = .65;
	som_tocar(snd_fall_chao, .1);
	var _pp = player_perto(x, y);
	if(_pp != noone) dir = _pp.x < x ? -1 : 1;
}

//BOMBA: EXPLODE. DESTROI OS BLOCOS EM VOLTA (TIRANDO OS PONTOS DELES), MATA OS INIMIGOS PERTO (OUTRA BOMBA
//EXPLODE LOGO DEPOIS: REAÇAO EM CADEIA) E DA DANO NO PLAYER PERTO
explodir = function()
{
	if(!vivo()) exit;
	estado = "explodiu";
	var _ex = x, _ey = y;
	//BLOCOS EM VOLTA (O DESTROY DA PEÇA TIRA OS PONTOS DE QUEM FOI DESTRUIDO PELA "BOMBA")
	with(obj_peca) if(destruido_por == noone and point_distance(x, y, _ex, _ey) < BOMBA_RAIO)
	{
		destruido_por = "bomba";
		instance_destroy();
	}
	//INIMIGOS PERTO
	with(obj_inimigo) if(id != other.id and vivo() and point_distance(x, y, _ex, _ey) < BOMBA_RAIO)
	{
		if(bomba) bomba_timer = min(bomba_timer, 8);
		else morrer_nocaute(x < _ex ? -1 : 1, false);
	}
	//PLAYER PERTO: DANO (E EMPURRA PRA LONGE DA BOMBA)
	with(obj_player) if(estado != state.morte and point_distance(x, y - 10, _ex, _ey) < BOMBA_DANO_RAIO) levar_dano(x < _ex ? -1 : 1);
	//EFEITO: EXPLOSAO GRANDE, ONDA DE CHOQUE, TREMIDA, HITSTOP E SOM
	var _e = instance_create_depth(_ex, _ey, -1950, obj_efeito_animacao);
	_e.sprite_index = spr_explosao_bomb;
	_e.image_speed = 1.2;
	_e.image_xscale = 3;
	_e.image_yscale = 3;
	onda_choque(_ex, _ey, 90, 7, 30);
	hitstop(5);
	shakes(14, 3);
	som_tocar(snd_explosao, .05);
	audio_play_sound(snd_hit2, 1, false, .8, 0, .6);
	instance_destroy();
}

//PONTOS E MOEDAS DE QUANDO MORRE
dar_pontos = function(_pontos)
{
	pontos_somar(_pontos * global.level, x, y - 14, c_yellow, 1);
	moeda_criar(x, y - 8, MOEDAS_INIMIGO);
}

//PISAO: ACHATA, FICA UM TEMPINHO NO CHAO E SOME
morrer_amassado = function()
{
	estado = "amassado";
	timer = 0;
	pernas = 0;
	esc_x = 1.4;
	esc_y = .45;
	alpha_fog = 1;
	dar_pontos(PONTOS_INIMIGO);
	emocao_mostrar(1, 40);
	onda_choque(x, y, 45, 4, 20);
	hitstop(4);
	audio_play_sound(snd_hit2, 1, false, 1, 0, 1.3);
	shakes(6, 2);
}

//GIRO, SOCO OU PEÇA: VIRA DE PONTA CABEÇA, DA UM PULINHO E CAI PRA FORA DA TELA (SEM COLISAO)
morrer_nocaute = function(_dir, _pelo_player)
{
	estado = "nocaute";
	velh = 1.3 * _dir;
	velv = -3.5;
	alpha_fog = 0;
	dar_pontos(_pelo_player ? PONTOS_INIMIGO : PONTOS_INIMIGO_PECA);
	if(_pelo_player)
	{
		emocao_mostrar(1, 40);
		onda_choque(x, y, 45, 4, 20);
		hitstop(4);
	}
	else som_tocar(snd_peca_destroy, .1);
	var _anel = instance_create_depth(x, y, -1900, obj_efeito_pontos);
	_anel.modo = "anel";
	_anel.timer = 14;
	shakes(6, 2);
}

//ENCOSTOU NO PLAYER
checar_player = function()
{
	var _topo = bbox_top - pernas; //O CORPO SOBE COM AS PERNAS
	var _p = collision_rectangle(bbox_left, _topo - 1, bbox_right, bbox_bottom, obj_player, false, true);
	if(_p == noone) exit;
	if(_p.estado == state.morte) exit;

	//GIRO MATA (NO AR ELE QUICA, IGUAL QUANDO QUEBRA UM BLOCO)
	if(_p.estado == state.giro)
	{
		if(_p.giro_ar)
		{
			_p.quique_seq++;
			_p.quicar();
		}
		audio_play_sound(snd_hit2, 1, false, 1, 0, 1.1);
		morrer_nocaute(_p.x < x ? 1 : -1, true);
		exit;
	}

	//PISAO: OS PES DO PLAYER ESTAO NO TOPO DO INIMIGO (CAINDO OU PARADO EM CIMA)
	if(_p.velv >= 0 and _p.bbox_bottom <= _topo + 3 + _p.velv)
	{
		_p.quicar();
		morrer_amassado();
		exit;
	}

	//CABEÇUDO: DANO NORMAL, MAS SE TIVER PAREDE/BLOCO ATRAS DO PLAYER ELE E JOGADO PRO LADO OPOSTO (POR CIMA DO CABEÇUDO)
	if(cabecudo)
	{
		var _lado = _p.x < x ? -1 : 1;
		var _parede = false;
		with(_p) _parede = place_meeting(x + _lado * CEL, y - 2, obj_block) or place_meeting(x + _lado * CEL, y - 2, obj_peca);
		if(_parede) _lado = -_lado;
		var _levou = _p.imune <= 0;
		_p.levar_dano(_lado);
		if(_parede and _levou and _p.estado == state.dano) with(_p) { velh = CABECUDO_JOGA_H * _lado; velv = -CABECUDO_JOGA_V; }
		exit;
	}

	//ENCOSTOU DE LADO OU POR BAIXO: TIRA UMA VIDA (SE O PLAYER NAO TIVER IMUNE)
	_p.levar_dano(_p.x < x ? -1 : 1);
}

//CABEÇUDO ANDANDO: VAI PRA FRENTE E, QUANDO BATE EM ALGO, DA UMA CABEÇADA:
//	BLOCO: EMPURRA ELE UMA CASA (SE ELE NAO TIVER PRA ONDE IR, QUEBRA) E DEPOIS CONTINUA ANDANDO
//	PAREDE OU CHAO SOLIDO: CONTA A CABEÇADA. NA CABECUDO_BATIDAS ELE MORRE
//	OUTRO INIMIGO: DA MEIA-VOLTA (IGUAL AO INIMIGO)
cabecudo_andar = function()
{
	if(cab_espera > 0)
	{
		cab_espera--;
		exit;
	}
if(!mover_x(dir * CABECUDO_VEL) or velv != 0) exit; //(NO AR NAO DA CABEÇADA)
	cab_bump = 1;
	esc_x = 1.15;
	esc_y = .9;
	var _b = instance_place(x + dir, y, obj_peca);
	if(_b != noone)
	{
		with(_b) velocidade_h(other.dir);
		if(instance_exists(_b) and _b.prox_x == _b.x)
		{
			_b.destruido_por = "cabecudo";
			instance_destroy(_b);
		}
		cab_espera = CABECUDO_PASSO;
		cab_batidas = 0;
		audio_play_sound(snd_hit, 1, false, .8, 0, .9 + random(.2));
		shakes(2, 1);
	}
	else if(place_meeting(x + dir, y, obj_block))
	{
		cab_batidas++;
		cab_espera = CABECUDO_BATIDA;
		audio_play_sound(snd_hit, 1, false, .8, 0, .8 + cab_batidas * .1);
		shakes(3, 1.5);
		if(cab_batidas >= CABECUDO_BATIDAS) cabecudo_morrer();
	}
	else dir *= -1;
}

//CABEÇUDO MORREU DE TANTO BATER NA PAREDE: CAI PRA TRAS DE PONTA CABEÇA (IGUAL AO NOCAUTE, SEM DAR PONTOS)
cabecudo_morrer = function()
{
	estado = "nocaute";
	velh = -dir * 1.3;
	velv = -3.5;
	alpha_fog = 1;
	audio_play_sound(snd_hit2, 1, false, 1, 0, .7);
	var _anel = instance_create_depth(x, y, -1900, obj_efeito_pontos);
	_anel.modo = "anel";
	_anel.timer = 14;
	shakes(6, 2);
}

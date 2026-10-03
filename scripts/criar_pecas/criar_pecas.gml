//TIPOS E CORES DAS PEÇAS
enum tipo_peca
{
	F,		//BLOCO SOZINHO (O INIMIGO E O BLOCO QUE ELE VIRA QUANDO FICA PRESO)
	O,
	I1,		//VERTICAL
	I2,		//HORIZONTAL
	J1, J2, J3, J4,
	S1, S2,
	Z1, Z2,
	T1, T2, T3, T4,
	total
}

//CORES DAS PEÇAS (FRAME DA SPR_PECA)
enum cores
{
	c_green,
	c_yellow,
	c_purple,
	c_aqua,
	c_red,
	total
}

//ONDE AS PEÇAS NASCEM (OBJ_AREA.COLUNAS_SORTEADAS): PESO DE CADA POSIÇAO NO SORTEIO (O MEIO DA ARENA VALE 1)
#macro PECA_LATERAL_PESO		.7		//PEÇA ENCOSTADA NUMA PAREDE
#macro PECA_LATERAL_REPETE		.15		//ENCOSTADA NA MESMA PAREDE QUE A ULTIMA (QUASE NUNCA DUAS SEGUIDAS)

//SORTEIA A PROXIMA PEÇA
//GLOBAL.PROX_ESPECIE:	 "NORMAL" (PEÇA COMUM), "INIMIGO" (OBJ_INIMIGO), "BOMBA" (OBJ_INIMIGO QUE EXPLODE),
//						 "CABECUDO" (OBJ_INIMIGO COM CHIFRES QUE DA CABEÇADA NOS BLOCOS),
//						 "GELATINA" OU "BURACO" (BLOCO SOZINHO DESSE TIPO)
//GLOBAL.PROX_FANTASMAS: QUANTOS BLOCOS DA PEÇA SAO FANTASMA (0 NENHUM, 1, 2 GRUDADOS OU 4 = A PEÇA INTEIRA)
//GLOBAL.PROX_GELO:		 A PEÇA INTEIRA VEM DE GELO
//AS CHANCES FICAM NO SCR_PONTOS (DIFICULDADE). ESSES TIPOS SO APARECEM NO ARCADE, CADA UM DEPOIS DO SEU TEMPO (BLOCO_LIBERADO)
function peca_sortear_proxima()
{
	//PEÇA NORMAL DE TIPO E COR ALEATORIOS
	global.prox_tipo = irandom_range(tipo_peca.O, tipo_peca.total - 1);
	global.prox_cor	 = irandom(cores.total - 1);
	global.prox_especie = "normal";
	global.prox_fantasmas = 0;
	global.prox_gelo = false;
	//FORA DO ARCADE NAO TEM NADA DISSO
	if(!modo_arcade()) exit;

	//PODE VIR UM INIMIGO (SE NAO TIVER INIMIGOS DEMAIS NA ARENA). A BOMBA SO DEPOIS DO TEMPO DELA
	if(bloco_liberado(LIBERA_INIMIGO) and random(100) < chance_inimigo() and instance_number(obj_inimigo) < INIMIGO_MAX)
	{
		global.prox_especie = (bloco_liberado(LIBERA_BOMBA) and random(100) < BOMBA_CHANCE) ? "bomba" : "inimigo"; //PARTE DOS INIMIGOS SAO BOMBAS
		global.prox_tipo = tipo_peca.F;
	}
	//BURACO (BLOCO SOZINHO)
	else if(bloco_liberado(LIBERA_BURACO) and random(100) < BURACO_CHANCE and blocos_contar("sou_buraco") < BURACO_MAX)
	{
		global.prox_especie = "buraco";
		global.prox_tipo = tipo_peca.F;
	}
	//CABEÇUDO (O INIMIGO COM CHIFRES)
	else if(bloco_liberado(LIBERA_CABECUDO) and random(100) < CABECUDO_CHANCE and cabecudos_contar() < CABECUDO_MAX)
	{
		global.prox_especie = "cabecudo";
		global.prox_tipo = tipo_peca.F;
	}
	//GELATINA (BLOCO SOZINHO)
	else if(bloco_liberado(LIBERA_GELATINA) and random(100) < GELATINA_CHANCE and blocos_contar("sou_gelatina") < GELATINA_MAX)
	{
		global.prox_especie = "gelatina";
		global.prox_tipo = tipo_peca.F;
	}
	//SENAO, PODE VIR COM BLOCOS FANTASMA...
	else if(bloco_liberado(LIBERA_FANTASMA) and random(100) < chance_fantasma()) global.prox_fantasmas = choose(1, 1, 2, 2, 4);
	//...OU A PEÇA INTEIRA DE GELO
	else if(bloco_liberado(LIBERA_GELO) and random(100) < GELO_CHANCE) global.prox_gelo = true;
}

//POSIÇAO DOS 3 BLOCOS FILHOS EM RELAÇAO AO PAI (EM CELULAS)
function peca_formato(_tipo)
{
	switch(_tipo)
	{
		case tipo_peca.O:	return [[ 1, 0, 1], [ 0,-1,-1]];
		case tipo_peca.I1:	return [[ 0, 0, 0], [-1,-2,-3]];
		case tipo_peca.I2:	return [[-1, 1, 2], [ 0, 0, 0]];
		case tipo_peca.J1:	return [[ 0, 0,-1], [-1,-2, 0]];
		case tipo_peca.J2:	return [[-1, 1, 1], [ 0, 0,-1]];
		case tipo_peca.J3:	return [[ 1, 0, 0], [ 0,-1,-2]];
		case tipo_peca.J4:	return [[-1,-1, 1], [ 0,-1, 0]];
		case tipo_peca.S1:	return [[-1, 0, 1], [ 0,-1,-1]];
		case tipo_peca.S2:	return [[ 0, 1, 1], [-1, 0, 1]];
		case tipo_peca.Z1:	return [[ 1, 0,-1], [ 0,-1,-1]];
		case tipo_peca.Z2:	return [[ 0, 1, 1], [ 1, 0,-1]];
		case tipo_peca.T1:	return [[-1, 1, 0], [ 0, 0,-1]];
		case tipo_peca.T2:	return [[ 0, 0, 1], [-1, 1, 0]];
		case tipo_peca.T3:	return [[-1, 1, 0], [ 0, 0, 1]];
		case tipo_peca.T4:	return [[ 0, 0,-1], [-1, 1, 0]];
	}
	return [[], []]; //F: BLOCO SOZINHO
}

//ARENA MAIS PERTO DE UM PONTO (O CRIADOR NASCE ACIMA DA ARENA, FORA DELA)
function area_mais_perto(_x, _y)
{
	var _melhor = noone;
	var _dist = infinity;
	var _objs = [obj_area, obj_area_versus, obj_area_coop];
	for(var i = 0; i < array_length(_objs); i++)
	{
		var _a = instance_nearest(_x, _y, _objs[i]);
		if(_a != noone)
		{
			var _d = abs(_x - (_a.x + _a.sprite_width/2));
			if(_d < _dist) { _dist = _d; _melhor = _a; }
		}
	}
	return _melhor;
}

//CRIA A PEÇA NA POSIÇAO DO CRIADOR (CHAMADO PELO OBJ_CRIA_PECA, QUE SE DESTROI DEPOIS)
//_FANTASMAS = QUANTOS BLOCOS DA PEÇA SAO FANTASMA (O PLAYER PASSA POR DENTRO, SO O GIRO QUEBRA)
function criar_pecas(_tipo, _cor, _fantasmas = 0)
{
	//FORMATO DA PEÇA: POSIÇOES DOS FILHOS E QUANTOS SAO (SEM FILHOS = BLOCO SOZINHO)
	var _formato = peca_formato(_tipo);
	var _ox = _formato[0];
	var _oy = _formato[1];
	var _qtd = array_length(_ox);
	var _irmandade = _qtd > 0;

	//A I EM PE NASCE UMA CASA MAIS BAIXO
	if(_tipo == tipo_peca.I1) y += CEL;

	//EMPURRANDO PRA DENTRO DA ARENA SE ALGUM BLOCO FICAR PRA FORA DAS COLUNAS
	var _area = area_mais_perto(x, y);
	if(_area != noone)
	{
		var _col = (x - _area.x) div CEL;
		var _min = 0, _max = 0;
		for(var i = 0; i < _qtd; i++)
		{
			_min = min(_min, _ox[i]);
			_max = max(_max, _ox[i]);
		}
		if(_col + _min < 0)				x += CEL * -(_col + _min);
		if(_col + _max > _area.cols - 1)	x -= CEL * (_col + _max - (_area.cols - 1));
	}

	//CRIA O BLOCO PAI
	var _pai = instance_create_layer(x, y, "Blocos", obj_peca);
	with(_pai)
	{
		sou_pai		= true;
		pai			= id;
		coloracao	= _cor;
		tipo		= _tipo;
		irmandade	= _irmandade;
	}

	//COLOCANDO NA FILA DO TELEPORTE
	fila_adicionar(_pai);

	//CRIA OS FILHOS EM VOLTA DO PAI
	var _filhos = [];
	for(var i = 0; i < _qtd; i++)
	{
		var _peca = instance_create_layer(x + _ox[i] * CEL, y + _oy[i] * CEL, "Blocos", obj_peca);
		_peca.pai		= _pai.id;
		_peca.coloracao	= _cor;
		_peca.irmandade	= _irmandade;
		array_push(_filhos, _peca.id);
	}

	//ADICIONANDO OS FILHOS AO PAI
	array_push(_filhos, _pai.id);
	_pai.meus_filhos = _filhos;
	if(_fantasmas > 0) peca_colocar_fantasmas(_filhos, _fantasmas);
	//O CRIADOR SOME (E DEVOLVE O PAI PRA QUEM CHAMOU)
	instance_destroy();
	return _pai;
}

//A PEÇA INTEIRA VIRA GELO (O GELO NAO TEM COR E NENHUM BLOCO DELA SORTEIA OUTRO TIPO)
function peca_colocar_gelo(_blocos)
{
	for(var i = 0; i < array_length(_blocos); i++)
	{
		with(_blocos[i])
		{
			alarm[1] = -1;
			sou_gelo = true;
			sou_normal = false;
			cor_original = coloracao;
			coloracao = -1;
		}
	}
}

//O BLOCO SOZINHO VIRA GELATINA OU BURACO (_TIPO = "gelatina" OU "buraco"). SEM COR E SEM SORTEAR OUTRO TIPO
function bloco_virar_sozinho(_bloco, _tipo)
{
	with(_bloco)
	{
		alarm[1] = -1;
		sou_normal = false;
		sou_gelatina = _tipo == "gelatina";
		sou_buraco = _tipo == "buraco";
		cor_original = coloracao;
		coloracao = -1;
	}
}

//TRANSFORMA _QTD BLOCOS DA PEÇA EM FANTASMA, SEMPRE GRUDADOS UM NO OUTRO (4 = A PEÇA INTEIRA)
//O FANTASMA NAO TEM COR (NUNCA ENTRA NO GRUPO DO ESPECIAL NEM NA LINHA DE UMA COR SO).
//PEÇA COM FANTASMA NAO VIRA RAIVOSA/LASER/ESPECIAL (A RAIVOSA RESETA OS BLOCOS DO GRUPO TODO)
function peca_colocar_fantasmas(_blocos, _qtd)
{
	//COMEÇA COM UM BLOCO ALEATORIO E VAI ADICIONANDO VIZINHOS
	var _escolhidos = [_blocos[irandom(array_length(_blocos) - 1)]];
	while(array_length(_escolhidos) < min(_qtd, array_length(_blocos)))
	{
		//BLOCOS GRUDADOS (DO LADO, EM CIMA OU EMBAIXO) NOS QUE JA SAO FANTASMA
		var _vizinhos = [];
		for(var i = 0; i < array_length(_blocos); i++)
		{
			var _b = _blocos[i];
			if(array_contains(_escolhidos, _b)) continue;
			for(var j = 0; j < array_length(_escolhidos); j++)
			{
				if(abs(_b.x - _escolhidos[j].x) + abs(_b.y - _escolhidos[j].y) == CEL)
				{
					array_push(_vizinhos, _b);
					break;
				}
			}
		}
		if(array_length(_vizinhos) == 0) break;
		array_push(_escolhidos, _vizinhos[irandom(array_length(_vizinhos) - 1)]);
	}
	
	//MARCA OS ESCOLHIDOS COMO FANTASMA. NENHUM BLOCO DA PEÇA SORTEIA TIPO ESPECIAL
	for(var i = 0; i < array_length(_blocos); i++)
	{
		with(_blocos[i])
		{
			alarm[1] = -1;
			if(array_contains(_escolhidos, id))
			{
				sou_fantasma = true;
				sou_normal	 = false;
				coloracao	 = -1;
			}
		}
	}
}

//BLOCO NORMAL SOZINHO, FORA DA FILA DO TELEPORTE (O INIMIGO PRESO ENTRE 2 BLOCOS VIRA UM DESSES)
function criar_bloco_solto(_x, _y, _cor)
{
	var _b = instance_create_layer(grid_alinhar_x(_x), grid_alinhar_y(_y), "Blocos", obj_peca);
	with(_b)
	{
		sou_pai		= true;
		pai			= id;
		coloracao	= _cor;
		tipo		= tipo_peca.F;
		irmandade	= false;
		meus_filhos	= [id];
		alarm[1]	= -1; //NAO VIRA LASER/RAIVOSO/ESPECIAL
	}
	return _b;
}

//==================== MENU DE DEBUG DOS BLOCOS (ENTER NO ARCADE) ====================
//TODOS OS BLOCOS QUE O MENU MOSTRA (NA ORDEM EM QUE SAO LIBERADOS NA PARTIDA)
function debug_lista_blocos()
{
	return ["Normal", "Raio", "Especial", "Raivoso", "Pedra", "Gelo", "Fujao", "Colmeia", "Fantasma", "Inimigo",
		"Cabecudo", "Laser", "LaserLado", "Sniper", "Bomba", "Lento", "Gelatina", "Buraco"];
}

//ESCOLHEU NO MENU: A PROXIMA PEÇA VIRA ESSE BLOCO (OS QUE SAO "ESPECIE" JA MUDAM AQUI; OS TIPOS DE BLOCO
//SAO COLOCADOS QUANDO A PEÇA NASCE, NO DEBUG_APLICAR)
function debug_preparar(_nome)
{
	global.debug_bloco = _nome;
	global.prox_tipo = irandom_range(tipo_peca.O, tipo_peca.total - 1);
	global.prox_cor = irandom(cores.total - 1);
	global.prox_especie = "normal";
	global.prox_fantasmas = 0;
	global.prox_gelo = false;
	switch(_nome)
	{
		case "Inimigo":		global.prox_especie = "inimigo";	global.prox_tipo = tipo_peca.F; break;
		case "Bomba":		global.prox_especie = "bomba";		global.prox_tipo = tipo_peca.F; break;
		case "Cabecudo":	global.prox_especie = "cabecudo";	global.prox_tipo = tipo_peca.F; break;
		case "Gelatina":	global.prox_especie = "gelatina";	global.prox_tipo = tipo_peca.F; break;
		case "Buraco":		global.prox_especie = "buraco";		global.prox_tipo = tipo_peca.F; break;
		case "Fantasma":	global.prox_fantasmas = choose(1, 2, 4); break;
		case "Gelo":		global.prox_gelo = true; break;
	}
}

//A PEÇA ESCOLHIDA NASCEU: NENHUM BLOCO DELA SORTEIA OUTRO TIPO E O BLOCO PAI VIRA O TIPO ESCOLHIDO
//(A RAIVOSA E A PEÇA INTEIRA). SEM CHANCE E SEM LIMITE NA ARENA: E PRA TESTAR
function debug_aplicar(_pai)
{
	var _nome = global.debug_bloco;
	global.debug_bloco = "";
	if(!instance_exists(_pai)) exit;
	var _blocos = _pai.meus_filhos;
	for(var i = 0; i < array_length(_blocos); i++) if(instance_exists(_blocos[i])) _blocos[i].alarm[1] = -1;
	with(_pai)
	{
		switch(_nome)
		{
			case "Raio":		sou_normal = false; sou_raio = true; break;
			case "Fujao":		sou_normal = false; sou_fujao = true; break;
			case "Laser":		sou_normal = false; sou_laser = true; break;
			case "LaserLado":	sou_normal = false; sou_laser = true; laser_lado = true; break;
			case "Sniper":		sou_normal = false; sou_sensor = true; break;
			case "Lento":		sou_normal = false; sou_lento = true; break;
			case "Especial":
				sou_normal = false;
				sou_especial = true;
				premio_especial = especial_sortear();
				global.bloco_especial = id;
				break;
			case "Pedra":
				sou_normal = false;
				sou_pedra = true;
				vida_pedra = 2;
				cor_original = coloracao;
				coloracao = -1;
				break;
			case "Colmeia":
				sou_normal = false;
				sou_colmeia = true;
				colmeia_timer = COLMEIA_PRIMEIRA;
				cor_original = coloracao;
				coloracao = -1;
				break;
			case "Raivoso":
				for(var i = 0; i < array_length(_blocos); i++)
				{
					with(_blocos[i])
					{
						restar_variaveis_blocos();
						cair_direto = true;
						sou_raivoso = true;
						sou_normal = false;
					}
				}
				break;
		}
	}
}

//==================== CATALOGO DOS BLOCOS (TABELA DO MENU E AVISO DE BLOCO NOVO) ====================
//CADA BLOCO: ID, NOME [PT, EN], O QUE FAZ [PT, EN] E O MINUTO EM QUE ELE COMEÇA A APARECER NA PARTIDA
function blocos_catalogo()
{
	return [
		{ id : "normal",	min : 0,				nome : ["NORMAL", "NORMAL"],		desc : ["BLOCO COMUM. COMPLETE UMA LINHA INTEIRA PRA DESTRUIR. A PEÇA INTEIRA NA MESMA LINHA DÁ BÔNUS.", "REGULAR BLOCK. FILL A WHOLE ROW TO CLEAR IT. A WHOLE PIECE IN THE SAME ROW GIVES A BONUS."] },
		{ id : "raio",		min : LIBERA_RAIO,		nome : ["RAIO", "LIGHTNING"],		desc : ["DESTRUÍDO, CAI UM RAIO: TUDO FICA AZUL E OS PONTOS DOBRAM POR UM TEMPO.", "WHEN DESTROYED, LIGHTNING STRIKES: EVERYTHING TURNS BLUE AND POINTS DOUBLE FOR A WHILE."] },
		{ id : "especial",	min : LIBERA_ESPECIAL,	nome : ["ESPECIAL", "SPECIAL"],		desc : ["GUARDA UM PRÊMIO SURPRESA: PODE SER BOM OU RUIM PRO JOGADOR.", "HOLDS A SURPRISE PRIZE: IT CAN BE GOOD OR BAD FOR THE PLAYER."] },
		{ id : "raivoso",	min : LIBERA_RAIVOSO,	nome : ["RAIVOSO", "ANGRY"],		desc : ["A PEÇA INTEIRA CAI DIRETO, SEM PARAR, E NÃO PODE SER TELEPORTADA NEM EMPURRADA.", "THE WHOLE PIECE DROPS STRAIGHT DOWN WITHOUT STOPPING AND CAN'T BE TELEPORTED OR PUSHED."] },
		{ id : "pedra",		min : LIBERA_PEDRA,		nome : ["PEDRA", "STONE"],			desc : ["DURO: PRECISA DE DOIS GOLPES PRA QUEBRAR. NÃO TEM COR.", "TOUGH: TAKES TWO HITS TO BREAK. HAS NO COLOR."] },
		{ id : "gelo",		min : LIBERA_GELO,		nome : ["GELO", "ICE"],				desc : ["PEÇA INTEIRA DE GELO. ESCORREGA: O PLAYER DESLIZA EM CIMA E NÃO CONSEGUE ESCALAR A PAREDE DE GELO.", "A WHOLE ICE PIECE. SLIPPERY: YOU SLIDE ON TOP AND CAN'T CLIMB AN ICE WALL."] },
		{ id : "fujao",		min : LIBERA_FUJAO,		nome : ["FUJÃO", "RUNAWAY"],		desc : ["TEM UMA MOEDA DENTRO E FOGE PELA GRADE QUANDO O PLAYER CHEGA PERTO.", "HAS A COIN INSIDE AND RUNS AWAY THROUGH THE GRID WHEN YOU GET CLOSE."] },
		{ id : "colmeia",	min : LIBERA_COLMEIA,	nome : ["COLMEIA", "BEEHIVE"],		desc : ["SOLTA ABELHAS QUE DESTROEM O BLOCO MAIS PERTO. ELAS NÃO MACHUCAM E NÃO MORREM: QUEBRE A COLMEIA PRA PARAR.", "RELEASES BEES THAT DESTROY THE NEAREST BLOCK. THEY DON'T HURT AND CAN'T DIE: BREAK THE HIVE TO STOP THEM."] },
		{ id : "laser",		min : LIBERA_LASER,		nome : ["LASER", "LASER"],			desc : ["CARREGA E ATIRA UM LASER NA DIREÇÃO DO PLAYER.", "CHARGES UP AND SHOOTS A LASER AT THE PLAYER."] },
		{ id : "laser_lado",min : LIBERA_LASER,		nome : ["LASER LATERAL", "SIDE LASER"],	desc : ["ATIRA RETO PRO LADO MAIS ABERTO DA ARENA: QUEBRA O PRIMEIRO BLOCO QUE ACERTAR OU MACHUCA O PLAYER.", "SHOOTS STRAIGHT TOWARD THE OPEN SIDE OF THE ARENA: BREAKS THE FIRST BLOCK IT HITS OR HURTS THE PLAYER."] },
		{ id : "sniper",	min : LIBERA_SNIPER,	nome : ["SNIPER", "SNIPER"],		desc : ["PARECE UM BLOCO NORMAL, MAS QUANDO O PLAYER PASSA NA LINHA DELE ELE SE LANÇA, QUEBRANDO TUDO NO CAMINHO.", "LOOKS LIKE A REGULAR BLOCK, BUT WHEN YOU CROSS ITS ROW IT LAUNCHES, BREAKING EVERYTHING IN ITS WAY."] },
		{ id : "bomba",		min : LIBERA_BOMBA,		nome : ["BOMBA", "BOMB"],			desc : ["INIMIGO QUE EXPLODE E MACHUCA QUEM ESTIVER PERTO.", "AN ENEMY THAT EXPLODES AND HURTS ANYONE NEARBY."] },
		{ id : "fantasma",	min : LIBERA_FANTASMA,	nome : ["FANTASMA", "GHOST"],		desc : ["TRANSPARENTE: O PLAYER ATRAVESSA. SÓ O SOCO ESPIRITUAL ACERTA.", "TRANSPARENT: YOU PASS THROUGH IT. ONLY THE SPIRIT PUNCH HITS IT."] },
		{ id : "inimigo",	min : LIBERA_INIMIGO,	nome : ["INIMIGO", "ENEMY"],		desc : ["ANDA PELA ARENA E MACHUCA SE ENCOSTAR. PULE EM CIMA OU GIRE PRA DERROTAR.", "WALKS AROUND AND HURTS ON TOUCH. STOMP IT OR SPIN TO DEFEAT IT."] },
		{ id : "cabecudo",	min : LIBERA_CABECUDO,	nome : ["CABEÇUDO", "HEADBUTTER"],	desc : ["ANDA DANDO CABEÇADAS: EMPURRA OU QUEBRA OS BLOCOS DA FRENTE. MACHUCA SE ENCOSTAR.", "WALKS HEADBUTTING: PUSHES OR BREAKS BLOCKS AHEAD. HURTS ON TOUCH."] },
		{ id : "lento",		min : LIBERA_LENTO,		nome : ["LENTO", "SLOW"],			desc : ["QUEBRADO POR VOCÊ: TE DEIXA RÁPIDO! DESTRUÍDO DE OUTRO JEITO: TE DEIXA LENTO.", "BROKEN BY YOU: MAKES YOU FAST! DESTROYED ANY OTHER WAY: MAKES YOU SLOW."] },
		{ id : "gelatina",	min : LIBERA_GELATINA,	nome : ["GELATINA", "JELLY"],		desc : ["TRAMPOLIM: PULA ALTO EM CIMA E EMPURRA DO LADO. O BLOCO QUE CAI NELA FICA QUICANDO.", "TRAMPOLINE: BOUNCE HIGH ON TOP, GET PUSHED ON THE SIDE. BLOCKS THAT LAND ON IT KEEP BOUNCING."] },
		{ id : "buraco",	min : LIBERA_BURACO,	nome : ["BURACO", "HOLE"],			desc : ["ENGOLE O BLOCO QUE CAI NELE E SOLTA ELE PEGANDO FOGO LÁ DO ALTO, EM CIMA DE VOCÊ.", "SWALLOWS THE BLOCK THAT LANDS ON IT AND DROPS IT ON FIRE FROM ABOVE, RIGHT ON YOU."] },
	];
}

//DADOS DE UM BLOCO DO CATALOGO PELO ID (UNDEFINED SE NAO EXISTIR)
function bloco_info(_id)
{
	var _c = blocos_catalogo();
	for(var i = 0; i < array_length(_c); i++) if(_c[i].id == _id) return _c[i];
	return undefined;
}

//JA VIU ESSE BLOCO ALGUMA VEZ? (O NORMAL SEMPRE)
function bloco_visto(_id)
{
	if(_id == "normal") return true;
	return variable_global_exists("blocos_vistos") and variable_struct_exists(global.blocos_vistos, _id) and global.blocos_vistos[$ _id];
}

//DESENHA O BLOCO (ICONE) NO TAMANHO _ESC. _SILHUETA: SO A SOMBRA (AINDA NAO DESCOBERTO)
function bloco_icone_desenhar(_id, _x, _y, _esc, _silhueta = false, _a = 1)
{
	var _spr = spr_peca, _img = 0, _al = _a;
	switch(_id)
	{
		case "raio":		_img = cores.c_aqua; break;
		case "especial":	_img = 7; break;
		case "raivoso":		_img = 5; break;
		case "pedra":		_spr = spr_bloco_pedra; break;
		case "gelo":		_spr = spr_bloco_gelo; break;
		case "fujao":		_img = cores.c_yellow; break;
		case "colmeia":		_spr = spr_bloco_colmeia; break;
		case "laser":		_spr = spr_peca_laser; _img = 3; break;
		case "laser_lado":	_spr = spr_peca_laser; _img = 3; break;
		case "sniper":		_img = cores.c_red; break;
		case "bomba":		_spr = spr_inimigo_bomba; break;
		case "fantasma":	_img = 6; _al = _a * .6; break;
		case "inimigo":		_spr = spr_inimigo; break;
		case "cabecudo":	_spr = spr_bloco_cabecudo; break;
		case "lento":		_img = cores.c_purple; break;
		case "gelatina":	_spr = spr_bloco_gelatina; _al = _a * .85; break;
		case "buraco":		_spr = spr_bloco_buraco; _img = current_time / 120; break;
	}
	if(_silhueta)
	{
		gpu_set_fog(true, #2A2944, 0, 1);
		draw_sprite_ext(_spr, _img, _x, _y, _esc, _esc, 0, c_white, _a);
		gpu_set_fog(false, c_white, 0, 1);
		return;
	}
	draw_sprite_ext(_spr, _img, _x, _y, _esc, _esc, 0, c_white, _al);
	//OS DETALHES DE CADA UM (RAIO, MOEDA, ESPIRAL, SETA, MIRA)
	switch(_id)
	{
		case "raio":	draw_sprite_ext(spr_bloco_eletrico, current_time / 90, _x, _y, _esc, _esc, 0, c_white, _a); break;
		case "fujao":	draw_sprite_ext(spr_moeda, current_time / 100, _x, _y, .6 * _esc, .6 * _esc, 0, c_white, _a); break;
		case "lento":	draw_sprite_ext(spr_icone_lento, 0, _x, _y, .85 * _esc, .85 * _esc, -current_time / 6, c_white, _a); break;
		case "laser_lado":
			draw_set_color(#FF9A3C);
			draw_set_alpha(_a);
			draw_triangle(_x + 5 * _esc, _y - 3 * _esc, _x + 5 * _esc, _y + 3 * _esc, _x + 9 * _esc, _y, false);
			draw_set_alpha(1);
			draw_set_color(c_white);
			break;
		case "sniper":
			draw_set_color(c_white);
			draw_set_alpha(.8 * _a);
			draw_circle(_x, _y, 4 * _esc, true);
			draw_line(_x - 6 * _esc, _y, _x + 6 * _esc, _y);
			draw_line(_x, _y - 6 * _esc, _x, _y + 6 * _esc);
			draw_set_alpha(1);
			break;
	}
}

//O TIPO DE UM BLOCO DA ARENA (O ID DO CATALOGO). O SNIPER SO CONTA DEPOIS DE SE REVELAR
function bloco_tipo_id(_b)
{
	with(_b)
	{
		if(sou_raio) return "raio";
		if(sou_especial) return "especial";
		if(sou_raivoso) return "raivoso";
		if(sou_pedra) return "pedra";
		if(sou_gelo) return "gelo";
		if(sou_fujao) return "fujao";
		if(sou_colmeia) return "colmeia";
		if(sou_laser) return laser_lado ? "laser_lado" : "laser";
		if(sou_fantasma) return "fantasma";
		if(sou_lento) return "lento";
		if(sou_gelatina) return "gelatina";
		if(sou_buraco) return "buraco";
		if(sou_sensor and sensor_timer >= 0) return "sniper";
	}
	return "normal";
}

//MARCA UM BLOCO COMO DESCOBERTO (PRA SEMPRE, NO SAVE) E MOSTRA O AVISO "NOVO BLOCO DESCOBERTO"
function bloco_descobrir(_id)
{
	if(bloco_visto(_id)) exit;
	global.blocos_vistos[$ _id] = true;
	array_push(global.avisos_bloco, _id);
	jogo_salvar();
}

//PROCURA BLOCOS QUE O JOGADOR AINDA NAO TINHA VISTO (CHAMADO PELO OBJ_GAME_CONTROL DE TEMPOS EM TEMPOS)
function blocos_procurar_novos()
{
	with(obj_peca) if(destruido_por == noone and inicializando <= 0) bloco_descobrir(bloco_tipo_id(id));
	with(obj_inimigo) if(vivo()) bloco_descobrir(bomba ? "bomba" : (cabecudo ? "cabecudo" : "inimigo"));
	if(instance_exists(obj_sensor_voando)) bloco_descobrir("sniper");
}
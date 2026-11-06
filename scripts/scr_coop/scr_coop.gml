//MODO COOP==================================
//O COOP E O PROPRIO ARCADE (RM_ARCADE, COM TUDO: PODERES, LETRAS, DESAFIOS, INIMIGOS...) COM DOIS JOGADORES NA
//MESMA ARENA. O MENU LIGA GLOBAL.COOP, A SELEÇAO ESCOLHE OS DOIS PERSONAGENS E O PLAYER 1 CRIA O PLAYER 2.
//	PONTOS, ENERGIA, LETRAS E PODERES SAO DO TIME. CADA JOGADOR TEM AS SUAS VIDAS.
//	MORREU: VOLTA DEPOIS DE COOP_REVIVER NO LUGAR DO PARCEIRO (SE ELE AINDA ESTIVER VIVO).
//	GAME OVER: OS DOIS MORTOS AO MESMO TEMPO (OU A ARENA ENCHEU). O RECORDE DO COOP E SEPARADO DO ARCADE
#macro COOP_REVIVER		(room_speed * 8)	//TEMPO PRA VOLTAR DEPOIS DE MORRER
#macro COOP_COR_P1		#FFE600				//COR DA ETIQUETA "P1"
#macro COOP_COR_P2		#31FCFF				//COR DA ETIQUETA "P2"

//O PLAYER 1 OU 2 (NOONE SE NAO EXISTIR)
function player_n(_n)
{
	var _r = noone;
	with(obj_player) if(jogador == _n and !player_e_fantasma(id)) { _r = id; break; }
	return _r;
}

//PLAYER VIVO MAIS PERTO DO PONTO (NOONE SE NAO TIVER NENHUM VIVO)
function player_perto(_x, _y)
{
	var _r = noone, _d = infinity;
	with(obj_player)
	{
		if(estado == state.morte or player_e_fantasma(id)) continue; //(O FANTASMA DO VERSUS NAO E ALVO DE NADA)
		var _dd = point_distance(_x, _y, x, y);
		if(_dd < _d) { _d = _dd; _r = id; }
	}
	return _r;
}

//TODOS OS PLAYERS ESTAO MORTOS? (SEM PLAYER NA ROOM = NAO)
function todos_mortos()
{
	if(!instance_exists(obj_player)) return false;
	//VERSUS: A RODADA ACABA QUANDO UM DOS DOIS MORRE (O OUTRO GANHA)
	if(room == rm_versus)
	{
		var _alguem = false;
		with(obj_player) if(estado == state.morte) _alguem = true;
		return _alguem;
	}
	var _vivo = false;
	with(obj_player) if(estado != state.morte) _vivo = true;
	return !_vivo;
}

//==================== COOP: TELEPORTE DA PEÇA, UM DE CADA VEZ ====================
//OS DOIS JOGADORES PODEM TELEPORTAR A PEÇA ATUAL, MAS NA VEZ: QUEM TELEPORTOU PASSA A VEZ PRO OUTRO. SE O DONO DA VEZ ESTA MORTO,
//O OUTRO TELEPORTA NO LUGAR DELE. DE QUEM E A VEZ APARECE NA CAIXA DO JOGADOR (PISCA NA COR DELE) E NO BRILHO DA PEÇA ATUAL (A COR DELE)
global.coop_vez			= 1;	//DE QUEM E A VEZ (1 OU 2)
global.coop_vez_aviso	= 0;	//FRAMES ATE PODER AVISAR DE NOVO "NAO E A SUA VEZ"

//==================== COOP: PONTOS DE CADA UM E TOTAL DO TIME ====================
//GLOBAL.PONTOS_1 CONTINUA SENDO O TOTAL DO TIME (RECORDE, FIM DE JOGO...). GLOBAL.COOP_PTS GUARDA QUANTO CADA UM FEZ [P1, P2], E A SOMA DOS DOIS = TOTAL.
//PONTO DE ACAO DE UM PLAYER (QUEBRAR BLOCO, MATAR INIMIGO) VAI PRO PLAYER VIVO MAIS PERTO. PONTO DO TIME (LINHA, IRMANDADE, BONUS) E DIVIDIDO IGUAL.
//DANO TIRA SO DE QUEM LEVOU. COOP_PEND E O QUE AINDA TA VOANDO ATE O HUD (A CAIXA DE CADA UM SO SOBE QUANDO O NUMERO CHEGA, IGUAL AO TOTAL)
global.coop_pts = [0, 0];
global.coop_pend = [0, 0];

//ESTAMOS NO COOP? (O VERSUS TAMBEM USA DOIS PLAYERS, MAS COM PLACAR PROPRIO)
function coop_pontos_ativo()
{
	return global.coop and room != rm_versus;
}

//DE QUEM E UM EVENTO NO PONTO (_X, _Y): 1 OU 2 = O PLAYER VIVO MAIS PERTO, 0 = NINGUEM VIVO (DIVIDE)
function coop_dono(_x, _y)
{
	var _p = player_perto(_x, _y);
	return _p == noone ? 0 : clamp(_p.jogador, 1, 2);
}

//DIVIDE UM VALOR ENTRE OS DOIS: _JOG 1 OU 2 = TUDO PRA ELE, 0 = METADE PRA CADA (O QUE SOBRA DE UM PONTO VAI PRO P2). DEVOLVE [P1, P2]
function coop_dividir(_v, _jog)
{
	if(_jog == 1) return [_v, 0];
	if(_jog == 2) return [0, _v];
	var _a = _v div 2;
	return [_a, _v - _a];
}

//CREDITA PONTOS (_VOA = O NUMERO VAI VOAR ATE O HUD, ENTAO A CAIXA ESPERA ELE CHEGAR)
function coop_creditar(_v, _jog, _voa)
{
	var _d = coop_dividir(_v, _jog);
	for(var i = 0; i < 2; i++)
	{
		global.coop_pts[i] += _d[i];
		if(_voa) global.coop_pend[i] += _d[i];
	}
}

//O NUMERO CHEGOU NO HUD (CHAMADO DEPOIS DE DIMINUIR O PONTOS_PENDENTES)
function coop_chegou(_v, _jog)
{
	var _d = coop_dividir(_v, _jog);
	for(var i = 0; i < 2; i++) global.coop_pend[i] = max(0, global.coop_pend[i] - _d[i]);
	if(global.pontos_pendentes <= 0) global.coop_pend = [0, 0]; //(ACERTA QUALQUER SOBRA DE ARREDONDAMENTO)
}

//COMEÇOU UMA PARTIDA: A VEZ COMEÇA NO PLAYER 1
function coop_vez_reiniciar()
{
	global.coop_vez = 1;
	global.coop_vez_aviso = 0;
}

//DE QUEM E A VEZ DE VERDADE (1 OU 2): SE O DONO DA VEZ ESTA MORTO E O OUTRO VIVO, E DO OUTRO
function coop_vez_de()
{
	var _v = global.coop_vez;
	var _p = player_n(_v), _o = player_n(3 - _v);
	var _dono_morto = _p == noone or _p.estado == state.morte;
	var _outro_vivo = _o != noone and _o.estado != state.morte;
	return (_dono_morto and _outro_vivo) ? 3 - _v : _v;
}

//O JOGADOR _N APERTOU A TECLA DE TELEPORTE. SO TELEPORTA SE FOR A VEZ DELE
function coop_teleporte(_n)
{
	fila_limpar();
	if(!instance_exists(global.peca_inst)) return;
	var _p = player_n(_n);
	if(_p == noone or _p.estado == state.morte) return;
	if(coop_vez_de() != _n)
	{
		//NAO E A VEZ DELE: AVISA NA COR DO OUTRO (SEM FICAR REPETINDO SE ELE MARTELAR A TECLA)
		if(global.coop_vez_aviso <= 0)
		{
			global.coop_vez_aviso = room_speed div 2;
			var _o = string(3 - _n);
			efeito_texto(global.linguagem == 0 ? "VEZ DO P" + _o : "P" + _o + "'S TURN", _p.x, _p.y - 30, _n == 1 ? COOP_COR_P2 : COOP_COR_P1, 1);
			som_tocar(snd_menu_erro_03, .1);
		}
		return;
	}
	teleporte_acionar();
	habil_aprender("teleporte");
	global.coop_vez = 3 - _n;
}

//COR DO BRILHO DA PEÇA ATUAL NO COOP: A COR DE QUEM TEM A VEZ DO TELEPORTE (P1 AMARELO, P2 CIANO)
function coop_vez_cor()
{
	return coop_vez_de() == 1 ? COOP_COR_P1 : COOP_COR_P2;
}

//ALGUM PLAYER VIVO TA SEM A VIDA CHEIA? (O BLOCO ESPECIAL SO SORTEIA +1 VIDA SE TIVER)
function alguem_sem_vida_cheia()
{
	var _r = false;
	with(obj_player) if(estado != state.morte and vida_atual < vida_total) _r = true;
	return _r;
}

//RECORDE DO MODO ATUAL (O COOP TEM O SEU)
function recorde_atual()
{
	if(room == rm_versus) return 0; //O VERSUS NAO TEM RECORDE
	return global.coop ? global.record_coop : global.record_1;
}

//O ARCADE DE VERDADE: O RM_ARCADE (SOLO, OU O COOP ANTIGO NA ARENA ESTREITA) OU O RM_COOP (O COOP NA ARENA LARGA).
//TUDO QUE ERA "SO NO ARCADE" (BLOCOS NOVOS, ONDAS, LASER, LETRAS, PODERES, DESAFIOS...) VALE NOS DOIS
function modo_arcade()
{
	return room == rm_arcade or room == rm_coop or room == rm_versus; //(NO VERSUS O QUE NAO CABE E DESLIGADO POR MODO_VERSUS())
}

//DESENHA A BORDA DO ARCADE (SPR_BORDA) NUMA ARENA _EXTRA PX MAIS LARGA: A METADE ESQUERDA NO LUGAR, O MEIO ESTICADO
//E A METADE DIREITA (COM O PAINEL) EMPURRADA _EXTRA PX PRA DIREITA. _EXTRA = 0 DESENHA NORMAL
function borda_desenhar(_spr, _frame, _x, _y, _extra, _alpha = 1)
{
	if(_extra <= 0) { draw_sprite_ext(_spr, _frame, _x, _y, 1, 1, 0, c_white, _alpha); exit; }
	var _ox = sprite_get_xoffset(_spr), _oy = sprite_get_yoffset(_spr);
	var _w = sprite_get_width(_spr), _h = sprite_get_height(_spr);
	var _corte = _ox + sprite_get_width(spr_area) div 2;	//MEIO DA ARENA NA ARTE (SO TEM O CHAO NESSA COLUNA)
	var _l = _x - _ox, _t = _y - _oy;
	draw_sprite_part_ext(_spr, _frame, 0, 0, _corte, _h, _l, _t, 1, 1, c_white, _alpha);
	draw_sprite_part_ext(_spr, _frame, _corte, 0, 1, _h, _l + _corte, _t, _extra, 1, c_white, _alpha);
	draw_sprite_part_ext(_spr, _frame, _corte, 0, _w - _corte, _h, _l + _corte + _extra, _t, 1, 1, c_white, _alpha);
}


//==================== MODO VERSUS ====================
//DOIS JOGADORES, CADA UM NA SUA ARENA, NA MESMA ROOM (RM_VERSUS). E A MESMA MAQUINA DO ARCADE/COOP: UMA UNICA OBJ_AREA LARGA (29 COLUNAS)
//COM DUAS "ZONAS" DE 10 COLUNAS (A DO P1 NA ESQUERDA E A DO P2 NA DIREITA) E UM VAO NO MEIO PRO PLACAR. CADA ZONA TEM A SUA PROPRIA
//CRIAÇAO DE PEÇAS, A SUA FILA DE TELEPORTE, AS SUAS LINHAS, O SEU COMBO E OS SEUS PONTOS. AS PAREDES E O CHAO DE CADA ZONA SAO CRIADOS
//POR CODIGO (VERSUS_MONTAR), POIS A ROOM SO TEM OS OBJETOS ANTIGOS DO VERSUS DE 2024 (QUE SAO APAGADOS).
//COMO SE ATRAPALHA: FECHAR LINHAS MANDA UM ATAQUE PRO ADVERSARIO (UM BLOCO DO JOGO: INIMIGO, GELO, CABEÇUDO, BOMBA, LASER...), QUE NASCE
//NA ARENA DELE NO LUGAR DA PROXIMA PEÇA. FECHAR LINHAS TAMBEM CANCELA OS ATAQUES QUE VOCE AINDA NAO RECEBEU (CONTRA-ATAQUE).
//QUEM ENCHER A ARENA ATE O TOPO (OU PERDER TODAS AS VIDAS) PERDE.
#macro VS_COLS				10		//COLUNAS DE CADA ZONA
#macro VS_ZONA2_COL			18		//COLUNA ONDE COMEÇA A ZONA DO P2 (O VAO CENTRAL TEM 8 COLUNAS)
#macro VS_ARENA_X			136		//X DA ARENA NA ROOM (O CENTRO DAS CASAS TEM QUE CAIR EM MULTIPLO DE 16: X = 8 + 16*N)
#macro VS_ARENA_Y			48		//Y DA ARENA NA ROOM
#macro VS_ARENA_ESC			1.75	//SPR_AREA_COOP (256PX) VEZES ISSO = 448PX = 28 COLUNAS (MARGEM DE 136PX DOS DOIS LADOS)
#macro VS_INICIO			(room_speed * 3)	//ESPERA ANTES DA PRIMEIRA PEÇA (A CONTAGEM "VALENDO!")
#macro VS_INTERVALO_INI		1.9		//SEGUNDOS ENTRE UMA PEÇA E OUTRA NO COMEÇO...
#macro VS_INTERVALO_FIM		.8		//...E NO FIM DA RAMPA (FICA MAIS FRENETICO COM O TEMPO)
#macro VS_QUEDA_INI			.62		//SEGUNDOS POR CASA QUE A PEÇA DESCE NO COMEÇO...
#macro VS_QUEDA_FIM			.27		//...E NO FIM DA RAMPA
#macro VS_RAMPA_S			200		//SEGUNDOS ATE O FIM DA RAMPA
#macro VS_COMBO_TEMPO		(room_speed * 4)	//TEMPO PRA EMENDAR OUTRA LINHA NO COMBO DA ZONA
#macro VS_MAX_ATAQUES		6		//BLOCOS PENDENTES NA FILA DE QUEM RECEBE (PODER NAO USA SE A FILA ESTA CHEIA)
#macro VS_NIVEL_S			120		//SEGUNDOS DE CADA NIVEL DA PARTIDA (NIVEL 1, 2 E 3: O 3 NAO ACABA)
#macro VS_ESCOLHA_S		5		//SEGUNDOS PRA ESCOLHER O PODER (O JOGO DE QUEM FECHOU A LINHA FICA PARADO)
#macro VS_ESCOLHA_ATRASO	28		//FRAMES ATE O MENU APARECER DEPOIS DE FECHAR A LINHA (DEIXA A LINHA EXPLODIR)
#macro VS_COR_P1			#4D7CFF		//AZUL (O LADO ESQUERDO)
#macro VS_COR_P2			#FF553A		//VERMELHO (O LADO DIREITO)

global.vs_nivel		= 1;		//NIVEL DA PARTIDA (VERSUS_NIVEL), PRA AVISAR QUANDO SOBE
global.vs_perdedor	= 0;		//0 NINGUEM PERDEU, 1 OU 2 = JOGADOR QUE PERDEU A RODADA
global.vs_vitorias	= [0, 0];	//VITORIAS DA SESSAO (NAO ZERA QUANDO REINICIA: REVANCHE)
global.vs_contou	= false;	//A VITORIA DA RODADA JA FOI CONTADA?

function modo_versus()	{ return room == rm_versus; }
function dois_players()	{ return global.coop or room == rm_versus; }

//QUAL ZONA (0 OU 1) TEM ESSE X DA ROOM? (-1 SE FOR NO VAO OU FORA DA ARENA)
function versus_zona_x(_x)
{
	if(!instance_exists(obj_area) or !variable_instance_exists(obj_area, "zonas")) return -1;
	for(var z = 0; z < 2; z++)
	{
		var _zn = obj_area.zonas[z];
		if(_x >= _zn.x and _x < _zn.x + VS_COLS * CEL) return z;
	}
	return -1;
}

//ZONA DO JOGADOR _N (1 OU 2)
function versus_zona_do(_n)
{
	return obj_area.zonas[_n - 1];
}

//ESCOLHE A PROXIMA PEÇA DA ZONA (USA O SORTEIO DO ARCADE, ENTAO OS BLOCOS NOVOS APARECEM PELO TEMPO DE PARTIDA IGUAL)
function versus_sortear(_zn)
{
	peca_sortear_proxima();
	_zn.prox = { tipo : global.prox_tipo, cor : global.prox_cor, especie : global.prox_especie, fantasmas : global.prox_fantasmas, gelo : global.prox_gelo };
}

//TEMPO (FRAMES) ATE A PROXIMA PEÇA DE UMA ZONA: COMEÇA CALMO E VAI FICANDO FRENETICO
function versus_intervalo()
{
	var _t = clamp(global.tempo_partida / VS_RAMPA_S, 0, 1);
	return room_speed * lerp(VS_INTERVALO_INI, VS_INTERVALO_FIM, _t);
}

//TEMPO (FRAMES) QUE A PEÇA ESPERA PRA DESCER UMA CASA NO VERSUS
function versus_queda()
{
	var _t = clamp(global.tempo_partida / VS_RAMPA_S, 0, 1);
	return room_speed * lerp(VS_QUEDA_INI, VS_QUEDA_FIM, _t);
}

//CHAMADO NO CREATE DO OBJ_AREA (SO NO RM_VERSUS): ESTICA A ARENA E CRIA AS DUAS ZONAS
function versus_criar()
{
	sprite_index = spr_area_coop;
	mask_index = spr_area_coop;
	image_xscale = VS_ARENA_ESC;
	x = VS_ARENA_X;
	y = VS_ARENA_Y;
	vs_montado = false;
	zonas = [];
	for(var z = 0; z < 2; z++)
	{
		var _c0 = z == 0 ? 0 : VS_ZONA2_COL;
		array_push(zonas, {
			idx : z,
			jogador : z + 1,
			c0 : _c0,
			x : VS_ARENA_X + _c0 * CEL,
			espera : VS_INICIO + z * 4,		//FRAMES ATE A PROXIMA PEÇA DESSA ZONA
			topo_cheio : 0,					//TENTATIVAS SEGUIDAS DE CRIAR PEÇA COM A ZONA CHEIA
			lado_ultimo : 0,
			prox : undefined,				//PROXIMA PEÇA (TIPO, COR, ESPECIE...)
			ataques : [],					//ATAQUES PENDENTES (NOMES DO DEBUG_LISTA_BLOCOS) QUE VAO NASCER NESSA ARENA
			combo : 0,						//SEQUENCIA DE LINHAS DENTRO DO TEMPO DO COMBO
			combo_t : 0,
			fila : [],						//FILA DO TELEPORTE
			atual : noone,					//A PEÇA QUE O TELEPORTE VAI PEGAR
			aviso : 0,						//FRAMES PISCANDO "ATAQUE!" (RECEBEU UM)
			enviou : 0,						//FRAMES PISCANDO "ATAQUE ENVIADO"
			energia : 0,					//ENERGIA DO ESPECIAL (ENCHE FECHANDO LINHAS)
			congelada : false,				//O TEMPO ESTA PARADO NESSA ARENA (O DONO USOU O PODER DO FANTASMA)
			invasor : 0,					//JOGADOR (1 OU 2) CUJO FANTASMA ESTA NESSA ARENA (0 = NINGUEM)
			fantasma : noone,				//O FANTASMA DO DONO DA ARENA (ESTA NA ARENA DO ADVERSARIO)
			fant_t : 0,					//FRAMES QUE FALTAM DO FANTASMA
			linhas : 0,						//LINHAS FECHADAS NA RODADA
			slots : ["", "", "", ""],		//OS 4 PODERES GUARDADOS (NOME DO BLOCO OU "" = VAZIO), USADOS PELAS TECLAS 1 2 3 4 (P1) / NUM 5 6 7 8 (P2)
			slot_t : [0, 0, 0, 0],			//QUANDO CADA UM FOI GUARDADO (O MAIS ANTIGO SAI SE ESTIVER CHEIO)
			slot_pop : [0, 0, 0, 0],		//1 A 0: PULINHO DA CAIXA QUANDO GANHA OU USA
			ajudas : [],					//BLOCOS QUE O PROPRIO DONO MANDOU PRA ARENA DELE (ESPECIAL, RAIO). NAO SAO CANCELADOS POR LINHAS
			escolha : undefined,			//MENU DE ESCOLHA ABERTO: { OPCOES, SEL, T } (A ARENA FICA PARADA ENQUANTO ISSO)
			escolha_atraso : 0,				//FRAMES ATE ABRIR O PROXIMO MENU
			recompensas : [],				//MENUS A ABRIR: { NIVEL, COMBO }
			chuva : 0,						//PEÇAS RAPIDAS QUE AINDA VAO CAIR NESSA ARENA (PODER CHUVA)
			duplas : 0,						//PEÇAS QUE AINDA VEM EM PAR NESSA ARENA (PODER DUPLAS)
			dupla_par : false,
			lin3 : 0,						//LINHAS FECHADAS NO NIVEL 3 (GUARDA PRO MINIJOGO DA 5A LINHA)
		});
	}
}

//CHAMADO NO 1O STEP DO OBJ_AREA: APAGA O RESTO DO VERSUS ANTIGO DA ROOM, CRIA PAREDES, CHAO E OS DOIS PLAYERS
function versus_montar()
{
	vs_montado = true;
	global.vs_perdedor = 0;
	global.vs_contou = false;
	global.vs_nivel = 1;
	//OBJETOS DO VERSUS ANTIGO E DO ARCADE (PAREDES, CHAO E REGUA QUE A ROOM TRAZ NO LUGAR ERRADO)
	with(obj_block) instance_destroy();
	with(obj_linha) instance_destroy();
	with(obj_linha_versus) instance_destroy();
	with(obj_borda) instance_destroy();
	for(var z = 0; z < 2; z++)
	{
		var _zn = zonas[z];
		//PAREDES (16PX DE LARGURA, A ALTURA DA ARENA), NOS DOIS LADOS DA ZONA
		instance_create_layer(_zn.x - CEL, y, "Blocos", obj_parede);
		instance_create_layer(_zn.x + VS_COLS * CEL, y, "Blocos", obj_parede);
		//CHAO: UM BLOCO EMBAIXO DE CADA COLUNA (A ORIGEM DO OBJ_BLOCK E NO CENTRO)
		for(var c = 0; c < VS_COLS; c++) instance_create_layer(_zn.x + CEL / 2 + CEL * c, y + sprite_height + CEL / 2, "Blocos", obj_block, { visible : false });	//(O CHAO JA VEM NO DESENHO DA MOLDURA)
		//O PLAYER NASCE NO MEIO DO CHAO DA ZONA
		instance_create_layer(_zn.x + VS_COLS * CEL / 2, y + sprite_height, "Blocos", obj_player, { jogador : z + 1 });
		versus_sortear(_zn);
	}
}

//AS COLUNAS ONDE A PROXIMA PEÇA PODE NASCER NA ZONA (IGUAL AO COLUNAS_SORTEADAS DO OBJ_AREA, SO QUE DENTRO DA ZONA)
function versus_colunas(_zn, _tipo)
{
	var _f = peca_formato(_tipo);
	var _minx = 0, _maxx = 0;
	for(var i = 0; i < array_length(_f[0]); i++)
	{
		_minx = min(_minx, _f[0][i]);
		_maxx = max(_maxx, _f[0][i]);
	}
	var _lista = [];
	for(var c = -_minx; c <= VS_COLS - 1 - _maxx; c++)
	{
		var _lado = 0;
		if(c + _minx == 0) _lado = -1;
		else if(c + _maxx == VS_COLS - 1) _lado = 1;
		var _peso = 1;
		if(_lado != 0) _peso = _lado == _zn.lado_ultimo ? PECA_LATERAL_REPETE : PECA_LATERAL_PESO;
		array_push(_lista, { col : _zn.c0 + c, lado : _lado, nota : power(random(1), 1 / _peso) });
	}
	array_sort(_lista, function(_a, _b) { return sign(_b.nota - _a.nota); });
	return _lista;
}

//CRIA A PROXIMA PEÇA (OU O ATAQUE QUE ESPERA NA FILA) NA ZONA. DEVOLVE FALSE SE NAO DEU (TENTA DE NOVO LOGO)
function versus_spawn(_z)
{
	var _zn = zonas[_z];
	//O CRIADOR LE AS GLOBAIS PROX_* NO FRAME SEGUINTE: SE JA TEM UM NASCENDO, ESPERA
	if(instance_exists(obj_cria_peca)) return false;
	if(is_undefined(_zn.prox)) versus_sortear(_zn);

	//ZONA CHEIA: BLOCO PARADO NA PRIMEIRA LINHA. PRECISA CONTINUAR CHEIA NA TENTATIVA SEGUINTE (UMA PEÇA ENCOSTADA EM OUTRA QUE AINDA CAI NAO CONTA)
	var _topo = y + CEL;
	var _x1 = _zn.x, _x2 = _zn.x + VS_COLS * CEL;
	var _cheia = false;
	with(obj_peca) if(estou_parado and !andar and y < _topo and x > _x1 and x < _x2) _cheia = true;
	if(_cheia)
	{
		_zn.topo_cheio++;
		if(_zn.topo_cheio >= 2) versus_perder(_z);
		return false;
	}
	_zn.topo_cheio = 0;

	//O QUE NASCE: UM ATAQUE RECEBIDO (TEM PRIORIDADE) OU A PROXIMA PEÇA DA ZONA
	var _fonte = array_length(_zn.ajudas) > 0 ? 2 : (array_length(_zn.ataques) > 0 ? 1 : 0);	//1 = ATAQUE DO ADVERSARIO, 2 = BLOCO QUE O DONO MANDOU PRA SI
	var _ataque = _fonte == 2 ? _zn.ajudas[0] : (_fonte == 1 ? _zn.ataques[0] : "");
	if(_ataque != "") debug_preparar(_ataque);
	else
	{
		global.debug_bloco = "";
		global.prox_tipo = _zn.prox.tipo;
		global.prox_cor = _zn.prox.cor;
		global.prox_especie = _zn.prox.especie;
		global.prox_fantasmas = _zn.prox.fantasmas;
		global.prox_gelo = _zn.prox.gelo;
	}

	//TEM ALGO NA AREA ONDE A PEÇA NASCE? ENTAO ESPERA
	if(collision_rectangle(_x1, y + CEL, _x2, (y + CEL) - CEL * 3, [obj_peca, obj_cria_peca, obj_inimigo], 0, 1))
	{
		global.debug_bloco = "";
		return false;
	}
	var _escolha = versus_colunas(_zn, global.prox_tipo)[0];
	instance_create_layer((x + CEL / 2) + CEL * _escolha.col, (y + CEL / 2) - CEL * 2, "Linha", obj_cria_peca);
	_zn.lado_ultimo = _escolha.lado;
	if(_fonte == 2) array_delete(_zn.ajudas, 0, 1);
	else if(_fonte == 1) array_delete(_zn.ataques, 0, 1);
	else _zn.prox = undefined; //A PROXIMA SO E SORTEADA NA PROXIMA TENTATIVA (O CRIADOR AINDA VAI LER AS GLOBAIS)
	return true;
}

//TODO FRAME (OBJ_AREA, FORA DA PAUSA): CRIA AS PEÇAS DE CADA ZONA E CONTA O COMBO
function versus_atualizar()
{
	if(!vs_montado) { versus_montar(); exit; }
	if(global.vs_perdedor != 0) exit;
	versus_perigo_atualizar();
	versus_fantasma_atualizar();
	versus_nivel_atualizar();
	for(var z = 0; z < 2; z++)
	{
		var _zn = zonas[z];
		if(_zn.combo_t > 0) _zn.combo_t--; else _zn.combo = 0;
		if(_zn.aviso > 0) _zn.aviso--;
		if(_zn.enviou > 0) _zn.enviou--;
		for(var k = 0; k < 4; k++) _zn.slot_pop[k] = max(0, _zn.slot_pop[k] - .06);
		versus_poderes_atualizar(z);
		if(_zn.congelada) continue; //TEMPO PARADO (PODER DO FANTASMA): NAO NASCEM PEÇAS NESSA ARENA
		if(!is_undefined(_zn.escolha)) continue; //ESCOLHENDO O PODER: A ARENA FICA PARADA
		if(_zn.espera > 0) { _zn.espera--; continue; }
		if(versus_spawn(z))
		{
			//CHUVA: AS PEÇAS CAEM UMA ATRAS DA OUTRA. DUPLAS: UMA SEGUNDA PEÇA VEM LOGO DEPOIS DA PRIMEIRA
			if(_zn.chuva > 0) { _zn.chuva--; _zn.espera = 14; }
			else if(_zn.duplas > 0)
			{
				_zn.dupla_par = !_zn.dupla_par;
				if(_zn.dupla_par) _zn.espera = 12;
				else { _zn.duplas--; _zn.espera = versus_intervalo(); }
			}
			else _zn.espera = versus_intervalo();
		}
		else _zn.espera = 8;
	}
}

//LINHAS COMPLETAS DE CADA ZONA (CHAMADO NO DRAW DA ARENA, IGUAL AO ARCADE)
function versus_detectar_linhas()
{
	if(!vs_montado) exit;
	for(var z = 0; z < 2; z++)
	{
		var _zn = zonas[z];
		var _linhas = [];
		for(var j = 0; j < lins; j++)
		{
			var _completa = true;
			for(var i = 0; i < VS_COLS; i++)
			{
				if(global.grid[# _zn.c0 + i, j] != 1) { _completa = false; break; }
			}
			if(_completa) array_push(_linhas, j);
		}
		if(timer_reset == 0 and array_length(_linhas) > 0) versus_limpar_linhas(z, _linhas);
	}
}

//UMA ZONA FECHOU LINHAS: MARCA NA GRADE, FAZ OS EFEITOS, SOMA O COMBO E MANDA O ATAQUE
function versus_limpar_linhas(_z, _linhas)
{
	var _zn = zonas[_z];
	var _n = array_length(_linhas);
	var _cx = _zn.x + VS_COLS * CEL / 2;
	var _y_texto = (y + CEL / 2) + CEL * _linhas[_n - 1];

	//MARCANDO NA GRADE (2 = SENDO DESTRUIDA, PRA NAO DETECTAR DE NOVO)
	for(var k = 0; k < _n; k++)
	{
		for(var i = 0; i < VS_COLS; i++) global.grid[# _zn.c0 + i, _linhas[k]] = 2;
	}

	//COMBO DA ZONA: OUTRA LINHA DENTRO DO TEMPO SOMA NA SEQUENCIA
	_zn.combo = _zn.combo_t > 0 ? _zn.combo + 1 : 1;
	_zn.combo_t = VS_COMBO_TEMPO;
	_zn.linhas += _n;
	var _palavra = "";
	if(_n == 2)		_palavra = texto("dupla");
	else if(_n == 3)	_palavra = texto("tripla");
	else if(_n >= 4)	_palavra = texto("incrivel");
	if(_palavra != "") efeito_texto(_palavra, _cx, _y_texto - 22, c_orange, 1.3 + .2 * (_n - 2));
	if(_zn.combo >= 2) efeito_texto("COMBO x" + string(_zn.combo), _cx, _y_texto - 38, c_aqua, 1.1);
	som_linha(_n + _zn.combo - 1);
	onda_choque(_cx, _y_texto, 60 + 20 * _n, 4 + _n, 28);
	hitstop(1 + _n);

	//UM EFEITO POR LINHA (ELE QUEBRA OS BLOCOS, DA OS PONTOS E ENERGIA)
	for(var k = 0; k < _n; k++)
	{
		var _row = _linhas[k];
		var _e = instance_create_layer(_cx, (y + CEL / 2) + CEL * _row, "Blocos", obj_efeito_line);
		_e.alt = CEL;
		_e.meu_y = y + CEL * _row;
		_e.line = false;
		_e.minha_area = id;
		_e.minha_linha = noone;
		_e.zx = _zn.x;
		_e.zc = VS_COLS;
		_e.zona = _z;
		_e.somar = false;
		_e.combo = _n;
		_e.criar_chao_combo = false;
	}

	//DEFESA: ESSAS LINHAS CANCELAM OS ATAQUES QUE EU AINDA IA RECEBER. E O JOGADOR GANHA UMA ESCOLHA DE PODER
	versus_defender(_z, _n);
	versus_recompensa(_z, _n);
}

//_Z FECHOU _N LINHAS: CADA LINHA CANCELA UM ATAQUE QUE ESTAVA CHEGANDO NA ARENA DELE (O ULTIMO DA FILA)
function versus_defender(_z, _n)
{
	var _eu = zonas[_z];
	var _cancelou = 0;
	while(_cancelou < _n and array_length(_eu.ataques) > 0)
	{
		array_delete(_eu.ataques, array_length(_eu.ataques) - 1, 1);
		_cancelou++;
	}
	if(_cancelou > 0)
	{
		efeito_texto(global.linguagem == 0 ? "DEFENDEU!" : "BLOCKED!", _eu.x + VS_COLS * CEL / 2, y + 60, #5CC8FF, 1.2);
		som_tocar(snd_escudo, .05);
	}
}

//A ZONA ENCHEU (OU O PLAYER MORREU): ESSE JOGADOR PERDEU A RODADA
function versus_perder(_z)
{
	if(global.vs_perdedor != 0) exit;
	global.vs_perdedor = _z + 1;
	with(obj_player) if(jogador == _z + 1 and !player_e_fantasma(id)) morrer(true);
}

//TELEPORTE: A TECLA DE CADA JOGADOR TELEPORTA A PEÇA ATUAL DA ZONA DELE
function versus_teleporte(_n)
{
	var _zn = versus_zona_do(_n);
	if(_zn.congelada or !is_undefined(_zn.escolha)) return; //TEMPO PARADO NA ARENA (OU ESCOLHENDO PODER): NADA TELEPORTA
	fila_limpar_zona(_zn);
	if(!instance_exists(_zn.atual)) return;
	with(_zn.atual) teleportar_peca();
	fila_avancar_zona(_zn);
	som_tocar(snd_acelerar_peca, .05);
}

//FILA DE TELEPORTE POR ZONA (IGUAL AO SCR_FILA, SO QUE UMA PRA CADA ARENA). _P = O BLOCO PAI DA PEÇA
function fila_limpar_zona(_zn)
{
	var _nova = [];
	for(var i = 0; i < array_length(_zn.fila); i++)
	{
		var _p = _zn.fila[i];
		if(instance_exists(_p) and _p != _zn.atual) array_push(_nova, _p);
	}
	_zn.fila = _nova;
}
function fila_avancar_zona(_zn)
{
	fila_limpar_zona(_zn);
	if(array_length(_zn.fila) > 0) { _zn.atual = _zn.fila[0]; array_delete(_zn.fila, 0, 1); }
	else _zn.atual = noone;
}
function fila_remover_zona(_zn, _p)
{
	if(_p == _zn.atual) { fila_avancar_zona(_zn); return; }
	for(var i = array_length(_zn.fila) - 1; i >= 0; i--) if(_zn.fila[i] == _p) array_delete(_zn.fila, i, 1);
}
function fila_adicionar_zona(_zn, _p)
{
	if(!instance_exists(_zn.atual)) _zn.atual = _p;
	else array_push(_zn.fila, _p);
}
//A PEÇA (BLOCO PAI) E A ATUAL DA ZONA DELA? (O BRILHO DA PEÇA QUE O TELEPORTE VAI PEGAR)
function versus_peca_atual(_pai)
{
	var _z = versus_zona_x(_pai.x);
	if(_z < 0) return false;
	return obj_area.zonas[_z].atual == _pai;
}


//ENERGIA DO ESPECIAL: NO VERSUS CADA ZONA TEM A SUA (_X = ONDE O BLOCO/PLAYER ESTA). NOS OUTROS MODOS E A GLOBAL.ENERGIA
function energia_valor(_x = noone)
{
	if(room == rm_versus)
	{
		var _z = _x == noone ? -1 : versus_zona_x(_x);
		return _z >= 0 ? obj_area.zonas[_z].energia : 0;
	}
	return global.energia;
}
function energia_gastar(_x, _qtd)
{
	if(room == rm_versus)
	{
		var _z = versus_zona_x(_x);
		if(_z >= 0) obj_area.zonas[_z].energia = max(0, obj_area.zonas[_z].energia - _qtd);
		return;
	}
	global.energia -= _qtd;
}
function versus_energia_ganhar(_z, _qtd)
{
	var _zn = obj_area.zonas[_z];
	var _antes = floor(_zn.energia);
	_zn.energia = min(ENERGIA_MAX, _zn.energia + _qtd);
	if(floor(_zn.energia) > _antes)
	{
		som_tocar(snd_certo);
		efeito_texto(texto("energia_cheia"), _zn.x + VS_COLS * CEL / 2, obj_area.y + obj_area.sprite_height - 60, c_aqua, 1);
	}
}


//==================== HUD DO VERSUS ====================
//FUNDO DAS DUAS ARENAS (DESENHADO PELA OBJ_AREA, POR BAIXO DAS PEÇAS). _SX/_SY = TREMIDA DA TELA
function versus_fundo_desenhar(_sx, _sy)
{
	for(var z = 0; z < 2; z++)
	{
		var _zn = zonas[z];
		var _x1 = _zn.x + _sx, _y1 = y + _sy, _x2 = _zn.x + VS_COLS * CEL - 1 + _sx, _y2 = y + sprite_height - 1 + _sy;
		draw_set_alpha(FUNDO_ARENA);
		draw_set_color(c_black);
		draw_rectangle(_x1, _y1, _x2, _y2, false);
		//PERIGO: A PILHA CHEGOU PERTO DO TOPO, A ARENA PISCA VERMELHO
		if(variable_struct_exists(_zn, "perigo") and _zn.perigo)
		{
			draw_set_alpha(.12 + .1 * sin(current_time / 90));
			draw_set_color(#FF2A2A);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
		}
		//TEMPO PARADO PELO PODER DO FANTASMA: A ARENA FICA VERDE E COM LISTRAS QUE DESCEM
		if(_zn.congelada)
		{
			draw_set_alpha(.22 + .06 * sin(current_time / 160));
			draw_set_color(TEMPO_VERDE);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
			draw_set_alpha(.12);
			for(var _ly = _y1 + ((current_time div 40) mod 12); _ly < _y2; _ly += 12) draw_line(_x1, _ly, _x2, _ly);
		}
		//TEM O FANTASMA DO ADVERSARIO AQUI DENTRO: A BORDA PISCA VERMELHO
		if(_zn.invasor > 0)
		{
			draw_set_alpha(.1 + .08 * sin(current_time / 100));
			draw_set_color(#FF2A55);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
		}
		//CHEGOU UM ATAQUE: FLASH NA COR DO ATAQUE
		if(_zn.aviso > 0)
		{
			draw_set_alpha(.18 * (_zn.aviso / (room_speed * 1.4)));
			draw_set_color(#FF5577);
			draw_rectangle(_x1, _y1, _x2, _y2, false);
		}
		draw_set_alpha(1);
		draw_set_color(c_white);
	}
}

//A PILHA DE CADA ZONA: PERIGO QUANDO TEM BLOCO PARADO NAS 4 LINHAS DE CIMA (CHAMADO TODO FRAME PELO VERSUS_ATUALIZAR)
function versus_perigo_atualizar()
{
	for(var z = 0; z < 2; z++)
	{
		var _zn = zonas[z];
		var _x1 = _zn.x, _x2 = _zn.x + VS_COLS * CEL;
		var _alto = y + sprite_height;
		with(obj_peca) if(estou_parado and !andar and velv == 0 and x > _x1 and x < _x2) _alto = min(_alto, y);
		var _antes = variable_struct_exists(_zn, "perigo") and _zn.perigo;
		_zn.perigo = _alto < y + CEL * 4;
		if(_zn.perigo and !_antes) som_tocar(snd_menu_erro_03, .08);
		_zn.altura = (y + sprite_height - _alto) / sprite_height; //0 VAZIA, 1 NO TOPO
	}
}

//PEÇA PEQUENA (PREVIA DA PROXIMA) CENTRADA EM (_X, _Y)
function versus_previa_desenhar(_zn, _x, _y)
{
	if(is_undefined(_zn.prox)) return;
	var _p = _zn.prox;
	//AS ESPECIES QUE SAO UM BLOCO SO MOSTRAM O ICONE DELAS
	if(_p.especie != "normal")
	{
		bloco_icone_desenhar(_p.especie == "inimigo" ? "inimigo" : _p.especie, _x, _y, 1);
		return;
	}
	var _f = peca_formato(_p.tipo);
	var _minx = 0, _maxx = 0, _miny = 0, _maxy = 0;
	for(var i = 0; i < array_length(_f[0]); i++)
	{
		_minx = min(_minx, _f[0][i]); _maxx = max(_maxx, _f[0][i]);
		_miny = min(_miny, _f[1][i]); _maxy = max(_maxy, _f[1][i]);
	}
	var _esc = .5;
	var _c = 8;
	var _ox = _x - (_minx + _maxx) / 2 * _c;
	var _oy = _y - (_miny + _maxy) / 2 * _c;
	var _frame = _p.gelo ? 0 : _p.cor;
	draw_sprite_ext(_p.gelo ? spr_bloco_gelo : spr_peca, _frame, _ox, _oy, _esc, _esc, 0, c_white, 1);
	for(var i = 0; i < array_length(_f[0]); i++)
	{
		draw_sprite_ext(_p.gelo ? spr_bloco_gelo : spr_peca, _frame, _ox + _f[0][i] * _c, _oy + _f[1][i] * _c, _esc, _esc, 0, c_white, 1);
	}
}

//CARTAO DE UM JOGADOR NA LATERAL (_ESQ = TRUE NO LADO ESQUERDO)
function versus_cartao_desenhar(_z, _esq)
{
	var _zn = obj_area.zonas[_z];
	var _n = _z + 1;
	var _p1 = _n == 1;
	var _cor = _z == 0 ? VS_COR_P1 : VS_COR_P2;
	var _pt = global.linguagem == 0;
	var _x = _esq ? 7 : room_width - 7 - COOP_CAIXA_W;	//CANTO DA CAIXA VISIVEL (A SPRITE TEM UMA MARGEM TRANSPARENTE)
	var _y = obj_area.y - 2;
	var _sombra = #0E071B;
	var _p = player_n(_n);
	//A MESMA CAIXA DO COOP: FRAME 0 = P1 (CORAÇOES NA ESQUERDA), FRAME 1 = P2 (CORAÇOES NA DIREITA)
	draw_sprite(spr_coop_caixa, _z, _x - COOP_CAIXA_OX, _y - COOP_CAIXA_OY);

	//CHEGOU UM ATAQUE: A CAIXA PISCA VERMELHO
	if(_zn.aviso > 0)
	{
		draw_set_color(#FF5577);
		draw_set_alpha(.4 + .6 * abs(sin(current_time / 90)));
		draw_rectangle(_x - 1, _y - 1, _x + COOP_CAIXA_W, _y + COOP_CAIXA_H, true);
		draw_rectangle(_x, _y, _x + COOP_CAIXA_W - 1, _y + COOP_CAIXA_H - 1, true);
		draw_set_alpha(1);
	}

	//FAIXA DO NOME: TINGIDA NA COR DO JOGADOR (AZUL / VERMELHO)
	draw_set_color(_cor);
	draw_set_alpha(.45);
	draw_rectangle(_x + 1, _y + 4, _x + 98, _y + 13, false);
	draw_set_alpha(1);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _nome = (_pt ? "JOGADOR " : "PLAYER ") + string(_n);
	draw_text_transformed_color(_x + 7, _y + 9.5, _nome, .55, .55, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_x + 6, _y + 8.5, _nome, .55, .55, 0, c_white, c_white, c_white, c_white, 1);

	//ENERGIA DO ESPECIAL (COLUNA DE 4 QUADRADOS: P1 NA DIREITA, P2 NA ESQUERDA): SOBE DE BAIXO PRA CIMA
	var _ex1 = _p1 ? _x + 80 : _x + 2, _ex2 = _p1 ? _x + 97 : _x + 19, _ebase = _y + 78, _ealt = 62;
	var _etopo = _ebase - _ealt * clamp(_zn.energia / ENERGIA_MAX, 0, 1);
	var _cheia = _zn.energia >= ENERGIA_MAX;
	var _celulas = [[_y + 66, _y + 78], [_y + 49, _y + 62], [_y + 32, _y + 45], [_y + 16, _y + 28]];	//DE BAIXO PRA CIMA
	for(var k = 0; k < 4; k++)
	{
		var _t = max(_celulas[k][0], _etopo);
		if(_t < _celulas[k][1])
		{
			draw_set_alpha(_cheia ? .75 + .25 * sin(current_time / 150) : .9);
			draw_rectangle_color(_ex1, _t, _ex2, _celulas[k][1], #31FCFF, #31FCFF, #1C6FD1, #1C6FD1, false);
			draw_set_alpha(1);
		}
	}

	//RETRATO: CARA DO MOMENTO (NORMAL, GRITA QUANDO ENVIA ATAQUE, MACHUCADO QUANDO RECEBE)
	var _perfil = global.skins[_n == 2 ? global.skin_player_2 : global.skin_player_1].perfil;
	var _cara = 0;
	if(_zn.enviou > 0) _cara = 1;
	if(_zn.aviso > 0 or (_p != noone and _p.imune > 0)) _cara = 3;
	if(_p != noone and _p.estado == state.morte) _cara = 3;
	if(_cara == 0 and (current_time + _n * 1700) mod 3500 < 130) _cara = 2;
	draw_sprite_part(_perfil, min(_cara, sprite_get_number(_perfil) - 1), 4, 0, 52, 60, _x + 24, _y + 17);

	//CORAÇOES (OS CHEIOS JA VEM NO DESENHO: SO APAGA OS QUE FORAM)
	var _vidas = _p != noone ? _p.vida_atual : 0;
	for(var i = 0; i < 3; i++)
	{
		if(i < _vidas) continue;
		var _hy = _y + 23 + 25 * i;
		var _hx = _p1 ? _x + 10 : _x + 88.5;
		draw_set_color(#242234);
		draw_rectangle(_hx - 9, _hy - 11, _hx + 9, _hy + 11, false);
		draw_sprite(spr_coracao, 1, _hx, _hy);
	}

	//AS 4 CAIXAS: OS PODERES GUARDADOS. VERDE = AJUDA VOCE, VERMELHO = ATACA O ADVERSARIO. O NUMERO E A TECLA QUE USA
	for(var i = 0; i < 4; i++)
	{
		var _bx = _x + 13.5 + 24 * i, _by = _y + 104.5;
		var _id = _zn.slots[i];
		var _kn = string(_n == 1 ? i + 1 : i + 5);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		if(_id != "")
		{
			var _inf = versus_opcao_info(_id);
			var _h = 8 + 3 * _zn.slot_pop[i];
			draw_set_color(_inf.eu ? #123A26 : #5A1428);
			draw_rectangle(_bx - _h, _by - _h, _bx + _h, _by + _h, false);
			draw_set_color(_inf.eu ? TEMPO_VERDE : #FF5577);
			draw_rectangle(_bx - _h, _by - _h, _bx + _h, _by + _h, true);
			versus_icone_desenhar(_id, _bx, _by - 1, .7);
		}
		draw_text_transformed_color(_bx + 6, _by + 6, _kn, .4, .4, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_bx + 5, _by + 5, _kn, .4, .4, 0, _id != "" ? c_white : #4A4570, _id != "" ? c_white : #4A4570, _id != "" ? c_white : #4A4570, _id != "" ? c_white : #4A4570, 1);
	}

	//PONTOS (O NUMERO FICA EMBAIXO DA PALAVRA "SCORE" QUE JA VEM NO DESENHO)
	var _val = string(_n == 2 ? global.pontos_2 : global.pontos_1);
	draw_set_halign(fa_center);
	var _es = min(1.5, 58 / max(1, string_width(_val)));
	draw_text_transformed_color(_x + 51.5, _y + 135, _val, _es, _es, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_x + 50.5, _y + 134, _val, _es, _es, 0, c_white, c_white, c_white, c_white, 1);

	//EMBAIXO DA CAIXA: O QUE O ESPECIAL (FANTASMA) ESTA FAZENDO E A TECLA DO TELEPORTE
	var _cx = _x + COOP_CAIXA_W / 2, _ty = _y + COOP_CAIXA_H + 10;
	var _cinza = #92A1B9;
	var _imp = imputs_jogador(_n);
	if(instance_exists(_zn.fantasma))
	{
		var _segs = ceil(_zn.fant_t / room_speed);
		draw_text_transformed_color(_cx, _ty, (_pt ? "FANTASMA: " : "GHOST: ") + string(_segs) + (_pt ? " SEG" : " SEC"), .55, .55, 0, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, 1);
		draw_text_transformed_color(_cx, _ty + 10, "[" + tecla_nome(versus_tecla_poder(_n)) + "] " + (_pt ? "ENCERRAR" : "END"), .45, .45, 0, _cinza, _cinza, _cinza, _cinza, 1);
	}
	else if(_zn.invasor > 0)
	{
		draw_text_transformed_color(_cx, _ty, _pt ? "INVADIDO!" : "INVADED!", .6, .6, 0, #FF5577, #FF5577, #FF5577, #FF5577, 1);
	}
	else if(_zn.energia >= VS_FANT_CUSTO)
	{
		var _pp = (current_time div 250) mod 2 == 0;
		var _cp = _pp ? TEMPO_VERDE : c_white;
		draw_text_transformed_color(_cx, _ty, (_pt ? "FANTASMA: " : "GHOST: ") + tecla_nome(versus_tecla_poder(_n)), .6, .6, 0, _cp, _cp, _cp, _cp, 1);
	}
	else if(_zn.energia >= 1)
	{
		draw_text_transformed_color(_cx, _ty, tecla_nome(_imp.down) + " + " + tecla_nome(_imp.soco), .5, .5, 0, #31FCFF, #31FCFF, #31FCFF, #31FCFF, 1);
	}
	draw_text_transformed_color(_cx, _ty + 22, (_pt ? "TELEPORTE: " : "DROP: ") + tecla_nome(_imp.acelerar), .5, .5, 0, _cinza, _cinza, _cinza, _cinza, 1);
	//O QUE ESTA CHEGANDO NA ARENA DESSE JOGADOR (VERMELHO = ATAQUE, VERDE = O QUE ELE MESMO MANDOU), NA ORDEM EM QUE NASCEM
	var _fila = [];
	for(var i = 0; i < array_length(_zn.ajudas); i++) array_push(_fila, { id : _zn.ajudas[i], eu : true });
	for(var i = 0; i < array_length(_zn.ataques); i++) array_push(_fila, { id : _zn.ataques[i], eu : false });
	if(array_length(_fila) > 0)
	{
		var _pisca = _zn.aviso > 0 and (current_time div 120) mod 2 == 0;
		var _cl = _pisca ? #FF5577 : _cinza;
		draw_text_transformed_color(_cx, _ty + 38, _pt ? "CHEGANDO" : "INCOMING", .5, .5, 0, _cl, _cl, _cl, _cl, 1);
		for(var i = 0; i < array_length(_fila); i++)
		{
			var _fx = _cx - (min(array_length(_fila), VS_MAX_ATAQUES) - 1) * 8.5 + i * 17, _fy = _ty + 52;
			draw_set_color(_fila[i].eu ? #123A26 : #5A1428);
			draw_rectangle(_fx - 7, _fy - 7, _fx + 7, _fy + 7, false);
			draw_set_color(_fila[i].eu ? TEMPO_VERDE : #FF5577);
			draw_rectangle(_fx - 7, _fy - 7, _fx + 7, _fy + 7, true);
			versus_icone_desenhar(_fila[i].id, _fx, _fy, .55);
		}
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

//CENTRO DA TELA (O VAO ENTRE AS ARENAS): "VS", VITORIAS E TEMPO
function versus_centro_desenhar()
{
	var _pt = global.linguagem == 0;
	var _cx = room_width / 2;
	var _sombra = #0E071B;
	var _top = obj_area.y;
	var _w = 120;

	//PLACAR DA SESSAO (VITORIAS) E O VS
	draw_set_font(fnt_table);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	//TRAÇO VERMELHO INCLINADO ATRAS DO VS
	draw_set_color(#E5173A);
	draw_triangle(_cx - 30, _top + 4, _cx + 8, _top + 4, _cx - 8, _top + 44, false);
	draw_triangle(_cx + 8, _top + 4, _cx - 8, _top + 44, _cx + 30, _top + 44, false);
	draw_text_transformed_color(_cx + 1, _top + 25, "VS", 1.5, 1.5, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_cx, _top + 24, "VS", 1.5, 1.5, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_font(fnt_hud);
	var _pl = string(global.vs_vitorias[0]) + "  -  " + string(global.vs_vitorias[1]);
	draw_text_transformed_color(_cx, _top + 58, _pl, 1, 1, 0, #FFE66B, #FFE66B, #FFE66B, #FFE66B, 1);
	draw_text_transformed_color(_cx, _top + 71, _pt ? "VITORIAS" : "WINS", .5, .5, 0, #92A1B9, #92A1B9, #92A1B9, #92A1B9, 1);
	//TEMPO
	var _seg = floor(global.tempo_partida);
	var _tempo = string_replace_all(string_format(_seg div 60, 2, 0), " ", "0") + ":" + string_replace_all(string_format(_seg mod 60, 2, 0), " ", "0");
	draw_text_transformed_color(_cx, _top + 88, _tempo, 1, 1, 0, c_white, c_white, c_white, c_white, 1);
	//NIVEL DA PARTIDA (SOBE A CADA VS_NIVEL_S SEGUNDOS ATE O 3) E UMA BARRINHA ATE O PROXIMO. O NIVEL DECIDE OS PODERES QUE APARECEM
	var _nv = versus_nivel();
	var _nvt = _pt ? "NIVEL " + string(_nv) : "LEVEL " + string(_nv);
	draw_text_transformed_color(_cx + 1, _top + 105, _nvt, .6, .6, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_cx, _top + 104, _nvt, .6, .6, 0, #31FCFF, #31FCFF, #31FCFF, #31FCFF, 1);
	if(_nv < 3)
	{
		var _pr = frac(global.tempo_partida / VS_NIVEL_S);
		draw_set_color(#1E1A38);
		draw_rectangle(_cx - 24, _top + 112, _cx + 24, _top + 115, false);
		draw_set_color(#31FCFF);
		draw_rectangle(_cx - 24, _top + 112, _cx - 24 + 48 * _pr, _top + 115, false);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

//MOLDURA DE UMA ARENA (POR CIMA DAS PEÇAS): SPR_NEW_AREA_VERSUS (180X315), FRAME 0 = P1 (AZUL) E FRAME 1 = P2 (VERMELHO).
//IGUAL AO COOP, A ARENA FICA 10PX PRA DENTRO DA ESQUERDA E 2PX PRA BAIXO DO TOPO. O CHAO DESENHADO JA VEM NELA
function versus_moldura_desenhar(_z, _sx, _sy)
{
	var _zn = obj_area.zonas[_z];
	draw_sprite(spr_new_area_versus, _z, _zn.x - 10 + _sx, obj_area.y - 2 + _sy);
}

//TODO O HUD DO VERSUS (OBJ_AREA_VERSUS, POR CIMA DE TUDO NA ROOM)
function versus_hud_desenhar()
{
	if(!instance_exists(obj_area) or !variable_instance_exists(obj_area, "zonas")) exit;
	var _sx = global.shake_x, _sy = global.shake_y + global.lerp_y;
	for(var z = 0; z < 2; z++) versus_moldura_desenhar(z, _sx, _sy);
	versus_cartao_desenhar(0, true);
	versus_cartao_desenhar(1, false);
	versus_centro_desenhar();
	for(var z = 0; z < 2; z++) versus_escolha_desenhar(z);

	//CONTAGEM NO COMEÇO DA RODADA: 3, 2, 1, VALENDO!
	var _t = obj_area.zonas[0].espera;
	var _tt = global.tempo_partida;
	if(_tt < VS_INICIO / room_speed)
	{
		var _rest = ceil(VS_INICIO / room_speed - _tt);
		var _txt = _rest > 0 ? string(_rest) : (global.linguagem == 0 ? "VALENDO!" : "GO!");
		draw_set_font(fnt_table);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var _esc = 3 + 1.5 * (1 - frac(VS_INICIO / room_speed - _tt));
		draw_text_transformed_color(room_width / 2 + 2, room_height / 2 + 2, _txt, _esc, _esc, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
		draw_text_transformed_color(room_width / 2, room_height / 2, _txt, _esc, _esc, 0, #FFE66B, #FFE66B, #FFB21E, #FFB21E, 1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
}

//TELA DE RESULTADO DO VERSUS (GUI, SO O FIM DA RODADA). _A = ALPHA
function versus_resultado_desenhar(_a)
{
	var _pt = global.linguagem == 0;
	var _e = gui_esc();
	var _tl = gui_tela();
	draw_set_alpha(_a * .7);
	draw_set_color(c_black);
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(_a);

	var _venc = global.vs_perdedor == 1 ? 2 : 1;	//QUEM GANHOU
	var _cor = _venc == 1 ? VS_COR_P1 : VS_COR_P2;
	var _cx = gui_meio_x();
	var _cy = gui_meio_y();
	var _pw = 300, _ph = 236;
	var _px = _cx - _pw / 2, _py = _cy - _ph / 2;
	var _th = sprite_get_height(spr_caixa_setings);
	draw_sprite_stretched_ext(spr_caixa_setings, 0, _px * _e, _py * _e, _pw * _e, _th * _e, c_white, _a);
	draw_sprite_stretched_ext(spr_menu_janela, 0, _px * _e, (_py + _th) * _e, _pw * _e, (_ph - _th) * _e, c_white, _a);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_text_transformed_color((_px + 5) * _e, (_py + _th / 2) * _e, _pt ? "FIM DA RODADA" : "ROUND OVER", _e, _e, 0, c_white, c_white, c_white, c_white, _a);

	//VENCEDOR
	var _perfil = global.skins[_venc == 2 ? global.skin_player_2 : global.skin_player_1].perfil;
	var _y = _py + _th + 14;
	draw_sprite_part_ext(_perfil, 0, 4, 0, 52, 60, (_cx - 26) * _e, _y * _e, _e, _e, c_white, _a);
	draw_set_halign(fa_center);
	var _tit = (_pt ? "JOGADOR " : "PLAYER ") + string(_venc) + (_pt ? " VENCEU!" : " WINS!");
	draw_text_transformed_color(_cx * _e + _e, (_y + 74) * _e + _e, _tit, _e * 1.2, _e * 1.2, 0, #0E071B, #0E071B, #0E071B, #0E071B, _a);
	draw_text_transformed_color(_cx * _e, (_y + 74) * _e, _tit, _e * 1.2, _e * 1.2, 0, _cor, _cor, _cor, _cor, _a);

	//NUMEROS DE CADA UM
	_y += 94;
	var _linhas = [
		[_pt ? "PONTOS" : "SCORE", string(global.pontos_1), string(global.pontos_2)],
		[_pt ? "LINHAS" : "LINES", string(obj_area.zonas[0].linhas), string(obj_area.zonas[1].linhas)],
		[_pt ? "VITORIAS" : "WINS", string(global.vs_vitorias[0]), string(global.vs_vitorias[1])],
	];
	for(var i = 0; i < array_length(_linhas); i++)
	{
		draw_set_halign(fa_center);
		draw_text_transformed_color(_cx * _e, _y * _e, _linhas[i][0], _e * .8, _e * .8, 0, #92A1B9, #92A1B9, #92A1B9, #92A1B9, _a);
		draw_set_halign(fa_right);
		draw_text_transformed_color((_cx - 40) * _e, _y * _e, _linhas[i][1], _e * .9, _e * .9, 0, VS_COR_P1, VS_COR_P1, VS_COR_P1, VS_COR_P1, _a);
		draw_set_halign(fa_left);
		draw_text_transformed_color((_cx + 40) * _e, _y * _e, _linhas[i][2], _e * .9, _e * .9, 0, VS_COR_P2, VS_COR_P2, VS_COR_P2, VS_COR_P2, _a);
		_y += 15;
	}

	//OPÇOES
	var _opcoes = [_pt ? "REVANCHE" : "REMATCH", _pt ? "VOLTAR AO MENU" : "BACK TO MENU"];
	_y += 6;
	draw_set_halign(fa_center);
	for(var i = 0; i < 2; i++)
	{
		var _sel = obj_game_control.opcao_fim == i;
		var _oy = _y + i * 20;
		if(_sel)
		{
			draw_set_color(#FFB21E);
			draw_set_alpha(_a);
			draw_rectangle((_cx - 80) * _e, (_oy - 8) * _e, (_cx + 80) * _e, (_oy + 8) * _e, false);
		}
		var _cc = _sel ? #1B1038 : #C7CFDD;
		draw_text_transformed_color(_cx * _e, _oy * _e, _opcoes[i], _e * .9, _e * .9, 0, _cc, _cc, _cc, _cc, _a);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}


//==================== SELETOR DO VERSUS ====================
//OS DOIS JOGADORES ESCOLHEM AO MESMO TEMPO NA MESMA TELA (RM_SELECAO COM GLOBAL.VERSUS_SEL LIGADO). VISUAL DO SELETOR DO VERSUS DO PROJETO
//ANTIGO (OS MESMOS SPRITES: FUNDO "FRENTE A FRENTE", CARTAS ESCURAS, CAIXA DE NOME COM SETAS, RETRATOS GRANDES, ICONE DE CONTROLE),
//COM O "VS" NO MEIO E O "PRONTO" DE CADA UM. QUANDO OS DOIS FICAM PRONTOS, COMEÇA.
//P1: A/D ESCOLHE, J OU ESPAÇO CONFIRMA, K VOLTA.  P2: SETAS ESCOLHE, C OU ENTER CONFIRMA, X VOLTA.  OS CONTROLES (GAMEPAD) SAO MAPEADOS
//PRA ESSAS TECLAS NO GAMEPAD_ATUALIZAR. ESC VOLTA PRO MENU.
global.versus_sel = false;	//A SELEÇAO DE PERSONAGEM ATUAL E A DO VERSUS?

//CHAMADO NO CREATE DO OBJ_SELECAO_PERSONAGEM
function versus_sel_criar()
{
	vs = global.versus_sel;
	if(!vs) return;
	vs_i = [global.pers_liberados[global.skin_player_1] ? global.skin_player_1 : personagem.macaco, global.pers_liberados[global.skin_player_2] ? global.skin_player_2 : personagem.macaco];
	vs_pronto = [false, false];
	vs_pop = [0, 0];			//0 A 1: A CARTA DA UM PULINHO QUANDO FICA PRONTA
	vs_seta = [0, 0];			//PISCADA DA SETA QUANDO TROCA (-1 ESQUERDA, 1 DIREITA, ANIMA ATE 0)
	vs_go = 0;					//FRAMES DEPOIS QUE OS DOIS FICARAM PRONTOS (A CONTAGEM)
	vs_t = 0;
	vs_troca = [0, 0];			//0 A 1: O RETRATO ENTRA DESLIZANDO QUANDO TROCA DE PERSONAGEM
}

//A TECLA DE CADA JOGADOR: [ESQUERDA, DIREITA, CONFIRMA 1, CONFIRMA 2, VOLTA]
function versus_sel_teclas(_n)
{
	if(_n == 1) return [ord("A"), ord("D"), ord("J"), vk_space, ord("K")];
	return [vk_left, vk_right, ord("C"), vk_enter, ord("X")];
}

//PROXIMO PERSONAGEM LIBERADO (_DIR = -1 OU 1). OS BLOQUEADOS SAO PULADOS: PRA COMPRAR TEM QUE IR NO ARCADE
function versus_sel_proximo(_atual, _dir)
{
	var _n = array_length(global.skins);
	var _i = _atual;
	repeat(_n)
	{
		_i = (_i + _dir + _n) mod _n;
		if(global.pers_liberados[_i]) return _i;
	}
	return _atual;
}

//TODO FRAME (STEP DO OBJ_SELECAO_PERSONAGEM)
function versus_sel_step()
{
	vs_t++;
	timer += .06;
	for(var n = 0; n < 2; n++)
	{
		vs_pop[n] = lerp(vs_pop[n], 0, .15);
		vs_seta[n] = lerp(vs_seta[n], 0, .25);
		vs_troca[n] = lerp(vs_troca[n], 1, .22);
	}
	if(instance_exists(obj_transisao)) exit;

	//OS DOIS PRONTOS: CONTAGEM CURTA E VAI PRO JOGO
	if(vs_pronto[0] and vs_pronto[1])
	{
		vs_go++;
		if(vs_go == 1) { som_tocar(snd_new_level); shakes(8, 2); }
		if(vs_go > room_speed * 1.3)
		{
			global.skin_player_1 = vs_i[0];
			global.skin_player_2 = vs_i[1];
			global.vs_vitorias = [0, 0];
			jogo_salvar();
			scr_trans(rm_versus);
		}
		//AINDA DA PRA DESISTIR NO COMEÇO DA CONTAGEM
		if(vs_go < room_speed * .5 and (keyboard_check_pressed(vk_escape))) { vs_pronto = [false, false]; vs_go = 0; som_tocar(snd_menu_erro_02); }
		exit;
	}
	vs_go = 0;

	for(var n = 0; n < 2; n++)
	{
		var _k = versus_sel_teclas(n + 1);
		var _esq = keyboard_check_pressed(_k[0]);
		var _dir = keyboard_check_pressed(_k[1]);
		var _ok = keyboard_check_pressed(_k[2]) or keyboard_check_pressed(_k[3]);
		var _cancela = keyboard_check_pressed(_k[4]);
		if(!vs_pronto[n])
		{
			if(_esq xor _dir)
			{
				var _d = _dir - _esq;
				var _novo = versus_sel_proximo(vs_i[n], _d);
				if(_novo != vs_i[n]) { vs_i[n] = _novo; vs_troca[n] = 0; }
				vs_seta[n] = _d;
				som_tocar(snd_menu_select_01, .05);
			}
			if(_ok)
			{
				vs_pronto[n] = true;
				vs_pop[n] = 1;
				som_tocar(snd_menu_confirm_01);
				shakes(4, 1);
			}
		}
		else if(_cancela or _esq or _dir)
		{
			vs_pronto[n] = false;
			som_tocar(snd_menu_erro_02);
		}
	}

	//ESC: SE ALGUEM TA PRONTO, TIRA O PRONTO. SENAO VOLTA PRO MENU
	if(keyboard_check_pressed(vk_escape))
	{
		som_tocar(snd_menu_erro_02);
		if(vs_pronto[0] or vs_pronto[1]) vs_pronto = [false, false];
		else
		{
			global.menu_principal = true;
			scr_trans(menu_room());
		}
	}
}

//SPRITE GRANDE DO PERSONAGEM NO SELETOR (OS RETRATOS DO SELETOR DO PROJETO ANTIGO: 145X118, UM FRAME POR COR DE PELO)
function versus_sel_retrato(_i)
{
	switch(_i)
	{
		case personagem.tartaruga:	return spr_versus_skin_turtle;
		case personagem.falcao:		return spr_versus_skin_aguia;
		case personagem.dino:		return spr_versus_skin_dino;
	}
	return spr_versus_skin_mamaco;
}

//TEXTO COM SOMBRA (CENTRALIZADO NO PONTO). A FONTE E A ALINHAMENTO DEVEM ESTAR PRONTOS
function versus_sel_texto(_x, _y, _txt, _esc, _cor, _ang = 0)
{
	var _sombra = #0E071B;
	draw_text_transformed_color(_x + 1, _y + 1, _txt, _esc, _esc, _ang, _sombra, _sombra, _sombra, _sombra, draw_get_alpha());
	draw_text_transformed_color(_x, _y, _txt, _esc, _esc, _ang, _cor, _cor, _cor, _cor, draw_get_alpha());
}

//QUADRILATERO INCLINADO: AS LETRAS DO "VS" SAO FEITAS DE BARRAS. AS COORDENADAS SAO DA LETRA (ALTURA TOTAL _H) E CADA PX DE ALTURA
//EMPURRA PRA DIREITA _K PX (A LETRA FICA ITALICA, COMO NO VERSUS ANTIGO)
function versus_sel_quad(_ox, _oy, _h, _k, _xt1, _xt2, _yt, _xb1, _xb2, _yb, _cor)
{
	var _tt = (_h - _yt) * _k, _tb = (_h - _yb) * _k;
	draw_set_color(_cor);
	draw_triangle(_ox + _xt1 + _tt, _oy + _yt, _ox + _xt2 + _tt, _oy + _yt, _ox + _xb2 + _tb, _oy + _yb, false);
	draw_triangle(_ox + _xt1 + _tt, _oy + _yt, _ox + _xb2 + _tb, _oy + _yb, _ox + _xb1 + _tb, _oy + _yb, false);
}

//O "VS" VERMELHO/AZUL DO MEIO. _CX, _CY = CENTRO. _PUL = ESCALA (PULSA QUANDO OS DOIS ESTAO PRONTOS)
function versus_sel_vs(_cx, _cy, _pul)
{
	var _h = 48, _k = .25;
	var _sombra = #0E071B;
	var _ox = _cx - 52 * _pul, _oy = _cy - _h / 2 * _pul;
	//(DESENHA EM ESCALA: CADA COORDENADA E MULTIPLICADA POR _PUL)
	for(var passo = 0; passo < 2; passo++)
	{
		var _dx = passo == 0 ? 3 : 0;
		var _dy = passo == 0 ? 3 : 0;
		var _c1 = passo == 0 ? _sombra : VS_COR_P1;
		var _c2 = passo == 0 ? _sombra : VS_COR_P2;
		var _p = _pul;
		//V
		versus_sel_quad(_ox + _dx, _oy + _dy, _h * _p, _k, 0, 12 * _p, 0, 13 * _p, 23 * _p, _h * _p, _c1);
		versus_sel_quad(_ox + _dx, _oy + _dy, _h * _p, _k, 26 * _p, 38 * _p, 0, 15 * _p, 25 * _p, _h * _p, _c1);
		//S (COMEÇA DEPOIS DO V)
		var _sx = _ox + _dx + 44 * _p;
		versus_sel_quad(_sx, _oy + _dy, _h * _p, _k, 0, 34 * _p, 0, 0, 34 * _p, 9 * _p, _c2);
		versus_sel_quad(_sx, _oy + _dy, _h * _p, _k, 0, 10 * _p, 0, 0, 10 * _p, 26 * _p, _c2);
		versus_sel_quad(_sx, _oy + _dy, _h * _p, _k, 0, 34 * _p, 19 * _p, 0, 34 * _p, 29 * _p, _c2);
		versus_sel_quad(_sx, _oy + _dy, _h * _p, _k, 24 * _p, 34 * _p, 22 * _p, 24 * _p, 34 * _p, 48 * _p, _c2);
		versus_sel_quad(_sx, _oy + _dy, _h * _p, _k, 0, 34 * _p, 39 * _p, 0, 34 * _p, 48 * _p, _c2);
	}
}

//UMA CARTA DE JOGADOR NO ESTILO DO SELETOR ANTIGO: NOME COM SETAS EM CIMA, A CARTA ESCURA COM O RETRATO E O CONTROLE EMBAIXO,
//E A CAIXA DE BAIXO COM "JOGADOR N" E O ESTADO. (_X1, _Y1 = CANTO DA CARTA, 147X171 PX DA ROOM)
function versus_sel_carta(_n, _x1, _y1)
{
	var _i = vs_i[_n];
	var _cor_j = _n == 0 ? VS_COR_P1 : VS_COR_P2;
	var _sombra = #0E071B;
	var _pt = global.linguagem == 0;
	var _pronto = vs_pronto[_n];
	var _pads = pads_ligados();
	var _pad = array_length(_pads) > _n;
	_y1 -= round(vs_pop[_n] * 5);
	var _cx = _x1 + 73;
	var _w = sprite_get_width(spr_versus_caixa), _h = sprite_get_height(spr_versus_caixa);

	draw_set_font(fnt_hud);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);

	//SOMBRA E BRILHO NA COR DO JOGADOR ATRAS DA CARTA (PISCA DE LEVE ESCOLHENDO, FIRME QUANDO PRONTO)
	draw_set_color(_sombra);
	draw_set_alpha(.5);
	draw_rectangle(_x1 + 5, _y1 + 5, _x1 + _w + 5, _y1 + _h + 5, false);
	gpu_set_blendmode(bm_add);
	draw_set_color(_cor_j);
	for(var g = 1; g <= 5; g++)
	{
		draw_set_alpha((_pronto ? .3 : .12 + .06 * sin(vs_t / 10 + _n * 2)) * (1 - g / 6));
		draw_rectangle(_x1 - g * 2, _y1 - g * 2, _x1 + _w + g * 2, _y1 + _h + g * 2, true);
	}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);

	//A CARTA (O DESENHO DO CONTROLE NO FUNDO MUDA SE E TECLADO OU GAMEPAD)
	draw_sprite_ext(spr_versus_caixa, _pad ? 0 : 1, _x1, _y1, 1, 1, 0, c_white, .96);

	//RETRATO: ENTRA DESLIZANDO QUANDO TROCA E OLHA PRA DENTRO (A DIREITA E ESPELHADA). O P1 USA A COR 1 DO PELO E O P2 A 2
	var _spr = versus_sel_retrato(_i);
	var _fr = min(_n, sprite_get_number(_spr) - 1);
	var _lado = _n == 0 ? -1 : 1;
	var _dx = (1 - vs_troca[_n]) * 22 * _lado;
	var _bob = _pronto ? 0 : round(sin(vs_t / 16 + _n * 2));
	var _esp = _n == 1 ? -1 : 1;
	var _px = _x1 + 1 + (_n == 1 ? 73 : 72) + _dx;
	var _py = _y1 + 58 + _bob;
	draw_sprite_ext(_spr, _fr, _px, _py, _esp, 1, 0, _pronto ? c_white : #DCDCE8, clamp(vs_troca[_n] * 1.5, 0, 1));
	//PRONTO: O RETRATO "ESTOURA" PRA FORA E SOME (COMO NO ANTIGO)
	if(vs_pop[_n] > .02)
	{
		var _g = 1 + (1 - vs_pop[_n]) * .7;
		draw_sprite_ext(_spr, _fr, _px, _py, _esp * _g, _g, 0, c_white, vs_pop[_n] * .55);
	}

	//DEBAIXO DO RETRATO: O CONTROLE QUE O JOGADOR USA (O 1O CONTROLE LIGADO E DO P1, O 2O E DO P2; SEM CONTROLE, TECLADO)
	var _ic = (_pad ? 0 : 2) + (_n == 0 ? 1 : 0);	//FRAMES: 0 GAMEPAD AZUL, 1 GAMEPAD VERMELHO, 2 TECLADO AZUL, 3 TECLADO VERMELHO
	draw_sprite_ext(spr_versus_control, _ic, _cx, _y1 + 131, 1, 1, 0, c_white, _pronto ? 1 : .75 + .25 * sin(vs_t / 12));
	var _ctrl = _pad ? (_pt ? "CONTROLE " : "GAMEPAD ") + string(_n + 1) : (_pt ? "TECLADO" : "KEYBOARD");
	versus_sel_texto(_cx, _y1 + 154, _ctrl, .6, #C7CFDD);

	//NOME DO PERSONAGEM EM CIMA (CAIXA DO ANTIGO) COM AS SETAS DOS LADOS: A DO LADO QUE APERTOU SALTA
	var _nx = _x1 + (_w - sprite_get_width(spr_versus_caixa_nome)) / 2;
	var _ny = _y1 - 3 - sprite_get_height(spr_versus_caixa_nome);
	draw_sprite_ext(spr_versus_caixa_nome, 0, _nx, _ny, 1, 1, 0, c_white, .95);
	//(A CAIXA DO NOME E CLARA: TEXTO ESCURO)
	var _nome = string_upper(global.skins[_i].nome);
	draw_text_transformed_color(_cx + 1, _ny + 16, _nome, .85, .85, 0, c_white, c_white, c_white, c_white, .5);
	draw_text_transformed_color(_cx, _ny + 15, _nome, .85, .85, 0, #1A1932, #1A1932, #1A1932, #1A1932, 1);
	for(var s = 0; s < 2; s++)
	{
		var _lado_s = s == 0 ? -1 : 1;
		var _ax = _cx + _lado_s * (sprite_get_width(spr_versus_caixa_nome) / 2 + 9) + (vs_seta[_n] == _lado_s ? _lado_s * 3 : 0);
		var _ca = _pronto ? .25 : (vs_seta[_n] == _lado_s ? 1 : .85);
		draw_sprite_ext(spr_versus_ceta, s, _ax, _ny + 14, 1, 1, 0, vs_seta[_n] == _lado_s ? #FFE66B : c_white, _ca);
	}

	//CAIXA DE BAIXO: "JOGADOR N" EM CIMA E O ESTADO EMBAIXO
	var _sx = _x1 + (_w - sprite_get_width(spr_versus_caixa_skin)) / 2;
	var _sy = _y1 + _h + 3;
	draw_sprite_ext(spr_versus_caixa_skin, 0, _sx, _sy, 1, 1, 0, c_white, .95);
	versus_sel_texto(_cx, _sy + 11, (_pt ? "JOGADOR " : "PLAYER ") + string(_n + 1), .75, _cor_j);
	versus_sel_texto(_cx, _sy + 34, _pronto ? (_pt ? "PRONTO!" : "READY!") : (_pt ? "ESCOLHENDO..." : "CHOOSING..."), .75, _pronto ? #8BFF32 : #C7CFDD);

	//AS TECLAS DESSE JOGADOR
	var _kk;
	if(_pad) _kk = _pt ? "< > ESCOLHER      A CONFIRMAR" : "< > CHOOSE      A CONFIRM";
	else _kk = _n == 0 ? (_pt ? "A D ESCOLHER      J CONFIRMAR" : "A D CHOOSE      J CONFIRM") : (_pt ? "SETAS ESCOLHER      C CONFIRMAR" : "ARROWS CHOOSE      C CONFIRM");
	versus_sel_texto(_cx, _sy + 62, _kk, .5, #92A1B9);

	//PRONTO: A CARTA ESCURECE UM POUCO E O CARIMBO "PRONTO!" GIRADO FICA POR CIMA DO RETRATO
	if(_pronto)
	{
		draw_set_font(fnt_table);
		var _es = 1.55 + vs_pop[_n] * .6;
		var _txt = _pt ? "PRONTO!" : "READY!";
		draw_text_transformed_color(_cx + 2, _y1 + 112 + 2, _txt, _es, _es, 14, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_cx, _y1 + 112, _txt, _es, _es, 14, #FF3237, #FF3237, #C8161E, #C8161E, 1);
		draw_set_font(fnt_hud);
	}
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
}

//DESENHO DA TELA INTEIRA (DRAW DO OBJ_SELECAO_PERSONAGEM): FUNDO GRANDE DO "FRENTE A FRENTE" DO PROJETO ANTIGO, A FAIXA NO TOPO,
//AS DUAS CARTAS E O "VS" NO MEIO
function versus_sel_desenhar()
{
	var _centro_x = room_width / 2;
	var _sombra = #0E071B;
	var _pt = global.linguagem == 0;

	//FUNDO: A ARTE GRANDE (1280X720) ESCALADA PRA ROOM, ESCURECIDA UM POUCO
	var _eb = room_width / sprite_get_width(spr_bg_fundo_versus);
	draw_sprite_ext(spr_bg_fundo_versus, 0, 0, 0, _eb, _eb, 0, c_white, 1);
	draw_set_alpha(.38);
	draw_set_color(_sombra);
	draw_rectangle(0, 0, room_width, room_height, false);
	draw_set_alpha(1);
	//LINHAS DO MEIO: UMA VERMELHA E UMA AZUL (O "CORTE" ENTRE OS DOIS)
	draw_set_alpha(.85);
	draw_set_color(VS_COR_P1);
	draw_line_width(_centro_x - 1, 0, _centro_x - 1, room_height, 1);
	draw_set_color(VS_COR_P2);
	draw_line_width(_centro_x + 1, 0, _centro_x + 1, room_height, 1);
	draw_set_alpha(1);

	//FAIXA DO TOPO (NO ESTILO DO "CHARACTER SELECTION" DO ANTIGO)
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _titulo = _pt ? "VERSUS: ESCOLHAM OS SEUS RECEPTÁCULOS" : "VERSUS: CHOOSE YOUR VESSELS";
	var _tw = string_width(_titulo) * .85 / 2 + 16;
	draw_set_color(_sombra);
	draw_rectangle(_centro_x - _tw - 2, 6, _centro_x + _tw + 2, 32, false);
	draw_set_color(#C7CFDD);
	draw_rectangle(_centro_x - _tw, 7, _centro_x + _tw, 30, false);
	draw_set_color(#424C6E);
	draw_rectangle(_centro_x - _tw + 2, 9, _centro_x + _tw - 2, 28, false);
	draw_set_color(#1A1932);
	draw_rectangle(_centro_x - _tw + 2, 26, _centro_x + _tw - 2, 28, false);
	versus_sel_texto(_centro_x, 19, _titulo, .85, #E4E9F5);

	//AS DUAS CARTAS (CABEM FOLGADO NOS DOIS LADOS, COMO NO ANTIGO)
	versus_sel_carta(0, 96, 92);
	versus_sel_carta(1, 477, 92);

	//O "VS" NO MEIO. QUANDO OS DOIS ESTAO PRONTOS ELE PULSA E FICA GRANDE
	var _go = vs_pronto[0] and vs_pronto[1];
	var _pul = _go ? 1.15 + .2 * sin(vs_go / 3) + min(vs_go / 60, .35) : 1 + .04 * sin(vs_t / 12);
	versus_sel_vs(_centro_x - 4, 175, _pul);
	if(_go)
	{
		draw_set_font(fnt_table);
		var _txt = _pt ? "VALENDO!" : "FIGHT!";
		draw_text_transformed_color(_centro_x + 2, 248, _txt, 1.4, 1.4, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_centro_x, 246, _txt, 1.4, 1.4, 0, #FFE66B, #FFE66B, #FFB21E, #FFB21E, 1);
		draw_set_font(fnt_hud);
	}

	//DICAS (E O AVISO DOS BLOQUEADOS)
	var _bloq = false;
	for(var k = 0; k < array_length(global.skins); k++) if(!global.pers_liberados[k]) _bloq = true;
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	versus_sel_texto(_centro_x, room_height - 30, _pt ? "ESC: VOLTAR      QUANDO OS DOIS ESTIVEREM PRONTOS, A LUTA COMEÇA!" : "ESC: BACK      WHEN BOTH ARE READY, THE FIGHT STARTS!", .6, #C7CFDD);
	if(_bloq) versus_sel_texto(_centro_x, room_height - 15, _pt ? "PERSONAGENS BLOQUEADOS: COMPRE NO ARCADE" : "LOCKED CHARACTERS: BUY THEM IN ARCADE", .5, #92A1B9);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}


//==================== PODER DO VERSUS: O FANTASMA INVASOR ====================
//COM A ENERGIA DO ESPECIAL EM VS_FANT_CUSTO CARGAS OU MAIS, O JOGADOR APERTA A TECLA DO PODER (P1 = I, P2 = B, OU O BOTAO DO TEMPO NO CONTROLE):
//	- O TEMPO PARA NA ARENA DELE (AS PEÇAS, OS INIMIGOS E OS TIROS DELA FICAM PARADOS) E O CORPO DELE FICA PARADO E IMUNE
//	- UM FANTASMA DELE NASCE NA ARENA DO ADVERSARIO E E CONTROLADO PELAS TECLAS DELE. O FANTASMA QUEBRA, EMPURRA E GIRA OS BLOCOS COMO UM
//	  PLAYER DE VERDADE, E OS PONTOS DOS BLOCOS QUE ELE QUEBRA (E DAS LINHAS FECHADAS ENQUANTO ELE ESTA LA) VAO PRA ELE, NAO PRO DONO DA ARENA
//	- PULANDO EM CIMA DO ADVERSARIO O FANTASMA O AMASSA NO CHAO POR UM TEMPO (ELE FICA ACHATADO E SEM CONTROLE)
//	- A ENERGIA VAI ESVAZIANDO ATE VS_FANT_CUSTO. APERTAR DE NOVO ENCERRA ANTES E GUARDA O QUE SOBROU
//O FANTASMA NAO MORRE NEM LEVA DANO E OS INIMIGOS/TIROS DA ARENA MIRAM SO NO ADVERSARIO DE VERDADE (PLAYER_PERTO IGNORA O FANTASMA)
#macro VS_FANT_CUSTO		2						//CARGAS DE ENERGIA QUE O FANTASMA GASTA (A BARRA TEM ENERGIA_MAX = 3)
#macro VS_FANT_DURACAO		(room_speed * 10)		//TEMPO MAXIMO DO FANTASMA
#macro VS_AMASSO			(room_speed * 2.2)		//TEMPO QUE O ADVERSARIO FICA AMASSADO
#macro VS_AMASSO_IMUNE		(room_speed * 1.4)		//DEPOIS DE SE LEVANTAR, UM TEMPO SEM PODER SER AMASSADO DE NOVO
#macro VS_ENERGIA_LINHA		.4						//ENERGIA QUE CADA LINHA FECHADA DA NO VERSUS (NO ARCADE E ENERGIA_LINHA)

//TECLA DO PODER DE CADA JOGADOR NO VERSUS
function versus_tecla_poder(_n)
{
	return _n == 1 ? ord("I") : ord("B");
}

//A ZONA DESSE X DA ROOM ESTA COM O TEMPO PARADO (O DONO USOU O PODER)?
function versus_zona_parada(_x)
{
	var _z = versus_zona_x(_x);
	return _z >= 0 and (obj_area.zonas[_z].congelada or !is_undefined(obj_area.zonas[_z].escolha));	//(PARADA PELO PODER OU PELO MENU DE ESCOLHA)
}

//PAUSA SO PRA QUEM ESTA NESSE X: A PAUSA DO JOGO TODO OU A ZONA CONGELADA PELO PODER
function pausa_em(_x)
{
	return global.game_pause or (room == rm_versus and versus_zona_parada(_x));
}

//DE QUEM SAO OS PONTOS DESTA ZONA? DO DONO DELA, OU DE QUEM TEM O FANTASMA LA DENTRO
function versus_pontos_de(_z)
{
	var _zn = obj_area.zonas[_z];
	return _zn.invasor > 0 ? _zn.invasor : _zn.jogador;
}

//O JOGADOR _N TEM O PODER ATIVO AGORA?
function versus_fantasma_ativo(_n)
{
	return instance_exists(versus_zona_do(_n).fantasma);
}

//APERTOU A TECLA DO PODER: INICIA (SE TEM ENERGIA) OU ENCERRA ANTES
function versus_poder_alternar(_n)
{
	if(global.vs_perdedor != 0) return;
	var _zn = versus_zona_do(_n);
	var _al = obj_area.zonas[2 - _n];	//ZONA DO ADVERSARIO
	if(versus_fantasma_ativo(_n)) { versus_fantasma_encerrar(_n); return; }
	//SEM ENERGIA, OU O ADVERSARIO TA COM O TEMPO PARADO (NAO TEM COMO INVADIR UMA ARENA PARADA), OU TEM UM FANTASMA DELE NA MINHA
	if(_zn.energia < VS_FANT_CUSTO or _al.congelada or _zn.invasor > 0 or !is_undefined(_zn.escolha))
	{
		som_tocar(snd_menu_erro_04);
		efeito_texto(_zn.energia < VS_FANT_CUSTO ? (global.linguagem == 0 ? "SEM ENERGIA" : "NO ENERGY") : (global.linguagem == 0 ? "AGORA NAO!" : "NOT NOW!"), _zn.x + VS_COLS * CEL / 2, obj_area.y + obj_area.sprite_height - 50, c_red, 1);
		return;
	}
	versus_fantasma_iniciar(_n);
}

//O TEMPO PARA NA ARENA DO JOGADOR _N E O FANTASMA DELE ENTRA NA ARENA DO ADVERSARIO
function versus_fantasma_iniciar(_n)
{
	var _a = obj_area;
	var _zn = _a.zonas[_n - 1];
	var _al = _a.zonas[2 - _n];
	var _corpo = player_n(_n);
	_zn.congelada = true;
	_zn.fant_t = VS_FANT_DURACAO;
	_al.invasor = _n;
	if(_corpo != noone) { _corpo.vs_parado = true; _corpo.velh = 0; }
	//O FANTASMA NASCE NA MESMA POSIÇAO (RELATIVA) DA ARENA DO ADVERSARIO, CAINDO DO TOPO
	var _gx = clamp(_al.x + (_corpo != noone ? _corpo.x - _zn.x : VS_COLS * CEL / 2), _al.x + CEL, _al.x + VS_COLS * CEL - CEL);
	var _gy = _a.y + 16;
	_zn.fantasma = instance_create_layer(_gx, _gy, "Blocos", obj_player, { jogador : _n, vs_fantasma : true });
	//CHEGADA: ONDAS NAS DUAS ARENAS, FEIXE VERDE E O AVISO PRO ADVERSARIO
	var _cor = TEMPO_VERDE;
	onda_choque(_zn.x + VS_COLS * CEL / 2, _a.y + _a.sprite_height / 2, 200, 7, 36);
	onda_choque(_gx, _gy, 120, 6, 28);
	poeira(_gx, _gy + 8, 10);
	som_tocar(snd_jingle_poder);
	shakes(10, 3);
	efeito_texto(global.linguagem == 0 ? "TEMPO PARADO!" : "TIME STOPPED!", _zn.x + VS_COLS * CEL / 2, _a.y + 60, _cor, 1.3);
	efeito_texto(global.linguagem == 0 ? "FANTASMA!" : "GHOST!", _gx, _a.y + 60, #FF5577, 1.3);
	_al.aviso = room_speed * 1.4;
}

//O FANTASMA SAI E O TEMPO VOLTA NA ARENA DO DONO
function versus_fantasma_encerrar(_n)
{
	var _a = obj_area;
	var _zn = _a.zonas[_n - 1];
	var _al = _a.zonas[2 - _n];
	if(instance_exists(_zn.fantasma))
	{
		var _f = _zn.fantasma;
		poeira(_f.x, _f.y + 8, 8);
		onda_choque(_f.x, _f.y, 80, 5, 24);
		with(_f) instance_destroy();
	}
	_zn.fantasma = noone;
	_zn.congelada = false;
	_zn.fant_t = 0;
	_al.invasor = 0;
	var _corpo = player_n(_n);
	if(_corpo != noone) _corpo.vs_parado = false;
	som_tocar(snd_certo);
	efeito_texto(global.linguagem == 0 ? "TEMPO VOLTOU" : "TIME IS BACK", _zn.x + VS_COLS * CEL / 2, _a.y + 60, c_white, 1);
}

//TODO FRAME (DENTRO DO VERSUS_ATUALIZAR): A ENERGIA ESVAZIA E O TEMPO DO FANTASMA ACABA
function versus_fantasma_atualizar()
{
	for(var z = 0; z < 2; z++)
	{
		var _zn = zonas[z];
		if(!_zn.congelada) continue;
		_zn.fant_t--;
		_zn.energia = max(0, _zn.energia - VS_FANT_CUSTO / VS_FANT_DURACAO);
		if(_zn.fant_t <= 0 or !instance_exists(_zn.fantasma)) versus_fantasma_encerrar(z + 1);
	}
}

//O JOGADOR _N E UM FANTASMA? (O PLAYER_N E O PLAYER_PERTO IGNORAM FANTASMAS)
function player_e_fantasma(_p)
{
	return variable_instance_exists(_p, "vs_fantasma") and _p.vs_fantasma;
}


//==================== HUD DO COOP: MOLDURA NOVA + UMA CAIXA PRA CADA JOGADOR ====================
//NO RM_COOP A ARENA GANHA A MOLDURA SPR_NEW_AREA_COOP (276X315, A ARENA FICA 10PX PRA DENTRO DA ESQUERDA E 2PX PRA BAIXO DO TOPO)
//E CADA JOGADOR TEM A SUA CAIXA SPR_COOP_CAIXA (103X180): O P1 NA ESQUERDA E O P2 NA DIREITA, COMO NO SPR_COOP_IDEIA.
//CADA CAIXA TEM: A FAIXA COM O NOME, A BARRA DE ENERGIA (ESQUERDA), O RETRATO, OS 3 CORAÇOES (DIREITA), OS 8 PODERES, O SCORE DO
//TIME E AS LETRAS A P E D R O P. EMBAIXO DE CADA UMA FICA UM PAINEL COM HI-SCORE/LEVEL (P1) E TEMPO/MOEDAS (P2).
//CHAMADO PELO DRAW DO OBJ_BORDA (E RODA COM O OBJ_BORDA COMO "SELF": USA OS HUD_PAINEL, HUD_FAIXA, HUD_RETRATO E HUD_ICONE DELE)
#macro COOP_CAIXA_W		103		//TAMANHO DA CAIXA VISIVEL (A SPRITE TEM 117X186 COM UMA MARGEM TRANSPARENTE: 10PX NA ESQUERDA E 4PX EM CIMA)
#macro COOP_CAIXA_H		158
#macro COOP_CAIXA_OX	10		//ONDE A CAIXA VISIVEL COMEÇA DENTRO DA SPRITE
#macro COOP_CAIXA_OY	4
#macro COOP_MOLDURA_W	276

//UMA CAIXA DE JOGADOR (_N = 1 OU 2) COM O CANTO DE CIMA ESQUERDO EM (_X, _Y). _CARA = EMOÇAO DO MOMENTO (RETRATO)
function coop_caixa_desenhar(_n, _x, _y, _cara, _dados)
{
	var _cor_j = _n == 1 ? COOP_COR_P1 : COOP_COR_P2;
	var _sombra = #0E071B;
	var _p = player_n(_n);
	var _pt = global.linguagem == 0;
	//O FRAME 0 DA SPRITE E DO P1 (CORAÇOES NA ESQUERDA, ENERGIA NA DIREITA) E O FRAME 1 E DO P2 (O CONTRARIO). (_X, _Y) = CANTO DA CAIXA VISIVEL
	var _sx = _x - COOP_CAIXA_OX, _sy = _y - COOP_CAIXA_OY;
	var _p1 = _n == 1;
	draw_sprite(spr_coop_caixa, _n - 1, _sx, _sy);
	//FEBRE: A CAIXA PISCA EM LARANJA JUNTO COM A MOLDURA
	if(febre_mix > 0)
	{
		gpu_set_fog(true, #FF7A1A, 0, 1);
		draw_sprite_ext(spr_coop_caixa, _n - 1, _sx, _sy, 1, 1, 0, c_white, febre_mix);
		gpu_set_fog(false, c_white, 0, 1);
	}

	//FAIXA DE CIMA: A COR DO JOGADOR NA PONTA E O NOME
	draw_set_alpha(.55);
	draw_set_color(_cor_j);
	draw_rectangle(_x + 3, _y + 5, _x + 8, _y + 11, false);
	draw_set_alpha(1);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _nome = "PLAYER " + string(_n);
	draw_text_transformed_color(_x + 13, _y + 9.5, _nome, .55, .55, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_x + 12, _y + 8.5, _nome, .55, .55, 0, c_white, c_white, c_white, c_white, 1);

	//VEZ DO TELEPORTE: A CAIXA DE QUEM TEM A VEZ PISCA NA COR DELE E GANHA A ETIQUETA "TELE" NA FAIXA DO NOME
	if(coop_vez_de() == _n)
	{
		var _pul = .5 + .5 * sin(current_time / 140);
		draw_set_color(_cor_j);
		draw_set_alpha(.6 + .4 * _pul);
		draw_rectangle(_x - 2, _y - 2, _x + COOP_CAIXA_W + 1, _y + COOP_CAIXA_H + 1, true);
		draw_rectangle(_x - 1, _y - 1, _x + COOP_CAIXA_W, _y + COOP_CAIXA_H, true);
		draw_rectangle(_x, _y, _x + COOP_CAIXA_W - 1, _y + COOP_CAIXA_H - 1, true);
		draw_set_alpha(1);
		draw_rectangle_color(_x + 62, _y + 4, _x + 97, _y + 13, _cor_j, _cor_j, _cor_j, _cor_j, false);
		draw_set_halign(fa_center);
		draw_text_transformed_color(_x + 80, _y + 9, "TELE", .5, .5, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_set_halign(fa_left);
	}

	//BARRA DE ENERGIA (COLUNA DA ESQUERDA, 4 QUADRADOS): SOBE DE BAIXO PRA CIMA. CHEIA PISCA, E AO ENCHER DA UM CLARAO
	var _ex1 = _p1 ? _x + 80 : _x + 2, _ex2 = _p1 ? _x + 97 : _x + 19, _ebase = _y + 78, _ealt = 62;
	var _etopo = _ebase - _ealt * clamp(energia_mostrada / ENERGIA_MAX, 0, 1);
	var _cheia = global.energia >= ENERGIA_MAX;
	var _celulas = [[_y + 66, _y + 78], [_y + 49, _y + 62], [_y + 32, _y + 45], [_y + 16, _y + 28]];	//DE BAIXO PRA CIMA
	for(var k = 0; k < 4; k++)
	{
		var _c1 = _celulas[k][0], _c2 = _celulas[k][1];
		var _t = max(_c1, _etopo);
		if(_t < _c2)
		{
			draw_set_alpha(_cheia ? .75 + .25 * sin(current_time / 150) : .9);
			draw_rectangle_color(_ex1, _t, _ex2, _c2, #31FCFF, #31FCFF, #1C6FD1, #1C6FD1, false);
			draw_set_alpha(1);
		}
	}
	if(energia_pulso > 0)
	{
		gpu_set_blendmode(bm_add);
		var _ex = (1 - energia_pulso) * 7;
		draw_set_color(TEMPO_VERDE);
		draw_set_alpha(energia_pulso * .8);
		draw_rectangle(_ex1 - _ex, _y + 12 - _ex, _ex2 + _ex, _y + 79 + _ex, true);
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	}

	//RETRATO NA JANELA PRETA DO MEIO (A JANELA E 59X69 E O RETRATO 52X60). NO COOP, MORTO ELE ESCURECE E MOSTRA QUANTO FALTA PRA VOLTAR
	hud_retrato(_n, _x + 24, _y + 17, _cara);

	//CORAÇOES (COLUNA DA DIREITA): OS QUE JA FORAM SE APAGAM (O CORAÇAO CHEIO JA VEM NO DESENHO DA CAIXA)
	var _vida = _p != noone ? _p.vida_atual : 0;
	for(var i = 0; i < 3; i++)
	{
		if(i < _vida) continue;
		var _hy = _y + 23 + 25 * i;
		draw_set_color(#242234);
		var _hx = _p1 ? _x + 10 : _x + 88.5;	//CENTRO DA COLUNA DOS CORAÇOES
		draw_rectangle(_hx - 9, _hy - 11, _hx + 9, _hy + 11, false);
		draw_sprite(spr_coracao, 1, _hx, _hy);
	}

	//AS 4 CAIXAS DE PODER. OS PODERES QUE O JOGADOR TEM SE ACENDEM NA COR DELES, UM EM CADA CAIXA, NA ORDEM DA LISTA (SE TIVER MAIS DE 4, OS PRIMEIROS 4)
	var _lista = global.poderes_lista;
	var _caixa = 0;
	for(var i = 0; i < array_length(_lista); i++)
	{
		var _pid = _lista[i].id;
		var _tem = tem_poder(_pid);
		if(!_tem) continue;
		if(_caixa >= 4) break;
		var _bx = _x + 13.5 + 24 * _caixa, _by = _y + 104.5;
		_caixa++;
		var _h = 8 * poder_pop[i];
		var _pcor = _lista[i].cor;
		if(_tem)
		{
			draw_set_color(merge_color(_pcor, _sombra, .75));
			draw_rectangle(_bx - _h, _by - _h, _bx + _h, _by + _h, false);
			draw_set_color(_pcor);
			draw_rectangle(_bx - _h, _by - _h, _bx + _h, _by + _h, true);
			hud_icone(_pid, _bx - 4, _by - 5, _pcor, false);
			//REFLEXO E ESCUDO: BARRINHA EMBAIXO DO ICONE (DO PROPRIO JOGADOR DESSA CAIXA)
			var _barra = -1, _quebrado = false;
			if(_pid == "reflexo" and _p != noone) _barra = _p.reflexo_energia;
			if(_pid == "escudo" and _p != noone) { _barra = _p.escudo_vida; _quebrado = _p.escudo_quebrado; }
			if(_barra >= 0)
			{
				draw_set_color(_sombra);
				draw_rectangle(_bx - 6, _by + 5, _bx + 6, _by + 6, false);
				draw_set_color(_quebrado ? #7A3030 : c_white);
				draw_rectangle(_bx - 6, _by + 5, _bx - 6 + 12 * _barra / 100, _by + 6, false);
			}
		}
	}

	//SCORE DO TIME (O NUMERO FICA EMBAIXO DA PALAVRA "SCORE" QUE JA VEM NO DESENHO) E DA UM PULINHO QUANDO CHEGA PONTO
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _val = _n == 1 ? _dados.p1 : _dados.p2;	//CADA UM MOSTRA O SEU PROPRIO SCORE (O DO TIME FICA NA FAIXA DE BAIXO)
	var _es = min(1.5, 58 / max(1, string_width(_val))) * score_esc;	//ENCOLHE SE O NUMERO FICAR COMPRIDO
	var _sc = (score_esc > 1.05) ? c_yellow : c_white;
	draw_text_transformed_color(_x + 51.5, _y + 135, _val, _es, _es, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_x + 50.5, _y + 134, _val, _es, _es, 0, _sc, _sc, _sc, _sc, 1);

	//LETRAS A P E D R O P: AS QUE FALTAM FICAM APAGADAS (O DESENHO JA TEM). A QUE PEGOU GANHA A COR E UM "POP"
	var _cores_l = [ #8BFF32, #FFFF00, #DE65FF, #31FCFF, #FF3237, #8BFF32, #FFFF00];
	var _let = letras_de(_n);
	var _pop = letra_pop_de(_n);
	var _todas = letras_completas(_n);
	var _festa = global.palavra_festa > 0 and _todas;	//A FESTA E SO DE QUEM COMPLETOU A PALAVRA
	draw_set_font(fnt_hud);
	for(var i = 0; i < array_length(_let); i++)
	{
		var _lx = _x + 7 + 14 * i, _ly = _y + 149.5;
		if(_festa)
		{
			var _q = frac((1 - global.palavra_festa / PALAVRA_FESTA) * 2) * 1.6 - i * .1;
			if(_q > 0 and _q < 1) { _ly -= sin(_q * pi) * 6; _pop[i] = max(_pop[i], 1 + sin(_q * pi) * .6); }
		}
		if(!_let[i]) continue;
		var _hh = 5 * _pop[i];
		var _c = _cores_l[i];
		if(_todas and (current_time div 120) mod 2 == 0) _c = c_white;
		if(_festa) _c = merge_color(_c, #FFE600, .5 + .5 * sin(current_time / 60 + i));
		draw_set_color(merge_color(_c, c_black, .5));
		draw_rectangle(_lx - _hh, _ly - _hh, _lx + _hh, _ly + _hh, false);
		draw_set_color(_c);
		draw_rectangle(_lx - _hh, _ly - _hh, _lx + _hh - 1, _ly + _hh - 1, false);
		draw_set_color(merge_color(_c, c_white, .55));
		draw_rectangle(_lx - _hh, _ly - _hh, _lx + _hh - 1, _ly - _hh, false);
		draw_rectangle(_lx - _hh, _ly - _hh, _lx - _hh, _ly + _hh - 1, false);
		var _ts = .5 * _pop[i];
		draw_set_halign(fa_center);
		draw_text_transformed_color(_lx, _ly, global.letras_nomes[i], _ts, _ts, 0, _sombra, _sombra, _sombra, _sombra, 1);
	}
	//FESTA DA PALAVRA COMPLETA: BRILHO DOURADO EM VOLTA DA FILEIRA
	if(_festa)
	{
		var _pf = 1 - global.palavra_festa / PALAVRA_FESTA;
		var _ab = 2 + sin(current_time / 70) * 2;
		gpu_set_blendmode(bm_add);
		draw_set_alpha(.4 * (1 - _pf * .5));
		draw_set_color(#FFB21E);
		draw_rectangle(_x - _ab, _y + 142 - _ab, _x + COOP_CAIXA_W + _ab, _y + 157 + _ab, false);
		draw_set_alpha(1);
		gpu_set_blendmode(bm_normal);
	}

	//MOEDAS (SO NA CAIXA DO P2): UM PAINELZINHO EMBAIXO. A MOEDA DA UM "PULO" QUANDO CHEGA UMA. O LEVEL, O RECORDE E O TEMPO FICAM NA FAIXA DE BAIXO DA MOLDURA
	if(_n == 2)
	{
		var _my = _y + COOP_CAIXA_H + 5;
		hud_painel(_x, _my, _x + COOP_CAIXA_W, _my + 18);
		moeda_esc = lerp(moeda_esc, 1, .15);
		draw_set_font(fnt_mini_hud);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_sprite_ext(spr_moeda, current_time / 100, _x + 14, _my + 9, moeda_esc, moeda_esc, 0, c_white, 1);
		var _tm = string(global.moedas_partida);
		draw_text_transformed_color(_x + 26, _my + 10.5, _tm, moeda_esc, moeda_esc, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_x + 25, _my + 9.5, _tm, moeda_esc, moeda_esc, 0, c_yellow, c_yellow, #FFB21E, #FFB21E, 1);
	}
}

//FAIXA DE BAIXO DA MOLDURA (SPR_COOP_CAIXA_BOTTOM, 247X35): LEVEL, TEAM SCORE (NO MEIO, MAIS ALTO) E TIME. OS NUMEROS FICAM EMBAIXO DOS NOMES.
//O MEIO MOSTRA O TOTAL DO TIME (P1 + P2). A PALAVRA "TEAM SCORE" E DESENHADA AQUI (NA SPRITE A PALAVRA ANTIGA FOI APAGADA)
function coop_faixa_desenhar(_x, _y, _dados)
{
	var _sombra = #0E071B;
	draw_sprite(spr_coop_caixa_bottom, 0, _x, _y);
	if(febre_mix > 0)
	{
		gpu_set_fog(true, #FF7A1A, 0, 1);
		draw_sprite_ext(spr_coop_caixa_bottom, 0, _x, _y, 1, 1, 0, c_white, febre_mix);
		gpu_set_fog(false, c_white, 0, 1);
	}
	//"TEAM SCORE" NO MEIO, NO MESMO ESTILO DAS OUTRAS PALAVRAS (BRANCO COM SOMBRA ESCURA)
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _azul = #003E66;
	var _rot = "TEAM SCORE", _re = min(.75, 54 / max(1, string_width(_rot)));	//ENCOLHE PRA CABER NO PAINEL AZUL
	draw_text_transformed_color(_x + 124, _y + 11.5, _rot, _re, _re, 0, _azul, _azul, _azul, _azul, 1);
	draw_text_transformed_color(_x + 123, _y + 10.5, _rot, _re, _re, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_font(fnt_mini_hud);
	var _vals = [[_x + 49, _y + 22, string(global.level)], [_x + 123, _y + 19, _dados.pontos], [_x + 197, _y + 22, _dados.tempo]];
	for(var i = 0; i < 3; i++)
	{
		var _ev = min(1, 52 / max(1, string_width(_vals[i][2])));	//ENCOLHE SE O NUMERO FICAR COMPRIDO
		draw_text_transformed_color(_vals[i][0] + 1, _vals[i][1] + 1, _vals[i][2], _ev, _ev, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_vals[i][0], _vals[i][1], _vals[i][2], _ev, _ev, 0, c_white, c_white, c_white, c_white, 1);
	}
}

//TUDO DO HUD DO COOP (CHAMADO NO INICIO DO DRAW DO OBJ_BORDA). A MOLDURA, AS DUAS CAIXAS E OS AVISOS QUE FICAM NA ARENA
function coop_hud_desenhar()
{
	var shake_x = global.shake_x, shake_y = global.shake_y + global.lerp_y;
	var _fx = x - 10 + shake_x, _fy = y - 2 + shake_y;	//CANTO DA MOLDURA (A ARENA ENTRA 10PX E 2PX PRA DENTRO DELA)
	//O CHAO DE BAIXO DA ARENA JA VEM NO DESENHO DA MOLDURA: OS BLOCOS DE CHAO DA ROOM SO FICAM COM A COLISAO
	if(instance_exists(obj_area))
	{
		var _fundo = obj_area.y + obj_area.sprite_height - 2;
		with(obj_block) if(y > _fundo) visible = false;
	}
	var _sombra = #0E071B;
	var _pt = global.linguagem == 0;

	//FEBRE: O QUE ESTA DESENHADO PISCA EM LARANJA (MAIS RAPIDO NOS ULTIMOS 2 SEGUNDOS)
	febre_mix = 0;
	if(global.febre > 0)
	{
		var _vel = global.febre < room_speed * 2 ? 50 : 120;
		febre_mix = .3 + .25 * sin(current_time / _vel);
	}
	draw_sprite(spr_new_area_coop, 0, _fx, _fy);
	if(febre_mix > 0)
	{
		gpu_set_fog(true, #FF7A1A, 0, 1);
		draw_sprite_ext(spr_new_area_coop, 0, _fx, _fy, 1, 1, 0, c_white, febre_mix);
		gpu_set_fog(false, c_white, 0, 1);
	}

	//DADOS COMPARTILHADOS: PONTOS SOBEM SUAVE, TEMPO DA PARTIDA, RECORDE
	var _alvo = max(0, global.pontos_1 - global.pontos_pendentes);
	pontos_mostrado = lerp(pontos_mostrado, _alvo, .2);
	if(abs(pontos_mostrado - _alvo) < 1) pontos_mostrado = _alvo;
	score_esc = lerp(score_esc, 1, .15);
	//SCORE INDIVIDUAL DE CADA UM (TAMBEM SOBE SUAVE E SO QUANDO O NUMERO CHEGA)
	if(!variable_instance_exists(id, "pm1")) { pm1 = 0; pm2 = 0; }
	var _a1 = max(0, global.coop_pts[0] - global.coop_pend[0]), _a2 = max(0, global.coop_pts[1] - global.coop_pend[1]);
	pm1 = lerp(pm1, _a1, .2);
	pm2 = lerp(pm2, _a2, .2);
	if(abs(pm1 - _a1) < 1) pm1 = _a1;
	if(abs(pm2 - _a2) < 1) pm2 = _a2;
	var _seg = floor(global.tempo_partida);
	var _dados = {
		pontos : string(round(pontos_mostrado)),
		p1 : string(round(pm1)),
		p2 : string(round(pm2)),
		tempo : string_replace_all(string_format(_seg div 60, 2, 0), " ", "0") + ":" + string_replace_all(string_format(_seg mod 60, 2, 0), " ", "0")
	};
	var _cara = 0;
	if(global.emocao_timer > 0) { global.emocao_timer--; _cara = global.emocao; }

	//ENERGIA: SOBE SUAVE. AO ENCHER: SOM, TREMIDA, ONDA E UM PULSO QUE ABRE NA BARRA DAS DUAS CAIXAS
	energia_mostrada = lerp(energia_mostrada, global.energia, .1);
	if(!variable_instance_exists(id, "energia_pulso")) { energia_pulso = 0; energia_cheia_ant = global.energia >= ENERGIA_MAX; }
	var _cheia_agora = global.energia >= ENERGIA_MAX;
	if(_cheia_agora and !energia_cheia_ant)
	{
		energia_pulso = 1;
		som_tocar(snd_certo);
		audio_play_sound(snd_feitico, 2, false, .7, 0, 1.7);
		audio_play_sound(snd_jingle_poder, 2, false, .5, 0, 1.4);
		shakes(5, 2);
	}
	energia_cheia_ant = _cheia_agora;

	//PODERES: UM "POP" NO ICONE QUANDO GANHA
	var _lista = global.poderes_lista;
	for(var i = 0; i < array_length(_lista); i++)
	{
		if(tem_poder(_lista[i].id) and !array_contains(poderes_antes, _lista[i].id)) poder_pop[i] = 1.6;
		poder_pop[i] = lerp(poder_pop[i], 1, .12);
	}
	poderes_antes = array_create(0);
	array_copy(poderes_antes, 0, global.poderes, 0, array_length(global.poderes));
	for(var i = 0; i < array_length(global.letras); i++)
	{
		global.letra_pop[i] = lerp(global.letra_pop[i], 1, .12);
		global.letra_pop2[i] = lerp(global.letra_pop2[i], 1, .12);
	}

	//AS DUAS CAIXAS (P1 NA ESQUERDA, P2 NA DIREITA) COM O TOPO NA ALTURA DO TOPO DA MOLDURA
	var _cx1 = _fx - 8 - COOP_CAIXA_W;
	var _cx2 = _fx + COOP_MOLDURA_W + 7;
	coop_caixa_desenhar(1, _cx1, _fy, _cara, _dados);
	coop_caixa_desenhar(2, _cx2, _fy, _cara, _dados);
	coop_faixa_desenhar(_fx + (COOP_MOLDURA_W - 247) / 2, _fy + 316, _dados);	//FAIXA DE BAIXO, CENTRADA EMBAIXO DA MOLDURA
	if(energia_pulso > 0) energia_pulso = max(0, energia_pulso - .03);

	//COMBO DE LINHAS: EMBAIXO DO PAINEL DO P1 (NO ESPAÇO VAZIO DA ESQUERDA)
	combo_alpha = lerp(combo_alpha, global.combo_seq >= 2 ? 1 : 0, .2);
	if(global.combo_seq >= 2) combo_mostrado = global.combo_seq;
	if(combo_alpha > .01)
	{
		var _ccx = _cx1 + COOP_CAIXA_W / 2, _ccy = _fy + COOP_CAIXA_H + 30;
		var _pul = 1 + .08 * sin(current_time / 90);
		draw_set_font(fnt_hud);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed_color(_ccx + 1, _ccy + 1, "COMBO", 1, 1, 0, _sombra, _sombra, _sombra, _sombra, combo_alpha);
		draw_text_transformed_color(_ccx, _ccy, "COMBO", 1, 1, 0, c_aqua, c_aqua, c_aqua, c_aqua, combo_alpha);
		var _txt_c = "x" + string(combo_mostrado);
		var _ce = (1.6 + .1 * min(combo_mostrado, 6)) * _pul;
		draw_text_transformed_color(_ccx + 2, _ccy + 22, _txt_c, _ce, _ce, 0, _sombra, _sombra, _sombra, _sombra, combo_alpha);
		draw_text_transformed_color(_ccx, _ccy + 20, _txt_c, _ce, _ce, 0, c_white, c_white, c_aqua, c_aqua, combo_alpha);
		var _bw = 40 * (global.combo_timer / COMBO_TEMPO);
		draw_set_alpha(combo_alpha);
		draw_rectangle_color(_ccx - 20, _ccy + 38, _ccx + 20, _ccy + 41, _sombra, _sombra, _sombra, _sombra, false);
		draw_rectangle_color(_ccx - 20, _ccy + 38, _ccx - 20 + _bw, _ccy + 41, c_aqua, c_aqua, c_aqua, c_aqua, false);
		draw_set_alpha(1);
	}

	//ENERGIA CHEIA: AVISO DO PODER DE PARAR O TEMPO EMBAIXO DO PAINEL DO P2 (A TECLA 1)
	alerta_tempo = lerp(alerta_tempo, (_cheia_agora and global.tempo_fase == "") ? 1 : 0, .15);
	if(alerta_tempo > .02)
	{
		var _ax = _cx2 + COOP_CAIXA_W / 2, _ay = _fy + COOP_CAIXA_H + 38;
		var _pp = .8 + .2 * sin(current_time / 140);
		draw_set_font(fnt_hud);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_alpha(alerta_tempo);
		draw_text_transformed_color(_ax + 1, _ay + 1, _pt ? "TEMPO PARADO" : "TIME STOP", .8, .8, 0, _sombra, _sombra, _sombra, _sombra, alerta_tempo);
		draw_text_transformed_color(_ax, _ay, _pt ? "TEMPO PARADO" : "TIME STOP", .8, .8, 0, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, TEMPO_VERDE, alerta_tempo * _pp);
		draw_text_transformed_color(_ax, _ay + 14, _pt ? "APERTE 1" : "PRESS 1", .8, .8, 0, c_white, c_white, c_white, c_white, alerta_tempo);
		draw_set_alpha(1);
	}

	//PERIGO: ARENA PULSANDO VERMELHO
	perigo_alpha = lerp(perigo_alpha, global.perigo ? 1 : 0, .1);
	if(perigo_alpha > .01)
	{
		var _ar = obj_area;
		var _pp2 = (.5 + .5 * sin(current_time / 120)) * perigo_alpha;
		draw_set_alpha(.18 * _pp2);
		draw_rectangle_color(_ar.x, _ar.y, _ar.x + _ar.sprite_width, _ar.y + CEL * 4, c_red, c_red, c_red, c_red, false);
		draw_set_alpha(_pp2);
		draw_rectangle_color(_ar.x, _ar.y, _ar.x + _ar.sprite_width, _ar.y + _ar.sprite_height, c_red, c_red, c_red, c_red, true);
		draw_set_alpha(1);
		draw_set_font(fnt_hud);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text_transformed_color(_ar.x + _ar.sprite_width / 2, _ar.y - 10, texto("perigo"), 1, 1, 0, c_red, c_red, c_red, c_red, _pp2);
	}

	//AVISO DO MODO DE TESTE E VISAO ESPIRITUAL (O PROXIMO A NASCER E UM INIMIGO OU UMA BOMBA)
	draw_set_font(fnt_hud);
	draw_set_valign(fa_middle);
	if(IMORTAL)
	{
		draw_set_halign(fa_left);
		draw_text_transformed_color(_cx1, _fy + COOP_CAIXA_H + 8, "IMORTAL (TESTE)", .5, .5, 0, c_lime, c_lime, c_lime, c_lime, 1);
	}
	if(tem_poder("visao") and (global.prox_especie == "inimigo" or global.prox_especie == "bomba") and instance_exists(obj_area))
	{
		var _vx = obj_area.x + obj_area.sprite_width / 2;
		var _vy = obj_area.y + 14 + sin(current_time / 120) * 2;
		draw_set_halign(fa_center);
		var _vt = _pt ? "! INIMIGO VINDO !" : "! ENEMY INCOMING !";
		if(global.prox_especie == "bomba") _vt = _pt ? "! BOMBA VINDO !" : "! BOMB INCOMING !";
		draw_text_transformed_color(_vx + 1, _vy + 1, _vt, .8, .8, 0, _sombra, _sombra, _sombra, _sombra, 1);
		draw_text_transformed_color(_vx, _vy, _vt, .8, .8, 0, #FF7AE0, #FF7AE0, #FF7AE0, #FF7AE0, .6 + .4 * sin(current_time / 90));
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_font(-1);
	draw_set_halign(-1);
	draw_set_valign(-1);
}


//==================== VERSUS: PODERES POR ESCOLHA ====================
//FECHAR LINHA DA UMA ESCOLHA: O JOGO DE QUEM FECHOU PARA POR ATE VS_ESCOLHA_S SEGUNDOS (O DO ADVERSARIO CONTINUA), APARECEM 3 OPÇOES NO MEIO
//DA ARENA, E A ESCOLHIDA FICA GUARDADA NUMA DAS 4 CAIXAS. DEPOIS E SO APERTAR A TECLA DA CAIXA (P1: 1 2 3 4 / P2: NUM 5 6 7 8).
//O QUE APARECE DEPENDE DO NIVEL DA PARTIDA (SOBE A CADA VS_NIVEL_S SEGUNDOS) E DO COMBO:
//	NIVEL 1: ESPECIAL (PRA VOCE), INIMIGO PATRULHEIRO, RAIVOSO		NIVEL 2: ELETRICO (PRA VOCE), PEDRA, BURACO NEGRO, LASER
//	NIVEL 3: BOMBA, CABEÇADA, SNIPER, ABELHAS, FANTASMA				COMBO DE 3 LINHAS: GELATINA, GELO, CHUVA DE PEÇAS, PEÇAS DUPLAS
//OS PODERES "PRA VOCE" NASCEM NA PROPRIA ARENA; OS OUTROS, NA DO ADVERSARIO. LINHAS FECHADAS AINDA CANCELAM ATAQUES QUE ESTAVAM CHEGANDO.
//(AINDA NAO TEM: O MINIJOGO QUE O NIVEL 3 DA NA 5A LINHA. A CONTA JA ESTA EM LIN3)

//NIVEL ATUAL DA PARTIDA (1, 2 OU 3)
function versus_nivel()
{
	return clamp(1 + floor(global.tempo_partida / VS_NIVEL_S), 1, 3);
}

//SUBIU DE NIVEL: AVISO NO CENTRO DA TELA
function versus_nivel_atualizar()
{
	var _nv = versus_nivel();
	if(_nv == global.vs_nivel) return;
	global.vs_nivel = _nv;
	efeito_texto((global.linguagem == 0 ? "NIVEL " : "LEVEL ") + string(_nv) + "!", room_width / 2, y + 150, #31FCFF, 1.8);
	onda_choque(room_width / 2, y + 150, 120, 6, 30);
	som_tocar(snd_jingle_poder);
	shakes(6, 2);
}

//TECLA DA CAIXA _I (0 A 3) DO JOGADOR _N
function versus_tecla_slot(_n, _i)
{
	return _n == 1 ? ord("1") + _i : vk_numpad5 + _i;
}

//OPÇOES QUE O NIVEL (OU O COMBO) OFERECE
function versus_pool(_nivel, _combo)
{
	if(_combo) return ["Gelatina", "Gelo", "Chuva", "Duplas"];
	switch(_nivel)
	{
		case 1: return ["Especial", "Inimigo", "Raivoso"];
		case 2: return ["Raio", "Pedra", "Buraco", "LaserLado"];
	}
	return ["Bomba", "Cabecudo", "Sniper", "Colmeia", "Fantasma"];
}

//DADOS DE UMA OPÇAO: { NOME, DESC (2 LINHAS), EU (AJUDA QUEM USA), ICONE }. OS NOMES SAO OS DO DEBUG_LISTA_BLOCOS (+ "Chuva" E "Duplas")
function versus_opcao_info(_id)
{
	var _l = global.linguagem == 0 ? 0 : 1;
	var _n = [_id, _id], _d = ["", ""], _eu = false;
	switch(_id)
	{
		case "Especial":	_n = ["ESPECIAL", "SPECIAL"];			_d = ["BLOCO COM PREMIO SURPRESA\nNA SUA ARENA", "BLOCK WITH A SURPRISE PRIZE\nIN YOUR ARENA"]; _eu = true; break;
		case "Inimigo":		_n = ["PATRULHEIRO", "PATROL"];			_d = ["INIMIGO QUE PATRULHA A\nARENA DO ADVERSARIO", "ENEMY THAT PATROLS THE\nOPPONENT'S ARENA"]; break;
		case "Raivoso":		_n = ["RAIVOSO", "ANGRY"];				_d = ["PEÇA QUE CAI DIRETO NA\nARENA DO ADVERSARIO", "PIECE THAT DROPS STRAIGHT\nIN THE OPPONENT'S ARENA"]; break;
		case "Raio":		_n = ["ELETRICO", "ELECTRIC"];			_d = ["RAIO NA SUA ARENA:\nPONTOS EM DOBRO", "LIGHTNING IN YOUR ARENA:\nDOUBLE POINTS"]; _eu = true; break;
		case "Pedra":		_n = ["PEDRA", "STONE"];				_d = ["BLOCO DURO: PRECISA DE\n2 GOLPES PRA QUEBRAR", "TOUGH BLOCK: TAKES\n2 HITS TO BREAK"]; break;
		case "Buraco":		_n = ["BURACO NEGRO", "BLACK HOLE"];	_d = ["ENGOLE UM BLOCO E O SOLTA\nPEGANDO FOGO NO ADVERSARIO", "SWALLOWS A BLOCK AND DROPS\nIT BURNING ON THE OPPONENT"]; break;
		case "LaserLado":	_n = ["LASER", "LASER"];				_d = ["BLOCO QUE ATIRA LASER PRO\nLADO NA ARENA DO ADVERSARIO", "BLOCK THAT SHOOTS A LASER\nSIDEWAYS AT THE OPPONENT"]; break;
		case "Bomba":		_n = ["BOMBA", "BOMB"];					_d = ["INIMIGO QUE EXPLODE NA\nARENA DO ADVERSARIO", "ENEMY THAT EXPLODES IN\nTHE OPPONENT'S ARENA"]; break;
		case "Cabecudo":	_n = ["CABEÇADA", "HEADBUTT"];			_d = ["INIMIGO QUE EMPURRA E\nQUEBRA BLOCOS", "ENEMY THAT PUSHES AND\nBREAKS BLOCKS"]; break;
		case "Sniper":		_n = ["SNIPER", "SNIPER"];				_d = ["BLOCO QUE SE LANÇA QUANDO\nO PLAYER PASSA NA LINHA", "BLOCK THAT LAUNCHES WHEN\nTHE PLAYER CROSSES ITS LINE"]; break;
		case "Colmeia":		_n = ["ABELHAS", "BEES"];				_d = ["COLMEIA QUE SOLTA ABELHAS\nQUE DESTROEM BLOCOS", "HIVE THAT RELEASES BEES\nTHAT DESTROY BLOCKS"]; break;
		case "Fantasma":	_n = ["FANTASMA", "GHOST"];				_d = ["PEÇA TRANSPARENTE QUE O\nPLAYER ATRAVESSA", "TRANSPARENT PIECE THE\nPLAYER WALKS THROUGH"]; break;
		case "Gelatina":	_n = ["GELATINA", "JELLY"];				_d = ["TRAMPOLIM NA ARENA\nDO ADVERSARIO", "TRAMPOLINE IN THE\nOPPONENT'S ARENA"]; break;
		case "Gelo":		_n = ["GELO", "ICE"];					_d = ["PEÇA DE GELO QUE\nESCORREGA", "ICE PIECE THAT\nSLIPS"]; break;
		case "Chuva":		_n = ["CHUVA DE PEÇAS", "PIECE RAIN"];	_d = ["SOLTA 7 PEÇAS RAPIDAS NA\nARENA DO ADVERSARIO", "DROPS 7 FAST PIECES IN THE\nOPPONENT'S ARENA"]; break;
		case "Duplas":		_n = ["PEÇAS DUPLAS", "DOUBLE PIECES"];	_d = ["AS PROXIMAS PEÇAS DO\nADVERSARIO VEM EM PAR", "THE OPPONENT'S NEXT\nPIECES COME IN PAIRS"]; break;
	}
	return { id : _id, nome : _n[_l], desc : _d[_l], eu : _eu, icone : _id == "LaserLado" ? "laser_lado" : string_lower(_id) };
}

//ICONE DE UMA OPÇAO CENTRADO EM (_X, _Y). CHUVA E DUPLAS NAO SAO UM BLOCO SO: DESENHA PEÇAS
function versus_icone_desenhar(_id, _x, _y, _esc)
{
	if(_id == "Chuva")
	{
		bloco_icone_desenhar("normal", _x - 6 * _esc, _y - 6 * _esc, .55 * _esc);
		bloco_icone_desenhar("normal", _x + 5 * _esc, _y - 1 * _esc, .55 * _esc);
		bloco_icone_desenhar("normal", _x - 3 * _esc, _y + 6 * _esc, .55 * _esc);
		return;
	}
	if(_id == "Duplas")
	{
		bloco_icone_desenhar("normal", _x - 5 * _esc, _y, .7 * _esc);
		bloco_icone_desenhar("normal", _x + 5 * _esc, _y, .7 * _esc);
		return;
	}
	bloco_icone_desenhar(versus_opcao_info(_id).icone, _x, _y, _esc);
}

//_Z FECHOU _N LINHAS: GANHA UM MENU DE ESCOLHA (DE COMBO SE JA ESTA NO COMBO DE 3)
function versus_recompensa(_z, _n)
{
	var _zn = zonas[_z];
	var _combo = _zn.combo >= 3;
	if(_combo) _zn.combo = 0;
	if(versus_nivel() >= 3) _zn.lin3 += _n;
	if(array_length(_zn.recompensas) >= 3) return; //(MUITA COISA NA FILA: IGNORA)
	array_push(_zn.recompensas, { nivel : versus_nivel(), combo : _combo });
	if(is_undefined(_zn.escolha) and _zn.escolha_atraso <= 0) _zn.escolha_atraso = VS_ESCOLHA_ATRASO;
}

//TODO FRAME DE UMA ZONA: ABRE O MENU QUANDO CHEGA A HORA, LE AS TECLAS DELE E AS DAS 4 CAIXAS
function versus_poderes_atualizar(_z)
{
	var _zn = zonas[_z];
	var _n = _z + 1;
	var _imp = imputs_jogador(_n);
	if(global.vs_perdedor != 0) return;
	var _e = _zn.escolha;

	if(is_undefined(_e))
	{
		//ABRE O PROXIMO MENU (SE O DONO ESTA COM O PODER DO FANTASMA, ESPERA ELE VOLTAR)
		if(array_length(_zn.recompensas) > 0 and !_zn.congelada)
		{
			if(_zn.escolha_atraso > 0) _zn.escolha_atraso--;
			else versus_escolha_abrir(_z);
		}
		//USAR UM PODER GUARDADO
		for(var i = 0; i < 4; i++) if(keyboard_check_pressed(versus_tecla_slot(_n, i))) versus_poder_usar(_n, i);
		return;
	}

	//MENU ABERTO: ESQUERDA/DIREITA ESCOLHE, SOCO CONFIRMA (OU A TECLA DA CAIXA 1/2/3 ESCOLHE DIRETO)
	var _qtd = array_length(_e.opcoes);
	if(keyboard_check_pressed(_imp.left)) { _e.sel = (_e.sel + _qtd - 1) mod _qtd; som_tocar(snd_menu_select_02, .05); }
	if(keyboard_check_pressed(_imp.rigth)) { _e.sel = (_e.sel + 1) mod _qtd; som_tocar(snd_menu_select_02, .05); }
	var _ok = keyboard_check_pressed(_imp.soco) or keyboard_check_pressed(_imp.soco_press);
	for(var i = 0; i < _qtd; i++) if(keyboard_check_pressed(versus_tecla_slot(_n, i))) { _e.sel = i; _ok = true; }
	_e.t--;
	if(_e.t <= 0) _ok = true; //ACABOU O TEMPO: FICA COM A OPÇAO QUE ESTA MARCADA
	if(_ok) versus_escolha_fechar(_z);
}

//ABRE O MENU: SORTEIA 3 OPÇOES DO NIVEL E PARA O JOGO DESSA ARENA
function versus_escolha_abrir(_z)
{
	var _zn = zonas[_z];
	var _r = _zn.recompensas[0];
	var _pool = versus_pool(_r.nivel, _r.combo);
	var _op = [];
	while(array_length(_op) < min(3, array_length(_pool)))
	{
		var _c = _pool[irandom(array_length(_pool) - 1)];
		if(!array_contains(_op, _c)) array_push(_op, _c);
	}
	_zn.escolha = { opcoes : _op, sel : 0, t : room_speed * VS_ESCOLHA_S, tot : room_speed * VS_ESCOLHA_S, combo : _r.combo, nivel : _r.nivel };
	var _p = player_n(_z + 1);
	if(_p != noone) { _p.vs_parado = true; _p.velh = 0; }
	som_tocar(snd_jingle_poder, .05);
	efeito_texto(_r.combo ? "COMBO!" : (global.linguagem == 0 ? "ESCOLHA!" : "PICK ONE!"), _zn.x + VS_COLS * CEL / 2, y + 40, _r.combo ? c_aqua : c_yellow, 1.3);
}

//CONFIRMOU: GUARDA O PODER NUMA CAIXA (SE TODAS ESTAO CHEIAS, SUBSTITUI O MAIS ANTIGO) E O JOGO VOLTA
function versus_escolha_fechar(_z)
{
	var _zn = zonas[_z];
	var _e = _zn.escolha;
	var _id = _e.opcoes[_e.sel];
	var _s = -1;
	for(var i = 0; i < 4; i++) if(_zn.slots[i] == "") { _s = i; break; }
	if(_s < 0)
	{
		_s = 0;
		for(var i = 1; i < 4; i++) if(_zn.slot_t[i] < _zn.slot_t[_s]) _s = i;
	}
	_zn.slots[_s] = _id;
	_zn.slot_t[_s] = current_time;
	_zn.slot_pop[_s] = 1;
	_zn.escolha = undefined;
	array_delete(_zn.recompensas, 0, 1);
	var _p = player_n(_z + 1);
	if(_p != noone and !instance_exists(_zn.fantasma)) _p.vs_parado = false;
	if(array_length(_zn.recompensas) > 0) _zn.escolha_atraso = 18;
	som_tocar(snd_certo, .05);
	efeito_texto(versus_opcao_info(_id).nome, _zn.x + VS_COLS * CEL / 2, y + 40, versus_opcao_info(_id).eu ? TEMPO_VERDE : #FF5577, 1.1);
}

//APERTOU A TECLA DA CAIXA _I DO JOGADOR _N: MANDA O BLOCO (PRA ARENA DO ADVERSARIO OU PRA PROPRIA, SE FOR PODER "PRA VOCE")
function versus_poder_usar(_n, _i)
{
	if(global.vs_perdedor != 0 or global.game_pause) return;
	var _zn = versus_zona_do(_n);
	var _id = _zn.slots[_i];
	if(_id == "" or !is_undefined(_zn.escolha)) return;
	var _inf = versus_opcao_info(_id);
	var _al = obj_area.zonas[2 - _n];
	var _alvo = _inf.eu ? _zn : _al;
	var _especial = _id == "Chuva" or _id == "Duplas";
	var _fila = _inf.eu ? _alvo.ajudas : _alvo.ataques;
	if(!_especial and array_length(_fila) >= VS_MAX_ATAQUES)
	{
		som_tocar(snd_menu_erro_04);
		efeito_texto(global.linguagem == 0 ? "FILA CHEIA" : "QUEUE FULL", _zn.x + VS_COLS * CEL / 2, y + 60, #FF5577, 1);
		return;
	}
	switch(_id)
	{
		case "Chuva":	_alvo.chuva += 7; break;
		case "Duplas":	_alvo.duplas += 6; _alvo.dupla_par = false; break;
		default:		array_push(_fila, _id); break;
	}
	_zn.slots[_i] = "";
	_zn.slot_pop[_i] = 1;
	_zn.enviou = room_speed * 1.1;
	var _ex = _alvo.x + VS_COLS * CEL / 2;
	if(_inf.eu)
	{
		efeito_texto(global.linguagem == 0 ? "PODER!" : "POWER!", _ex, y + 40, TEMPO_VERDE, 1.4);
		som_tocar(snd_certo);
	}
	else
	{
		_al.aviso = room_speed * 1.4;
		efeito_texto(global.linguagem == 0 ? "ATAQUE!" : "ATTACK!", _ex, y + 40, #FF5577, 1.4);
		som_tocar(snd_menu_erro_03);
		shakes(6, 2);
	}
}

//O MENU DE ESCOLHA NO MEIO DA ARENA (_Z) E, EMBAIXO DELA, O TEMPO QUE FALTA. SO APARECE QUANDO O MENU ESTA ABERTO
function versus_escolha_desenhar(_z)
{
	var _zn = obj_area.zonas[_z];
	var _e = _zn.escolha;
	if(is_undefined(_e)) return;
	var _n = _z + 1;
	var _pt = global.linguagem == 0;
	var _cor = _z == 0 ? VS_COR_P1 : VS_COR_P2;
	var _sombra = #0E071B;
	var _cinza = #92A1B9;
	var _cx = _zn.x + VS_COLS * CEL / 2;
	var _y1 = obj_area.y + 52;
	var _pul = .5 + .5 * sin(current_time / 120);

	//PAINEL
	draw_set_color(_sombra);
	draw_set_alpha(.93);
	draw_rectangle(_zn.x + 1, _y1, _zn.x + VS_COLS * CEL - 1, _y1 + 184, false);
	draw_set_alpha(1);
	draw_set_color(_cor);
	draw_rectangle(_zn.x + 1, _y1, _zn.x + VS_COLS * CEL - 1, _y1 + 184, true);
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _tit = _e.combo ? (_pt ? "COMBO! ESCOLHA UM PODER" : "COMBO! PICK A POWER") : (_pt ? "ESCOLHA UM PODER" : "PICK A POWER");
	draw_text_transformed_color(_cx + 1, _y1 + 11, _tit, .6, .6, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_cx, _y1 + 10, _tit, .6, .6, 0, _e.combo ? #31FCFF : c_white, _e.combo ? #31FCFF : c_white, _e.combo ? #31FCFF : c_white, _e.combo ? #31FCFF : c_white, 1);

	//AS CARTAS
	var _qtd = array_length(_e.opcoes);
	var _cw = 46, _ch = 84, _gap = 5;
	var _x0 = _cx - (_qtd * _cw + (_qtd - 1) * _gap) / 2;
	for(var i = 0; i < _qtd; i++)
	{
		var _inf = versus_opcao_info(_e.opcoes[i]);
		var _sel = i == _e.sel;
		var _kx = _x0 + i * (_cw + _gap), _ky = _y1 + 22 + (_sel ? -2 : 0);
		draw_set_color(_sel ? #2A2350 : #1A1632);
		draw_rectangle(_kx, _ky, _kx + _cw, _ky + _ch, false);
		draw_set_color(_sel ? merge_color(_cor, c_white, _pul * .5) : #3A3558);
		draw_rectangle(_kx, _ky, _kx + _cw, _ky + _ch, true);
		if(_sel) draw_rectangle(_kx + 1, _ky + 1, _kx + _cw - 1, _ky + _ch - 1, true);
		versus_icone_desenhar(_e.opcoes[i], _kx + _cw / 2, _ky + 24, _sel ? 1.9 : 1.6);
		//NOME (ATE 2 LINHAS)
		var _pal = string_split(_inf.nome, " ");
		var _l1 = _pal[0], _l2 = "";
		if(array_length(_pal) > 1) { _l1 = _pal[0]; _l2 = _pal[1]; }
		var _ne = min(.5, (_cw - 4) / max(1, max(string_width(_l1), string_width(_l2))));
		draw_text_transformed_color(_kx + _cw / 2, _ky + 50, _l1, _ne, _ne, 0, c_white, c_white, c_white, c_white, 1);
		if(_l2 != "") draw_text_transformed_color(_kx + _cw / 2, _ky + 59, _l2, _ne, _ne, 0, c_white, c_white, c_white, c_white, 1);
		//PRA QUEM E
		var _ct = _inf.eu ? TEMPO_VERDE : #FF5577;
		draw_text_transformed_color(_kx + _cw / 2, _ky + _ch - 8, _inf.eu ? (_pt ? "PRA VOCE" : "FOR YOU") : (_pt ? "ATACA" : "ATTACK"), .42, .42, 0, _ct, _ct, _ct, _ct, 1);
		//NUMERO DA TECLA DIRETA
		draw_text_transformed_color(_kx + 6, _ky + 7, string(_n == 1 ? i + 1 : i + 5), .45, .45, 0, _cinza, _cinza, _cinza, _cinza, 1);
	}

	//O QUE A OPÇAO MARCADA FAZ
	var _di = versus_opcao_info(_e.opcoes[_e.sel]).desc;
	var _linhas = string_split(_di, "\n");
	for(var i = 0; i < array_length(_linhas); i++) draw_text_transformed_color(_cx, _y1 + 22 + _ch + 14 + i * 10, _linhas[i], .45, .45, 0, c_white, c_white, c_white, c_white, 1);

	//TECLAS
	var _imp = imputs_jogador(_n);
	draw_text_transformed_color(_cx, _y1 + 175, tecla_nome(_imp.left) + " " + tecla_nome(_imp.rigth) + (_pt ? "  ESCOLHE    " : "  PICK    ") + tecla_nome(_imp.soco) + (_pt ? "  CONFIRMA" : "  CONFIRM"), .4, .4, 0, _cinza, _cinza, _cinza, _cinza, 1);

	//TEMPO QUE FALTA, EMBAIXO DA ARENA
	var _fr = clamp(_e.t / _e.tot, 0, 1);
	var _by = obj_area.y + 322;
	var _ap = _fr < .35 and (current_time div 150) mod 2 == 0;
	draw_set_color(#1E1A38);
	draw_rectangle(_cx - 60, _by, _cx + 60, _by + 8, false);
	draw_rectangle_color(_cx - 60, _by, _cx - 60 + 120 * _fr, _by + 8, _ap ? #FF5577 : _cor, _ap ? #FF5577 : _cor, _ap ? #FF5577 : merge_color(_cor, c_white, .4), _ap ? #FF5577 : merge_color(_cor, c_white, .4), false);
	draw_set_color(#5A3A8A);
	draw_rectangle(_cx - 60, _by, _cx + 60, _by + 8, true);
	var _seg = string(ceil(_e.t / room_speed));
	draw_text_transformed_color(_cx + 1, _by + 17, _seg, 1.2, 1.2, 0, _sombra, _sombra, _sombra, _sombra, 1);
	draw_text_transformed_color(_cx, _by + 16, _seg, 1.2, 1.2, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
}

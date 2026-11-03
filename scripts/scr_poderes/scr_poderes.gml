//COLECIONAVEIS A P E D R O P E PODERES==================================
//AS LETRAS DE "APEDROP" APARECEM FORA DE ORDEM: SOLTAS NA ARENA (EM ZIGUE-ZAGUE) OU DENTRO DE UM BLOCO
//(QUANDO O BLOCO QUEBRA, A LETRA SAI). PEGANDO TODAS, O JOGO PAUSA E O JOGADOR ESCOLHE 1 DE 3 PODERES SORTEADOS.
//OS PODERES ACUMULAM (DURAM A PARTIDA TODA)

#macro LETRA_PRIMEIRA		(room_speed * 11)	//PRIMEIRA LETRA DA PARTIDA (10% MAIS RARAS: ERA 10)
#macro LETRA_INTERVALO_INICIO	(room_speed * 14.3)	//ATE GANHAR O 1O PODER: UMA LETRA NOVA A CADA... (MAIS FREQUENTE PRA COMPLETAR O APEDROP. ERA 13)
#macro LETRA_INTERVALO		(room_speed * 27.5)	//COM 1 PODER: UMA LETRA NOVA A CADA... (CADA PODER A MAIS DEIXA MAIS RARO: LETRA_RARIDADE. ERA 25)
#macro LETRA_VIDA			(room_speed * 8)	//TEMPO PRA PEGAR (SOLTA OU DENTRO DO BLOCO). PISCA NOS ULTIMOS 3S E SOME
#macro LETRA_NO_BLOCO		50					//CHANCE (0-100) DA LETRA NASCER DENTRO DE UM BLOCO
#macro PALAVRA_FESTA		(room_speed * 1.8)	//COMPLETOU A PALAVRA: TEMPO DA FESTA NO PAINEL (JOGO PARADO) ANTES DOS PODERES

//REFLEXO (ESQUIVA AUTOMATICA DOS TIROS)
#macro REFLEXO_CUSTO		34		//ENERGIA DE CADA ESQUIVA (A BARRA VAI ATE 100)
#macro REFLEXO_REGEN		.06		//POR FRAME
#macro REFLEXO_LINHA		25		//POR LINHA FECHADA (ENCHE TUDO AO SUBIR DE ANDAR)
#macro REFLEXO_VOLTA		30		//CHANCE (0-100) DA BALA VOLTAR NO LASER QUE ATIROU E DESTRUIR ELE

//ESCUDO
#macro ESCUDO_REGEN			.12		//POR FRAME (A BARRA VAI ATE 100). QUEBRADO, SO VOLTA QUANDO ENCHER
#macro ESCUDO_DANO			40		//TIRO OU ENCOSTAR NO INIMIGO

#macro IMA_RAIO				90		//DISTANCIA QUE O IMA PUXA AS LETRAS

#macro LETRA_RARIDADE		.4		//CADA PODER ALEM DO 1O DEIXA O INTERVALO DAS LETRAS 40% MAIOR
global.letras_nomes = ["A", "P", "E", "D", "R", "O", "P"]; //CADA POSIÇAO E UMA LETRA (AS DUAS "P" SAO SEPARADAS). VER LETRAS_REINICIAR

//PODERES (NOME/DESC: [PORTUGUES, INGLES])
global.poderes_lista = [
	{ id : "asas",			nome : ["ASAS", "WINGS"],					desc : ["PULO DUPLO NO AR", "DOUBLE JUMP"],							cor : #FFFFFF },
	{ id : "dash",			nome : ["DASH", "DASH"],					desc : ["DASH PRA QUALQUER LADO, ATÉ NO AR", "DASH ANY DIRECTION, EVEN MIDAIR"],	cor : #31FCFF },
	{ id : "espiritual",	nome : ["SOCO ESPIRITUAL", "SPIRIT PUNCH"],	desc : ["SOCA FANTASMA E ACERTA ATRÁS DO BLOCO", "PUNCH GHOSTS AND HIT BEHIND BLOCKS"],	cor : #B98CFF },
	{ id : "reflexo",		nome : ["REFLEXO", "REFLEX"],				desc : ["ESQUIVA SOZINHO E REBATE OS TIROS", "AUTO DODGE AND DEFLECT SHOTS"],	cor : #FFE600 },
	{ id : "escudo",		nome : ["ESCUDO", "SHIELD"],				desc : ["BLOQUEIA TIROS E ATAQUES", "BLOCKS SHOTS AND ATTACKS"],		cor : #5CC8FF },
	{ id : "visao",			nome : ["VISÃO ESPIRITUAL", "SPIRIT SIGHT"],	desc : ["VÊ INIMIGOS E SEGREDOS DOS BLOCOS", "SEE ENEMIES AND BLOCK SECRETS"],	cor : #FF7AE0 },
	{ id : "ima",			nome : ["ÍMÃ", "MAGNET"],					desc : ["PUXA AS LETRAS PRA PERTO", "PULLS LETTERS TO YOU"],			cor : #FF5050 },
	{ id : "cabeca",		nome : ["CABEÇADA", "HEADBUTT"],			desc : ["PULA E QUEBRA O BLOCO DE CIMA COM A CABEÇA", "JUMP UP TO BREAK BLOCKS WITH YOUR HEAD"],	cor : #FFA040 },
];

//ICONES DOS PODERES NO HUD (9X9, PIXEL ART): X = COR DO PODER, W = BRANCO
global.poder_icones = {
	asas : [
		".......XX",
		"......X.X",
		".....X.XX",
		"...XX.XX.",
		"..X..XX..",
		".X.XXX...",
		"XXXX.....",
		".XX......",
		".........",
	],
	dash : [
		".........",
		"....XX...",
		"WW...XX..",
		".XXXXXXX.",
		"WW...XX..",
		"....XX...",
		".........",
		".........",
		".........",
	],
	espiritual : [
		"...XXX...",
		"..XXXXX..",
		".XXWXWXX.",
		".XXXXXXX.",
		".XXXXXXX.",
		".XXXXXXX.",
		".X.X.X.X.",
		".........",
		".........",
	],
	reflexo : [
		"....XXX..",
		"...XXW...",
		"..XXX....",
		".XXXXXX..",
		"....XXX..",
		"...XXX...",
		"..XX.....",
		".X.......",
		".........",
	],
	escudo : [
		".XXXXXXX.",
		"XWWXXXXXX",
		"XWXXXXXXX",
		"XXXXXXXXX",
		".XXXXXXX.",
		".XXXXXXX.",
		"..XXXXX..",
		"...XXX...",
		"....X....",
	],
	visao : [
		".........",
		"..XXXXX..",
		".XX...XX.",
		"XX..W..XX",
		"XX.WWW.XX",
		"XX..W..XX",
		".XX...XX.",
		"..XXXXX..",
		".........",
	],
	ima : [
		"WWW...WWW",
		"XXX...XXX",
		"XX.....XX",
		"XX.....XX",
		"XX.....XX",
		"XXX...XXX",
		".XXXXXXX.",
		"..XXXXX..",
		".........",
	],
	cabeca : [
		"...WWW...",
		"..W...W..",
		".........",
		"..XXXXX..",
		".XXXXXXX.",
		".XWXXXWX.",
		".XXXXXXX.",
		"..XXXXX..",
		"...X.X...",
	],
};

//DESENHA O ICONE DO PODER (CANTO DE CIMA ESQUERDO EM _X,_Y; CADA PIXEL VIRA _ESC PIXELS)
//_APAGADO: TUDO NA _COR (SOMBRA DO PODER QUE AINDA NAO TEM)
function poder_icone_desenhar(_id, _x, _y, _esc, _cor, _apagado = false, _a = 1)
{
	if(!variable_struct_exists(global.poder_icones, _id)) exit;
	qc_pixel_garantir(); //PIXEL BRANCO 1X1 (DRAW_RECTANGLE DE 1 PIXEL NAO DESENHA NADA)
	var _ic = global.poder_icones[$ _id];
	//CADA LINHA DO DESENHO E CADA CARACTERE: "." NAO DESENHA, "W" BRANCO, "X" NA COR DO PODER
	for(var r = 0; r < array_length(_ic); r++)
	{
		var _l = _ic[r];
		for(var k = 1; k <= string_length(_l); k++)
		{
			var _ch = string_char_at(_l, k);
			if(_ch == ".") continue;
			draw_sprite_ext(global.qc_pixel, 0, floor(_x) + (k - 1) * _esc, floor(_y) + r * _esc, _esc, _esc, 0, (_ch == "W" and !_apagado) ? c_white : _cor, _a);
		}
	}
}

//O PLAYER JA TEM ESSE PODER?
function tem_poder(_id)
{
	return array_contains(global.poderes, _id);
}

//DADOS DO PODER (NOME, DESCRIÇAO, COR) PELO ID
function poder_info(_id)
{
	for(var i = 0; i < array_length(global.poderes_lista); i++)
	{
		if(global.poderes_lista[i].id == _id) return global.poderes_lista[i];
	}
	return global.poderes_lista[0];
}

//NOME DO PODER NO IDIOMA ATUAL
function poder_nome(_id)
{
	return poder_info(_id).nome[clamp(global.linguagem, 0, 1)];
}

//DESCRIÇAO DO PODER NO IDIOMA ATUAL
function poder_desc(_id)
{
	return poder_info(_id).desc[clamp(global.linguagem, 0, 1)];
}

//GANHA O PODER (ELES ACUMULAM)
function poder_ganhar(_id)
{
	if(!tem_poder(_id)) array_push(global.poderes, _id);
	//GANHAR QUALQUER PODER ENCHE AS BARRAS DO REFLEXO E DO ESCUDO
	with(obj_player)
	{
		reflexo_energia = 100;
		escudo_vida = 100;
		escudo_quebrado = false;
	}
}

//LETRAS==================================

//ZERA AS LETRAS: A PRIMEIRA PALAVRA E APEDROP, DEPOIS DO 1O PODER E SO DROP
function letras_reiniciar()
{
	global.letras_nomes = array_length(global.poderes) > 0 ? ["D", "R", "O", "P"] : ["A", "P", "E", "D", "R", "O", "P"];
	var _n = array_length(global.letras_nomes);
	global.letras = array_create(_n, false);
	global.letra_pop = array_create(_n, 1);
	global.letras2 = array_create(_n, false);	//COOP: AS LETRAS DO PLAYER 2
	global.letra_pop2 = array_create(_n, 1);
	//AS LETRAS QUE TAVAM NA ARENA SAO DA PALAVRA ANTIGA
	with(obj_letra) instance_destroy();
	with(obj_peca) letra = -1;
}

//TEMPO ATE A PROXIMA LETRA: RAPIDO ATE O 1O PODER, DEPOIS VAI FICANDO MAIS RARO A CADA PODER
function letra_intervalo()
{
	//SEM PODER: BEM MAIS FREQUENTE. DEPOIS, QUANTO MAIS PODERES, MAIS RARAS (1 PODER = 25S, 2 = 35S, 3 = 45S...)
	var _n = array_length(global.poderes);
	if(_n == 0) return LETRA_INTERVALO_INICIO;
	return LETRA_INTERVALO * (1 + (_n - 1) * LETRA_RARIDADE);
}

//AS LETRAS DE UM JOGADOR (1 OU 2). NO COOP CADA UM TEM A SUA PALAVRA; NO ARCADE SO EXISTE O 1
function letras_de(_n)
{
	return _n == 2 ? global.letras2 : global.letras;
}

//O "POP" DAS LETRAS NO HUD DE UM JOGADOR
function letra_pop_de(_n)
{
	return _n == 2 ? global.letra_pop2 : global.letra_pop;
}

//O JOGADOR _N PEGOU TODAS AS LETRAS?
function letras_completas(_n = 1)
{
	var _l = letras_de(_n);
	for(var i = 0; i < array_length(_l); i++) if(!_l[i]) return false;
	return true;
}

//SORTEIA UMA LETRA QUE FALTA E QUE AINDA NAO TA NA TELA NEM DENTRO DE UM BLOCO (-1 SE NAO TIVER)
function letra_sortear()
{
	var _opcoes = [];
	for(var i = 0; i < array_length(global.letras); i++)
	{
		//NO COOP A LETRA SO SAI SE ALGUM DOS DOIS AINDA NAO TEM
		if(global.letras[i] and (!global.coop or global.letras2[i])) continue;
		var _ja = false;
		with(obj_letra) if(letra == i) _ja = true;
		with(obj_peca) if(letra == i) _ja = true;
		if(!_ja) array_push(_opcoes, i);
	}
	if(array_length(_opcoes) == 0) return -1;
	return _opcoes[irandom(array_length(_opcoes) - 1)];
}

//LETRA SOLTA NA ARENA (_SAINDO = SAIU DE UM BLOCO: DA UM PULINHO)
function letra_criar(_x, _y, _i, _saindo = false)
{
	var _l = instance_create_depth(_x, _y, -1500, obj_letra);
	_l.letra = _i;
	if(_saindo) _l.velv = -2.5;
	letra_chamar_atencao(_x, _y, _i);
	return _l;
}

//LETRA APARECEU: ANEIS, SOM E O NOME DA LETRA PRA CHAMAR ATENÇAO
function letra_chamar_atencao(_x, _y, _i)
{
	for(var k = 0; k < 2; k++)
	{
		var _a = instance_create_depth(_x, _y, -1900, obj_efeito_pontos);
		_a.modo = "anel";
		_a.timer = 16 + k * 10;
	}
	efeito_texto(global.letras_nomes[_i] + "!", _x, _y - 18, c_yellow, 1.6);
	audio_play_sound(snd_coin, 1, false, 1, 0, 1.4);
}

//COLOCA UMA LETRA NA ARENA: DENTRO DE UM BLOCO PARADO OU SOLTA
function letra_aparecer()
{
	var _i = letra_sortear();
	if(_i == -1 or !instance_exists(obj_area)) exit;

	//METADE DAS VEZES TENTA COLOCAR DENTRO DE UM BLOCO NORMAL PARADO
	if(random(100) < LETRA_NO_BLOCO)
	{
		var _blocos = [];
		with(obj_peca) if(estou_parado and !andar and sou_normal and letra == -1 and destruido_por == noone) array_push(_blocos, id);
		if(array_length(_blocos) > 0)
		{
			with(_blocos[irandom(array_length(_blocos) - 1)])
			{
				letra = _i;
				letra_timer = LETRA_VIDA;
				alpha_fog = 1;
				esc = 1.4;
				letra_chamar_atencao(x, y, _i);
			}
			exit;
		}
	}
	//SEM BLOCO (OU NAO SORTEOU): SOLTA NUM LUGAR ALEATORIO DA METADE DE CIMA DA ARENA
	var _a = obj_area;
	letra_criar(_a.x + 24 + random(_a.sprite_width - 48), _a.y + 40 + random(_a.sprite_height * .5), _i);
}

//O JOGADOR _N PEGOU UMA LETRA. SE ELE JA TEM ESSA LETRA, ELA VIRA UMA MOEDA (NO COOP CADA UM TEM AS SUAS)
function letra_coletar(_i, _x, _y, _n = 1)
{
	var _l = letras_de(_n);
	if(_l[_i])
	{
		moeda_criar(_x, _y, 1);
		efeito_texto(global.linguagem == 0 ? "VIROU MOEDA!" : "TURNED INTO A COIN!", _x, _y - 10, c_yellow, .9);
		som_tocar(snd_coin);
		exit;
	}
	_l[_i] = true;
	letra_pop_de(_n)[_i] = 2;
	//CADA LETRA PEGA TOCA A NOTA SEGUINTE (A PALAVRA VAI "SUBINDO"). COMPLETOU: JINGLE DO PODER
	var _pegas = 0;
	for(var k = 0; k < array_length(_l); k++) if(_l[k]) _pegas++;
	if(letras_completas(_n)) som_tocar(snd_jingle_poder);
	else som_nota(4 + _pegas, .7);
	onda_choque(_x, _y, 34, 3, 18);
	efeito_texto(global.letras_nomes[_i], _x, _y - 10, c_yellow, 1.4);
}

//==================== PODER DE PARAR O TEMPO (ENERGIA CHEIA + TECLA 1) ====================
//O JOGO TODO PARA (A TELA FICA VERDE COM ANEIS DE RELOGIO) E SO O PLAYER SE MEXE POR TEMPO_DURACAO: DA PRA QUEBRAR E EMPURRAR
//BLOCOS, MAS NADA CAI. DEPOIS VEM A CONTAGEM DE 3S E TODOS OS BLOCOS SOLTOS CAEM DE UMA VEZ (DE BAIXO PRA CIMA), ENCAIXANDO
//DO JEITO QUE O JOGADOR ARRUMOU. O CONTROLE CHAMA O TEMPO_ATUALIZAR; O DESENHO FICA NO DRAW_64 E NO DRAW_77 DO OBJ_GAME_CONTROL
#macro TEMPO_DURACAO	(room_speed * 25)	//TEMPO COM TUDO PARADO (DEPOIS VEM A CONTAGEM DE 3S, ONDE O PLAYER AINDA ANDA)
#macro TEMPO_CONTAGEM	(room_speed * 3)
#macro TEMPO_TECLA		ord("1")
#macro TEMPO_VEL_EXTRA	.5		//VELOCIDADE A MAIS DO PLAYER ANDANDO NO TEMPO PARADO
#macro TEMPO_FEIXE		74		//COMPRIMENTO MAXIMO (PX) DO FEIXE DE LUZ DA PREVIA DA QUEDA, SAINDO DE BAIXO DE CADA BLOCO
#macro TEMPO_SOMBRA_VIDA	50		//FRAMES QUE O FEIXE E A SOMBRA VERDE DO TELEPORTE DEMORAM PRA SUMIR
#macro TEMPO_VERDE		#3CFF8C

//O PLAYER PODE ANDAR AGORA? (TEMPO PARADO OU NA CONTAGEM, E NENHUMA PAUSA DE VERDADE)
function tempo_player_livre()
{
	return (global.tempo_fase == "parado" or global.tempo_fase == "contagem") and !global.pausa_real;
}

//O TEMPO TA PARADO (QUALQUER FASE DO PODER)?
function tempo_ativo()
{
	return global.tempo_fase != "";
}

//APERTOU 1 COM A ENERGIA CHEIA: PARA O TEMPO (A ENERGIA ESVAZIA COM O TEMPO)
function tempo_parar()
{
	habil_aprender("tempo");
	global.tempo_fase = "parado"; //A ENERGIA VAI ESVAZIANDO SOZINHA ENQUANTO O TEMPO ESTA PARADO (TEMPO_ATUALIZAR)
	global.tempo_timer = TEMPO_DURACAO;
	global.tempo_t = 0;
	global.tempo_flash = 1;
	var _p = player_perto(room_width / 2, room_height / 2);
	global.tempo_cx = _p != noone ? _p.x : room_width / 2;
	global.tempo_cy = _p != noone ? _p.y - 10 : room_height / 2;
	onda_choque(global.tempo_cx, global.tempo_cy, 280, 9, 55);
	shakes(10, 3);
	audio_play_sound(snd_feitico, 2, false, 1, 0, .55);
	audio_play_sound(zap1, 1, false, .8, 0, .5);
	with(obj_player)
	{
		alpha_fog = 1; esc_x = 1.4 * image_xscale; esc_y = .7;
		if(!tem_poder("asas")) efeito_texto(global.linguagem == 0 ? "PULO DUPLO!" : "DOUBLE JUMP!", x, y - 30, TEMPO_VERDE, 1.2);
	}
}

//COMEÇA A QUEDA: TODOS OS BLOCOS SOLTOS SE TELEPORTAM DE UMA VEZ PRO LUGAR ONDE VAO FICAR (IGUAL AO TELEPORTE DAS PEÇAS)
function tempo_iniciar_queda()
{
	global.tempo_fase = "queda";
	global.tempo_flash = .8;
	global.tempo_dicas = [];
	global.tempo_rastros = [];
	global.tempo_sombras = [];
	//ENCAIXA TODO MUNDO NA GRADE
	with(obj_peca) if(destruido_por == noone)
	{
		x = grid_alinhar_x(prox_x);
		prox_x = x;
		y = grid_alinhar_y_cima(y);
		gel_quicando = false;
		tempo_q = 0;
	}
	var _plano = tempo_simular_queda();
	var _moveu = 0;
	for(var g = 0; g < array_length(_plano); g++)
	{
		var _m = _plano[g].m, _q = _plano[g].q;
		if(_q <= 0) continue;
		//TOPO E FUNDO DE CADA COLUNA DO GRUPO (UM RASTRO DE TELEPORTE POR COLUNA)
		var _topos = {}, _fundos = {};
		for(var i = 0; i < array_length(_m); i++)
		{
			with(_m[i])
			{
				esvaziar_grid();
				var _y0 = y;
				var _k = string(x);
				if(!variable_struct_exists(_topos, _k) or y < _topos[$ _k]) _topos[$ _k] = y;
				y += _q;
				if(!variable_struct_exists(_fundos, _k) or y > _fundos[$ _k]) _fundos[$ _k] = y;
				//FEIXE E SOMBRA VERDE SAINDO DESSE BLOCO (DESENHADOS NO OBJ_AREA)
				array_push(global.tempo_sombras, { x : x, y0 : _y0, y1 : y, spr : variable_instance_exists(id, "ult_spr") ? ult_spr : spr_peca, img : variable_instance_exists(id, "ult_img") ? ult_img : 0, idade : 0 });
				prox_y = y + CEL;
				velv = 0;
				velh = 0;
				andar = false;
				estou_parado = false;
				timer_move = meu_timer;
				inicializando = 0;
				esc = 1.2;
				alpha_fog = 1;
			}
		}
		//IMPACTO NO CHAO DE CADA COLUNA (O FEIXE E A SOMBRA VERDE SAEM DE CADA BLOCO: VER TEMPO_SOMBRAS)
		var _ks = variable_struct_get_names(_fundos);
		for(var i = 0; i < array_length(_ks); i++)
		{
			var _im = instance_create_depth(real(_ks[i]), _fundos[$ _ks[i]] + CEL / 2, -1800, obj_efeito_pontos);
			_im.modo = "tele";
			_im.y_chao = _im.y;
		}
		_moveu++;
	}
	if(_moveu > 0)
	{
		tempo_tirar_player();
		audio_play_sound(snd_acelerar_peca, 1, false, .8, 0, 1);
		shakes(8, 2);
	}
	som_tocar(snd_certo);
	audio_play_sound(snd_feitico, 2, false, 1, 0, 1.3);
	if(instance_exists(obj_area)) onda_choque(obj_area.x + obj_area.sprite_width / 2, obj_area.y + obj_area.sprite_height / 2, 220, 8, 40);
}

//APERTOU 1 DE NOVO COM O TEMPO PARADO: ENCERRA ANTES, SEM A CONTAGEM (OS BLOCOS CAEM NA HORA). A ENERGIA QUE SOBROU FICA GUARDADA
function tempo_encerrar()
{
	if(global.tempo_fase != "parado") exit;
	tempo_iniciar_queda();
}

//BLOCOS DE UM GRUPO (A PEÇA INTEIRA, OU SO O BLOCO SE ELE TA SOZINHO)
function tempo_membros(_l)
{
	if(!instance_exists(_l)) return [];
	if(!_l.irmandade) return [_l];
	var _r = [];
	var _todos = _l.irmaos();
	for(var i = 0; i < array_length(_todos); i++) if(_todos[i].irmandade and _todos[i].pai == _l and _todos[i].destruido_por == noone) array_push(_r, _todos[i]);
	if(array_length(_r) == 0) _r = [_l];
	return _r;
}

//CASA OCUPADA POR ALGO QUE NAO E DO GRUPO (CHAO, PAREDE OU OUTRO BLOCO)
function tempo_ocupado(_x, _y, _membros)
{
	var _x1 = _x - CEL / 2 + 1, _y1 = _y - CEL / 2 + 1, _x2 = _x + CEL / 2 - 2, _y2 = _y + CEL / 2 - 2;
	if(collision_rectangle(_x1, _y1, _x2, _y2, [obj_block, obj_parede], false, true)) return true;
	var _lista = ds_list_create();
	var _n = collision_rectangle_list(_x1, _y1, _x2, _y2, obj_peca, false, true, _lista, false);
	var _ocupado = false;
	for(var i = 0; i < _n; i++) if(!array_contains(_membros, _lista[| i]) and _lista[| i].destruido_por == noone) { _ocupado = true; break; }
	ds_list_destroy(_lista);
	return _ocupado;
}

//QUANTO O GRUPO CAIRIA (EM PIXELS) DA POSICAO ALINHADA ATUAL, SEM MEXER NELE
function tempo_queda_de(_m)
{
	var _limite = obj_area.y + obj_area.sprite_height;
	var _queda = 0;
	repeat(40)
	{
		var _prox = _queda + CEL, _livre = true;
		for(var i = 0; i < array_length(_m) and _livre; i++)
		{
			var _yy = grid_alinhar_y_cima(_m[i].y) + _prox;
			if(_yy > _limite or tempo_ocupado(grid_alinhar_x(_m[i].x), _yy, _m)) _livre = false;
		}
		if(!_livre) break;
		_queda = _prox;
	}
	return _queda;
}

//DICA: QUAIS GRUPOS COMPLETAM UMA LINHA SE CAIREM DO JEITO QUE TAO (A BORDA DELES BRILHA NO TEMPO PARADO)
function tempo_dica_calcular()
{
	var _res = [];
	global.tempo_dicas = _res;
	if(!instance_exists(obj_area)) exit;
	var _grupos = [];
	with(obj_peca) if(destruido_por == noone)
	{
		var _l = (irmandade and instance_exists(pai)) ? pai : id;
		if(!array_contains(_grupos, _l)) array_push(_grupos, _l);
	}
	for(var g = 0; g < array_length(_grupos); g++)
	{
		var _m = tempo_membros(_grupos[g]);
		var _q = tempo_queda_de(_m);
		//LINHAS (Y) E CASAS (X,Y) QUE O GRUPO OCUPA QUANDO POUSAR
		var _casas = [], _ys = [];
		for(var i = 0; i < array_length(_m); i++)
		{
			var _cy = grid_alinhar_y_cima(_m[i].y) + _q, _cx = grid_alinhar_x(_m[i].x);
			array_push(_casas, [_cx, _cy]);
			if(!array_contains(_ys, _cy)) array_push(_ys, _cy);
		}
		var _completa = false;
		for(var r = 0; r < array_length(_ys) and !_completa; r++)
		{
			var _cheia = true;
			for(var j = 0; j < obj_area.cols and _cheia; j++)
			{
				var _px = obj_area.x + CEL / 2 + j * CEL, _meu = false;
				for(var c = 0; c < array_length(_casas); c++) if(_casas[c][0] == _px and _casas[c][1] == _ys[r]) { _meu = true; break; }
				if(!_meu and !tempo_ocupado(_px, _ys[r], _m)) _cheia = false;
			}
			_completa = _cheia;
		}
		if(_completa) for(var i = 0; i < array_length(_m); i++) array_push(_res, _m[i]);
	}
	global.tempo_dicas = _res;
}

//SIMULA A QUEDA: ONDE CADA GRUPO VAI PARAR (OS DE BAIXO PRIMEIRO, ATE NINGUEM MAIS MEXER). NAO MEXE EM NADA DE VERDADE:
//GUARDA AS POSICOES, ENCAIXA NA GRADE, "CAI" NA CONTA E DEVOLVE TUDO. DEVOLVE UM ARRAY DE { m : BLOCOS DO GRUPO, q : PIXELS QUE CAI }
function tempo_simular_queda()
{
	var _salvo = [];
	with(obj_peca) if(destruido_por == noone) array_push(_salvo, [id, x, y]);
	for(var i = 0; i < array_length(_salvo); i++)
	{
		with(_salvo[i][0])
		{
			x = grid_alinhar_x(prox_x);
			y = grid_alinhar_y_cima(y);
		}
	}
	var _grupos = [];
	with(obj_peca) if(destruido_por == noone)
	{
		var _l = (irmandade and instance_exists(pai)) ? pai : id;
		if(!array_contains(_grupos, _l)) array_push(_grupos, _l);
	}
	var _res = [];
	for(var g = 0; g < array_length(_grupos); g++) array_push(_res, { m : tempo_membros(_grupos[g]), q : 0 });
	//DE BAIXO PRA CIMA. UM GRUPO PODE LIBERAR OUTRO, ENTAO REPETE ATE NINGUEM MAIS MEXER
	var _fundo = function(_r) { var _f = -infinity; for(var i = 0; i < array_length(_r.m); i++) _f = max(_f, _r.m[i].y); return _f; };
	repeat(6)
	{
		var _moveu = false;
		array_sort(_res, method({ f : _fundo }, function(_a, _b) { return f(_b) - f(_a); }));
		for(var g = 0; g < array_length(_res); g++)
		{
			var _q = tempo_queda_de(_res[g].m);
			if(_q <= 0) continue;
			for(var i = 0; i < array_length(_res[g].m); i++) _res[g].m[i].y += _q;
			_res[g].q += _q;
			_moveu = true;
		}
		if(!_moveu) break;
	}
	for(var i = 0; i < array_length(_salvo); i++)
	{
		_salvo[i][0].x = _salvo[i][1];
		_salvo[i][0].y = _salvo[i][2];
	}
	return _res;
}

//GUARDA EM CADA BLOCO QUANTO ELE VAI CAIR (TEMPO_Q) E MONTA OS RASTROS DA PREVIA: UM FEIXE DE LUZ POR COLUNA SO NOS BLOCOS QUE CAEM NO CHAO, SEM UM SOBREPOR O OUTRO
function tempo_planejar()
{
	with(obj_peca) tempo_q = 0;
	var _plano = tempo_simular_queda();
	var _cols = {};
	for(var g = 0; g < array_length(_plano); g++)
	{
		if(_plano[g].q <= 0) continue;
		for(var i = 0; i < array_length(_plano[g].m); i++)
		{
			var _b = _plano[g].m[i];
			_b.tempo_q = _plano[g].q;
			var _y1 = grid_alinhar_y_cima(_b.y);
			//SO OS BLOCOS QUE CAEM DIRETO NO BLOCO CHAO (OBJ_BLOCK) GANHAM FEIXE: ELES AJUDAM A FECHAR A LINHA PRINCIPAL
			var _k = string(grid_alinhar_x(_b.prox_x));
			var _fx = real(_k), _fy = _y1 + _plano[g].q;
			if(!collision_rectangle(_fx - 4, _fy + CEL - 4, _fx + 4, _fy + CEL + 4, obj_block, false, true)) continue;
			if(!variable_struct_exists(_cols, _k)) _cols[$ _k] = [];
			array_push(_cols[$ _k], [_y1, _y1 + min(_plano[g].q, TEMPO_FEIXE)]); //O FEIXE NAO PRECISA IR ATE O FIM
		}
	}
	//JUNTA OS TRECHOS DA MESMA COLUNA QUE SE ENCOSTAM/SOBREPOEM (VIRA UMA LINHA SO)
	var _rastros = [];
	var _ks = variable_struct_get_names(_cols);
	for(var c = 0; c < array_length(_ks); c++)
	{
		var _t = _cols[$ _ks[c]];
		array_sort(_t, function(_a, _b) { return _a[0] - _b[0]; });
		var _ini = _t[0][0], _fim = _t[0][1];
		for(var i = 1; i < array_length(_t); i++)
		{
			if(_t[i][0] <= _fim) _fim = max(_fim, _t[i][1]);
			else { array_push(_rastros, [real(_ks[c]), _ini, _fim]); _ini = _t[i][0]; _fim = _t[i][1]; }
		}
		array_push(_rastros, [real(_ks[c]), _ini, _fim]);
	}
	global.tempo_rastros = _rastros;
}

//PLAYER EMBAIXO DE UM BLOCO QUE CAIU: SOBE ELE PRA CIMA DA PEÇA (SENAO FICA PRESO DENTRO E LEVA DANO)
function tempo_tirar_player()
{
	with(obj_player)
	{
		var _eu = id, _n = 0, _preso = true;
		while(_preso and _n < 400)
		{
			_preso = false;
			with(obj_peca) if(!sou_fantasma and destruido_por == noone and place_meeting(x, y, _eu)) _preso = true;
			if(_preso) { _eu.y--; _n++; }
		}
		if(_n > 0) { velv = 0; esc_x = .8 * image_xscale; esc_y = 1.25; }
	}
}

//RODA TODO FRAME NO OBJ_GAME_CONTROL (MENOS NA PAUSA DE VERDADE): CONTA O TEMPO, A CONTAGEM E FAZ A QUEDA
function tempo_atualizar()
{
	if(global.tempo_fase == "") exit;
	global.tempo_t++;
	if(global.tempo_t mod 6 == 1 and (global.tempo_fase == "parado" or global.tempo_fase == "contagem")) { tempo_planejar(); tempo_dica_calcular(); }
	desafio_segurar(true); //NADA NASCE NEM ANDA (OS ALARMES FICAM SEGURADOS)
	switch(global.tempo_fase)
	{
		case "parado":
			global.tempo_timer--;
			global.energia = max(0, global.energia - ENERGIA_MAX / TEMPO_DURACAO); //A BARRA ESVAZIA ATE ZERAR NO FIM DO TEMPO
			//TIQUE DO RELOGIO A CADA SEGUNDO (MAIS FORTE NOS 3 ULTIMOS)
			if(global.tempo_timer > 0 and global.tempo_timer mod room_speed == 0) audio_play_sound(Bip_2, 1, false, global.tempo_timer <= room_speed * 3 ? .8 : .35, 0, .7);
			//(A CONTAGEM 3, 2, 1 APARECE NOS ULTIMOS 3S DO TEMPO PARADO: NO DRAW_64)
			if(global.tempo_timer <= 0) tempo_iniciar_queda();
			break;
		case "contagem":
			global.tempo_timer--;
			if(global.tempo_timer > 0 and global.tempo_timer mod room_speed == 0) som_tocar(Bip_2);
			if(global.tempo_timer <= 0)
			{
				tempo_iniciar_queda();
			}
			break;
		case "queda":
			//OS BLOCOS JA SE TELEPORTARAM (TEMPO_INICIAR_QUEDA): O JOGO VOLTA E AS LINHAS FECHADAS CONTAM NA HORA
			global.tempo_fase = "";
			shakes(12, 3);
			with(obj_area) alarm[0] = max(alarm[0], room_speed);
			break;
	}
}

//==================== GUIA DO JOGADOR ====================
//O JOGO GUIA O JOGADOR DE DOIS JEITOS DISCRETOS.
//1) TIRA DE COMANDOS NO RODAPE (TECLAS_DESENHAR, NO DRAW_64): AS TECLAS DAS AÇOES PASSAM DEVAGAR PRA UM LADO, SEMPRE. AS QUE O
//   JOGADOR AINDA NAO USOU FICAM CLARAS (ALPHA 1); QUANDO ELE USA UMA, ELA DA UMA PISCADINHA DE "DESCOBERTA" E FICA COM ALPHA .5
//   NA PARTIDA (O HISTORICO ZERA TODA VEZ QUE UMA PARTIDA COMEÇA: HABIL_ZERAR). ASSIM ELE SEMPRE ENCONTRA A TECLA SE ESQUECER.
//   DA PRA LIGAR/DESLIGAR A TIRA NAS CONFIGURAÇOES E NA PAUSA (GLOBAL.MOSTRAR_TECLAS).
//2) GUIA DA PRIMEIRA LINHA (GUIA_LINHA_DESENHAR): ENQUANTO O JOGADOR NUNCA FECHOU UMA LINHA, A LINHA QUE FICA EM CIMA DO CHAO BRILHA
//   DE LEVE, COM UMA SETA DE CADA LADO APONTANDO PRA ELA. DEPOIS DA 1A LINHA FECHADA (NA PARTIDA) SOME.

//O JOGADOR JA SABE FAZER ISSO?
function habil_ok(_id)
{
	return global.habil[$ _id];
}

//APRENDEU (SO VALE NA PARTIDA ATUAL). GUARDA A HORA PRA TECLA DA TIRA DAR A PISCADINHA
function habil_aprender(_id)
{
	if(global.habil[$ _id]) return;
	global.habil[$ _id] = true;
	global.habil_t[$ _id] = current_time;
}

//COMEÇOU UMA PARTIDA: ZERA O QUE O JOGADOR "JA DESCOBRIU" (AS TECLAS DA TIRA VOLTAM A FICAR CLARAS E O GUIA DA 1A LINHA VOLTA)
function habil_zerar()
{
	var _n = variable_struct_get_names(global.habil);
	for(var i = 0; i < array_length(_n); i++) global.habil[$ _n[i]] = false;
	global.habil_t = {};
}

//RODA TODO FRAME NO STEP DO PLAYER (FORA DE PAUSA): ANOTA O QUE ELE JA FEZ
function ensino_player_atualizar()
{
	if(abs(velh) > .5 or keyboard_check_pressed(imp.left) or keyboard_check_pressed(imp.rigth)) habil_aprender("mover");
	if(estado == state.jump and velv < -1.5) habil_aprender("pulou");
	if(estado == state.soco) habil_aprender("socou");
	if(estado == state.super_soco) habil_aprender("soco_forte");
	if(estado == state.giro) habil_aprender("girou");
	if(giro_lat) habil_aprender("giro_lat");
}

//--------------------- GUIA DA PRIMEIRA LINHA ---------------------
//ENQUANTO O JOGADOR NUNCA FECHOU UMA LINHA NA PARTIDA: A LINHA QUE FICA EM CIMA DO CHAO BRILHA DE LEVE E UMA SETA DE CADA LADO
//APONTA PRA ELA. (O CHAO SOBE A CADA LINHA QUE CONTA NO ANDAR, ENTAO A LINHA E: LINHAS DA ARENA - 1 - LINHAS COMPLETADAS.)
//DESENHADO NA GUI (DRAW_64) PRA FICAR POR CIMA DE TUDO. FICA ESCONDIDO NA PAUSA, NO TEMPO PARADO E NO COOP
function guia_linha_desenhar()
{
	if(habil_ok("linha") or !modo_arcade() or modo_versus() or global.coop or MOBILE or !instance_exists(obj_area) or tempo_ativo()) exit;
	var _a = obj_area;
	var _e = gui_esc();
	var _linha = _a.lins - 1 - global.linhas_completadas;
	if(_linha < 0) exit;
	var _cy = _a.y + CEL / 2 + _linha * CEL;
	var _x1 = _a.x, _x2 = _a.x + _a.sprite_width;
	var _pulso = .5 + .5 * sin(current_time / 260);

	//BRILHO LEVE NA LINHA INTEIRA (SOMA DE LUZ, BEM FRACO)
	gpu_set_blendmode(bm_add);
	draw_set_color(TEMPO_VERDE);
	draw_set_alpha(.06 + .07 * _pulso);
	draw_rectangle(_x1 * _e, (_cy - CEL / 2) * _e, _x2 * _e, (_cy + CEL / 2) * _e, false);
	draw_set_alpha(.2 + .2 * _pulso);
	draw_rectangle(_x1 * _e, (_cy - CEL / 2) * _e, _x2 * _e, (_cy - CEL / 2 + 1) * _e, false);
	draw_rectangle(_x1 * _e, (_cy + CEL / 2 - 1) * _e, _x2 * _e, (_cy + CEL / 2) * _e, false);
	gpu_set_blendmode(bm_normal);

	//SETAS: UMA DE CADA LADO DA ARENA, APONTANDO PRA LINHA E BALANÇANDO DEVAGAR
	var _bal = sin(current_time / 200) * 2;
	draw_set_alpha(.55 + .35 * _pulso);
	draw_set_color(TEMPO_VERDE);
	//ESQUERDA (APONTA PRA DIREITA)
	var _ax = _x1 - 6 + _bal;
	draw_triangle((_ax - 8) * _e, (_cy - 6) * _e, (_ax - 8) * _e, (_cy + 6) * _e, _ax * _e, _cy * _e, false);
	//DIREITA (APONTA PRA ESQUERDA)
	_ax = _x2 + 6 - _bal;
	draw_triangle((_ax + 8) * _e, (_cy - 6) * _e, (_ax + 8) * _e, (_cy + 6) * _e, _ax * _e, _cy * _e, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

//--------------------- TIRA DE COMANDOS (RODAPE) ---------------------
//DESENHA A TIRA NO RODAPE DA TELA (GUI). CHAMADO NO DRAW_64 DO OBJ_GAME_CONTROL. SO NO ARCADE SOLO NO PC
function teclas_desenhar()
{
	if(!global.mostrar_teclas or !modo_arcade() or modo_versus() or global.coop or MOBILE) exit;
	var _e = gui_esc();
	var _i = global.imputs;
	var _pt = global.linguagem == 0;
	//[HABILIDADE (PRA SABER SE JA DESCOBRIU), TECLA]
	var _itens = [
		["mover",		tecla_nome(_i.left) + " " + tecla_nome(_i.rigth)],
		["pulou",		tecla_nome(_i.jump)],
		["socou",		tecla_nome(_i.soco)],
		["soco_forte",	tecla_nome(_i.soco_press)],
		["girou",		tecla_nome(_i.giro)],
		["teleporte",	tecla_nome(_i.acelerar)],
	];
	draw_set_font(fnt_hud);
	draw_set_valign(fa_middle);
	var _esc = .55;
	//LARGURA DE CADA TECLA E POSIÇAO DELA NA ESTEIRA (30PX ENTRE UMA E OUTRA). A ESTEIRA E UM CIRCULO MAIOR QUE A TELA: CADA TECLA
	//QUE SOME NA ESQUERDA JA REAPARECE NA DIREITA (NENHUMA REPETIDA NA TELA)
	var _larg = [], _pos = [], _total = 0;
	for(var k = 0; k < array_length(_itens); k++)
	{
		var _kw = max(12, string_width(_itens[k][1]) * _esc + 8);
		array_push(_larg, _kw);
		array_push(_pos, _total);
		_total += _kw + 30;
	}
	var _volta = max(room_width + 60, _total);
	//FAIXA ESCURA FININHA ATRAS (FICA NO RODAPE DA TELA, NAO COBRE A ARENA)
	var _yc = 396;
	draw_set_color(#0E071B);
	draw_set_alpha(.55);
	draw_rectangle(0, (_yc - 8) * _e, room_width * _e, (_yc + 9) * _e, false);
	draw_set_alpha(1);
	//ANDA DEVAGAR PRA ESQUERDA (18 PX POR SEGUNDO)
	var _desloc = current_time * 0.018;
	for(var k = 0; k < array_length(_itens); k++)
	{
		var _id = _itens[k][0];
		var _sabe = global.habil[$ _id];
		//AINDA NAO DESCOBRIU: ALPHA 1. DESCOBRIU: PISCADINHA (UM CLARAO QUE VAI SUMINDO) E FICA COM .5 PRA SEMPRE
		var _al = 1;
		var _pop = 0;
		if(_sabe)
		{
			_al = .5;
			if(variable_struct_exists(global.habil_t, _id))
			{
				_pop = max(0, 1 - (current_time - global.habil_t[$ _id]) / 700);
				_al = .5 + .5 * _pop;
			}
		}
		var _kw = _larg[k];
		var _x = ((_pos[k] - _desloc) mod _volta + _volta) mod _volta - _kw - 20;
		var _kx = _x + _kw / 2;
		//TECLA: QUADRADINHO ESCURO, CONTORNO E O TEXTO (CRESCE UM POUCO NA PISCADA)
		var _g = _pop * 2;
		draw_set_color(#1B1038);
		draw_set_alpha(_al);
		draw_rectangle((_x - _g) * _e, (_yc - 6 - _g) * _e, (_x + _kw + _g) * _e, (_yc + 6 + _g) * _e, false);
		draw_set_color(_sabe ? c_white : TEMPO_VERDE);
		draw_rectangle((_x - _g) * _e, (_yc - 6 - _g) * _e, (_x + _kw + _g) * _e, (_yc + 6 + _g) * _e, true);
		draw_set_alpha(1);
		draw_set_halign(fa_center);
		draw_text_transformed_color(_kx * _e, _yc * _e, _itens[k][1], _e * _esc, _e * _esc, 0, c_white, c_white, c_white, c_white, _al);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

//==================== ZORG, O ALIEN QUE CONTROLA A GRADE ====================
//NOS MOMENTOS MAIORES (LASER, MINI GAME, PEÇAS MAIS RAPIDAS, CHUVA DE PEÇAS, PERIGO, MORTE, E QUANDO O JOGADOR VAI BEM) UM PAINEL COM O ROSTO DE UM ALIEN ENTRA
//PELO LADO ESQUERDO DA TELA E SOLTA UMA FRASE MALVADA, COMO NOS JOGOS ANTIGOS. SO ISSO: NAO PAUSA, NAO PEDE ENTER.
//TODAS AS FRASES FICAM EM ZORG_FRASES (MUDAR TEXTO OU CARA E SO MEXER LA). ZORG_FALAR("EVENTO") E CHAMADO NOS PONTOS DO JOGO.
//PRA TIRAR O ZORG SEM APAGAR CODIGO: ZORG_ATIVO = FALSE.
//A ARTE AINDA NAO EXISTE: ZORG_CARA DESENHA UMA CARINHA POR CODIGO. QUANDO A SPRITE "SPR_ALIEN_CARA" EXISTIR NO PROJETO
//(UM FRAME POR EXPRESSAO: 0 SORRISO MALVADO, 1 RINDO, 2 IRRITADO) ELA ENTRA SOZINHA NO LUGAR DO DESENHO.
#macro ZORG_ATIVO		true
#macro ZORG_ESPERA		(room_speed * 20)	//TEMPO MINIMO ENTRE UMA FALA E OUTRA (PRA NAO FICAR REPETITIVO)
#macro ZORG_FONTE_TAM	16					//TAMANHO DA FONTE IMPACT (A ESCALA DE CADA FRASE E ESCOLHIDA SOZINHA PRA CABER NA FAIXA)
#macro ZORG_ANGULO		26					//INCLINAÇAO DA FAIXA AMARELA E DA FRASE (GRAUS, SOBE PRA DIREITA)
#macro ZORG_FAIXA_COMP	260					//COMPRIMENTO DA FAIXA (COMEÇA UM POUCO FORA DA TELA)
#macro ZORG_FAIXA_ESP	96					//ESPESSURA DA FAIXA
#macro ZORG_FAIXA_RECUO	38					//ONDE A FRASE COMEÇA NA FAIXA (A PARTIR DO COMEÇO DELA)
#macro ZORG_FAIXA_W		196					//LARGURA MAXIMA DA FRASE (PX)
#macro ZORG_FAIXA_H		58					//ALTURA MAXIMA DA FRASE (PX)
#macro ZORG_VEL_TEXTO	.7					//LETRAS POR FRAME NA MAQUINA DE ESCREVER
#macro ZORG_INICIO_S	.4					//SEGUNDOS DE PARTIDA ATE ELE SE APRESENTAR (NO COMEÇO: A 1A PEÇA SO NASCE QUANDO ELE SOME)

global.zorg = undefined;	//A FALA NA TELA AGORA (UNDEFINED = ESCONDIDO)
global.zorg_cd = 0;			//FRAMES ATE ELE PODER FALAR DE NOVO
global.zorg_inicio = false;	//JA SE APRESENTOU NESSA PARTIDA?
global.zorg_ultima = "";	//ULTIMA FRASE (PRA NAO REPETIR NA SEQUENCIA)
global.zorg_intro = false;	//ELE AINDA VAI SE APRESENTAR (OU ESTA SE APRESENTANDO): A 1A PEÇA FICA ESPERANDO (OBJ_AREA, ALARM 0)
global.zorg_trava = false;	//A CENA DA QUEDA TRAVA OS COMANDOS DO PLAYER ATE ELE POUSAR

//COMEÇOU A PARTIDA (CHAMADO NO CREATE DO OBJ_GAME_CONTROL)
function zorg_iniciar()
{
	global.zorg = undefined;
	global.zorg_cd = 0;
	global.zorg_inicio = false;
	global.zorg_ultima = "";
	//ELE ABRE A PARTIDA: A PRIMEIRA PEÇA SO NASCE DEPOIS DA FALA DELE
	global.zorg_intro = ZORG_ATIVO and modo_arcade() and !modo_versus();
	//A ABERTURA: O PERSONAGEM CAI DE CIMA E O ZORG APARECE NO PULINHO (ZORG_QUEDA_ATUALIZAR)
	global.zq = global.zorg_intro ? { sub : 0, t : 0 } : undefined;
	global.zorg_trava = false;
}

//A 1A PEÇA DEVE ESPERAR? (OBJ_AREA, ALARM 0). SO ENQUANTO ELE SE APRESENTA. TRAVA DE SEGURANÇA: DEPOIS DE 12S DE PARTIDA SOLTA SEMPRE
function zorg_segurando()
{
	return global.zorg_intro and global.tempo_partida < 16;
}

//AS FRASES DE CADA EVENTO
function zorg_frases(_ev)
{
	switch(_ev)
	{
		case "inicio":		return ["BEM-VINDO À MINHA JAULA, {N}.", "EU CONTROLO CADA BLOCO. VOCÊ NÃO VAI SUBIR."];
		case "laser":		return ["SINTA O CALOR, {N}!", "MIRA {NO} {N}! FOGO!", "NÃO PISQUE. SERIA A SUA ÚLTIMA VEZ.", "ESSE EU MIREI DIREITINHO."];
		case "minigame":	return ["QUE TAL UM JOGUINHO? PERDER DÓI.", "RESOLVA, SE FOR TÃO ESPERTO.", "{O} {N} PODE SAIR PARA BRINCAR?"];
		case "rapido":		return ["ACELEREI A GRADE. DE NADA.", "MAIS RÁPIDO, {N}! O TEMPO É MEU ALIADO.", "SUAS PERNAS JÁ ESTÃO CANSADAS?"];
		case "onda":		return ["CHUVA DE BLOCOS!", "UM POUCO DE DIVERSÃO."];
		case "perigo":		return ["JÁ ESTÁ NO TOPO... É O FIM.", "DESISTA, {N}.", "VOCÊ NÃO VAI SUBIR."];
		case "morte":		return ["EU DISSE QUE VOCÊ NÃO SUBIA.", "FIM DE JOGO, {N}. A JAULA VENCEU.", "TENTE DE NOVO. EU GOSTO DE VER VOCÊ CAIR."];
		case "combo":		return ["IMPOSSÍVEL! COMO FEZ ISSO?!", "SORTE DE INICIANTE. SÓ ISSO."];
		case "level":		return ["ISSO NÃO ERA PRA ACONTECER...", "VOCÊ AINDA VAI ENGASGAR, {N}."];
		case "palavra":		return ["DEVOLVE ESSE PODER!", "ISSO ERA MEU! VOCÊ ME PAGA!"];
		case "frio":		return ["SENTE O FRIO, {N}?", "A JAULA ESTÁ CONGELANDO. QUE PENA.", "TUDO VIRA GELO. ESCORREGA, {N}!"];
	}
	return [];
}

//A CARA DE CADA EVENTO: 0 SORRISO MALVADO, 1 RINDO, 2 IRRITADO (QUANDO O JOGADOR VAI BEM)
function zorg_cara_do_evento(_ev)
{
	switch(_ev)
	{
		case "laser": case "minigame": case "rapido": case "onda": case "morte": case "frio":	return 1;
		case "combo": case "level": case "palavra":					return 2;
	}
	return 0;
}

//QUEBRA O TEXTO EM LINHAS QUE CABEM NA CAIXA DELE
function zorg_quebrar(_txt, _larg)
{
	var _palavras = string_split(_txt, " ");
	var _linha = "", _res = "";
	for(var i = 0; i < array_length(_palavras); i++)
	{
		var _t = _linha == "" ? _palavras[i] : _linha + " " + _palavras[i];
		if(string_width(_t) > _larg and _linha != "")
		{
			_res += _linha + "\n";
			_linha = _palavras[i];
		}
		else _linha = _t;
	}
	return _res + _linha;
}

//A FONTE DO ZORG: IMPACT (PESADA, DE CARTAZ). CARREGADA DO SISTEMA NA 1A VEZ (WINDOWS SEMPRE TEM). SE NAO DER, USA A FONTE DO HUD
global.zorg_font = -1;
function zorg_fonte()
{
	if(global.zorg_font == -1)
	{
		global.zorg_font = fnt_hud;
		try
		{
			var _f = font_add("Impact", ZORG_FONTE_TAM, false, false, 32, 255);
			if(_f != -1 and font_exists(_f)) global.zorg_font = _f;
		}
		catch(_erro) { }
	}
	return global.zorg_font;
}

//ESCOLHE O MAIOR TAMANHO EM QUE A FRASE CABE NA FAIXA AMARELA (QUEBRANDO EM LINHAS). DEVOLVE O TEXTO JA QUEBRADO E A ESCALA
function zorg_ajustar(_frase)
{
	draw_set_font(zorg_fonte());
	var _escalas = [1.7, 1.5, 1.35, 1.2, 1.05, .9, .8, .7, .6, .5];
	var _txt = _frase, _esc = .5;
	for(var i = 0; i < array_length(_escalas); i++)
	{
		var _s = _escalas[i];
		var _q = zorg_quebrar(_frase, ZORG_FAIXA_W / _s);
		_txt = _q;
		_esc = _s;
		if(string_height(_q) * _s <= ZORG_FAIXA_H and string_width(_q) * _s <= ZORG_FAIXA_W) break;
	}
	return { txt : _txt, esc : _esc };
}

//O ZORG APARECE E FALA (_FORCAR = IGNORA O TEMPO ENTRE FALAS E SUBSTITUI A QUE ESTA NA TELA, EX: A MORTE)
function zorg_falar(_ev, _forcar = false)
{
	if(!ZORG_ATIVO or !modo_arcade() or modo_versus()) return;
	if(!_forcar and (global.zorg_cd > 0 or !is_undefined(global.zorg))) return;
	var _frases = zorg_frases(_ev);
	if(array_length(_frases) == 0) return;
	//SORTEIA UMA FRASE DIFERENTE DA ULTIMA
	var _f = _frases[irandom(array_length(_frases) - 1)];
	if(array_length(_frases) > 1) while(_f == global.zorg_ultima) _f = _frases[irandom(array_length(_frases) - 1)];
	global.zorg_ultima = _f;
	var _aj = zorg_ajustar(heroi_texto(_f));	//{N} VIRA O NOME DO PERSONAGEM ESCOLHIDO
	var _txt = _aj.txt;
	global.zorg = {
		ev : _ev,
		txt : _txt,
		esc : _aj.esc,
		chars : 0,
		cara : zorg_cara_do_evento(_ev),
		t : 0,
		dur : max(room_speed * 3.6, string_length(_txt) / ZORG_VEL_TEXTO + room_speed * 2.8),
	};
	if(_ev == "morte") global.zorg.dur = room_speed * 6;
	global.zorg_cd = ZORG_ESPERA;
	//ENTRADA: UM GRAVE MALVADO E UMA TREMIDA DE LEVE
	audio_play_sound(snd_hit2, 1, false, .45, 0, .45);
	audio_play_sound(snd_menu_erro_03, 1, false, .25, 0, .55);
}

//TODO FRAME (OBJ_GAME_CONTROL, FORA DA PAUSA): CONTA O TEMPO, SE APRESENTA E ESCREVE A FALA
function zorg_atualizar()
{
	if(!ZORG_ATIVO or !modo_arcade() or modo_versus()) exit;
	if(global.zorg_cd > 0) global.zorg_cd--;
	zorg_queda_atualizar();
	//APRESENTACAO (UMA VEZ POR PARTIDA). NORMALMENTE VEM DA CENA DA QUEDA; ISSO AQUI E SO UM PLANO B
	if(!global.zorg_inicio and is_undefined(global.zq) and global.tempo_partida >= ZORG_INICIO_S)
	{
		global.zorg_inicio = true;
		zorg_falar("inicio", true);
	}
	var _z = global.zorg;
	if(is_undefined(_z)) exit;
	_z.t++;
	//MAQUINA DE ESCREVER COM UM BIP MALIGNO (GRAVE, UM A CADA 2 LETRAS)
	if(_z.chars < string_length(_z.txt))
	{
		var _antes = floor(_z.chars);
		_z.chars += ZORG_VEL_TEXTO;
		var _depois = floor(_z.chars);
		var _letra = string_char_at(_z.txt, max(1, _depois));
		if(_depois > _antes and (_depois mod 2) == 0 and _letra != " " and _letra != "\n")
		{
			audio_play_sound(snd_menu_select_03, 1, false, .2, 0, .3 + random(.15));
		}
	}
	if(_z.t > _z.dur)
	{
		if(_z.ev == "inicio") global.zorg_intro = false; //SUMIU: A PRIMEIRA PEÇA PODE NASCER
		global.zorg = undefined;
	}
}

//A CARINHA (_X, _Y = CANTO DE CIMA ESQUERDO, 32X32 EM PIXELS DA ROOM). _E = ESCALA DA GUI
function zorg_cara(_x, _y, _e, _a, _cara, _fundo = true)
{
	var _spr = asset_get_index("spr_alien_cara");
	if(_spr != -1 and sprite_exists(_spr))
	{
		draw_sprite_stretched_ext(_spr, min(_cara, sprite_get_number(_spr) - 1), _x * _e, _y * _e, 32 * _e, 32 * _e, c_white, _a);
		return;
	}
	draw_set_alpha(_a);
	//FUNDO (SO NA CARINHA PEQUENA)
	if(_fundo)
	{
		draw_set_color(#12081F);
		draw_rectangle(_x * _e, _y * _e, (_x + 32) * _e, (_y + 32) * _e, false);
	}
	//ANTENAS COM PONTINHOS VERMELHOS (PISCAM)
	var _pisca = (current_time mod 700) < 350;
	draw_set_color(#3FAF3F);
	draw_line_width((_x + 10) * _e, (_y + 7) * _e, (_x + 7) * _e, (_y + 2) * _e, _e);
	draw_line_width((_x + 22) * _e, (_y + 7) * _e, (_x + 25) * _e, (_y + 2) * _e, _e);
	draw_set_color(_pisca ? #FF2A55 : #8A1530);
	draw_circle((_x + 7) * _e, (_y + 2) * _e, 1.6 * _e, false);
	draw_circle((_x + 25) * _e, (_y + 2) * _e, 1.6 * _e, false);
	//CABEÇA: VERDE, ESTREITA EMBAIXO (FORMATO DE ALIEN)
	draw_set_color(#4FD84F);
	draw_ellipse((_x + 5) * _e, (_y + 5) * _e, (_x + 27) * _e, (_y + 22) * _e, false);
	draw_triangle((_x + 7) * _e, (_y + 17) * _e, (_x + 25) * _e, (_y + 17) * _e, (_x + 16) * _e, (_y + 31) * _e, false);
	draw_set_color(#2E9A2E);
	draw_ellipse((_x + 5) * _e, (_y + 5) * _e, (_x + 27) * _e, (_y + 22) * _e, true);
	//OLHOS GRANDES INCLINADOS (PRETOS COM UM BRILHO VERMELHO)
	draw_set_color(#0A0410);
	draw_triangle((_x + 7) * _e, (_y + 11) * _e, (_x + 15) * _e, (_y + 17) * _e, (_x + 8) * _e, (_y + 19) * _e, false);
	draw_triangle((_x + 25) * _e, (_y + 11) * _e, (_x + 17) * _e, (_y + 17) * _e, (_x + 24) * _e, (_y + 19) * _e, false);
	draw_set_color(_cara == 2 ? #FF2A2A : #FF5577);
	draw_circle((_x + 11) * _e, (_y + 16) * _e, (_cara == 2 ? 1.8 : 1.2) * _e, false);
	draw_circle((_x + 21) * _e, (_y + 16) * _e, (_cara == 2 ? 1.8 : 1.2) * _e, false);
	//IRRITADO: SOBRANCELHAS BRAVAS
	if(_cara == 2)
	{
		draw_set_color(#0A0410);
		draw_line_width((_x + 6) * _e, (_y + 9) * _e, (_x + 15) * _e, (_y + 13) * _e, 1.5 * _e);
		draw_line_width((_x + 26) * _e, (_y + 9) * _e, (_x + 17) * _e, (_y + 13) * _e, 1.5 * _e);
	}
	//BOCA: SORRISO TORTO (0), RISADA ABERTA COM DENTES (1) OU TRAÇO BRAVO (2)
	draw_set_color(#0A0410);
	if(_cara == 1)
	{
		draw_ellipse((_x + 11) * _e, (_y + 22) * _e, (_x + 21) * _e, (_y + 27) * _e, false);
		draw_set_color(c_white);
		draw_line_width((_x + 12) * _e, (_y + 23) * _e, (_x + 20) * _e, (_y + 23) * _e, _e);
	}
	else if(_cara == 2)
	{
		draw_line_width((_x + 11) * _e, (_y + 25) * _e, (_x + 21) * _e, (_y + 24) * _e, _e);
	}
	else
	{
		draw_line_width((_x + 11) * _e, (_y + 24) * _e, (_x + 15) * _e, (_y + 26) * _e, _e);
		draw_line_width((_x + 15) * _e, (_y + 26) * _e, (_x + 21) * _e, (_y + 22) * _e, _e);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

//DESENHO (GUI, NO FIM DO DRAW_64 DO OBJ_GAME_CONTROL): UM PAINEL GRANDE ENTRA PELO LADO ESQUERDO (FAIXA VERMELHA DIAGONAL, FAIXA AMARELA INCLINADA,
//ROSTO GRANDE EM CIMA, NOME EMBAIXO E A FRASE GIRADA ACOMPANHANDO A FAIXA), COM ALPHA BAIXO, E SAI DEVAGAR. ESTILO DE JOGO DE LUTA / VILAO DE FLIPERAMA.
//TUDO EM PIXELS DA ROOM. NAO PASSA DE X = 225, ENTAO NUNCA COBRE A ARENA (QUE COMEÇA EM X = 280)
#macro ZORG_ALPHA_FUNDO	.45		//TRANSPARENCIA DAS FAIXAS E DO OVAL (O TEXTO E O ROSTO FICAM MAIS FORTES)
#macro ZORG_ALPHA_ROSTO	.85		//TRANSPARENCIA DO ROSTO
#macro ZORG_ESCALA		.88		//TAMANHO DE TUDO (1 = TAMANHO ORIGINAL). O PAINEL FICA ENCOSTADO NO CANTO DE CIMA ESQUERDO
#macro ZORG_NOME_ESC	1.05	//TAMANHO DO NOME "ZORG"

//TEXTO COM CONTORNO ESCURO (LE EM CIMA DE QUALQUER FAIXA). _ANG EM GRAUS (SENTIDO ANTI-HORARIO)
function zorg_texto(_x, _y, _txt, _esc, _ang, _cor, _a)
{
	var _e = gui_esc() * ZORG_ESCALA;
	var _c = #3A0010;
	var _d = [[-1, 0], [1, 0], [0, -1], [0, 1], [-1, -1], [1, 1]];
	for(var i = 0; i < array_length(_d); i++)
	{
		draw_text_transformed_color(_x * _e + _d[i][0] * _e, _y * _e + _d[i][1] * _e, _txt, _e * _esc, _e * _esc, _ang, _c, _c, _c, _c, _a);
	}
	draw_text_transformed_color(_x * _e, _y * _e, _txt, _e * _esc, _e * _esc, _ang, _cor, _cor, _cor, _cor, _a);
}

function zorg_desenhar()
{
	var _z = global.zorg;
	if(is_undefined(_z)) exit;
	var _e0 = gui_esc();	//ESCALA CHEIA (SO PRA FAIXA VERMELHA, QUE VAI ATE O FIM DA TELA)
	var _e = _e0 * ZORG_ESCALA;
	//ENTRA E SAI EM 16 FRAMES (_K DE 0 A 1): DESLIZA PELO LADO E VAI APARECENDO / SUMINDO
	var _k = min(clamp(_z.t / 16, 0, 1), clamp((_z.dur - _z.t) / 16, 0, 1));
	var _ease = 1 - power(1 - _k, 3);
	var _ox = -(1 - _ease) * 240 + (_z.t < 24 ? random_range(-1.5, 1.5) : 0);
	var _pulso = .9 + .1 * sin(current_time / 130);

	//FAIXA VERMELHA DIAGONAL (LARGA EM CIMA, ESTREITA EMBAIXO)
	draw_set_color(#E5173A);
	draw_set_alpha(ZORG_ALPHA_FUNDO * _k);
	draw_triangle((0 + _ox) * _e, 0, (225 + _ox) * _e, 0, (112 + _ox) * _e, 405 * _e0, false);
	draw_triangle((0 + _ox) * _e, 0, (112 + _ox) * _e, 405 * _e0, (0 + _ox) * _e, 405 * _e0, false);
	//BORDA CLARA NA DIAGONAL
	draw_set_color(#FF8CA0);
	draw_set_alpha(ZORG_ALPHA_FUNDO * _k * 1.4);
	draw_line_width((225 + _ox) * _e, 0, (112 + _ox) * _e, 405 * _e0, 2 * _e);

	//OVAL VERDE ATRAS DO ROSTO
	draw_set_color(#2FA36B);
	draw_set_alpha(ZORG_ALPHA_FUNDO * _k * .9);
	draw_ellipse((12 + _ox) * _e, 6 * _e, (136 + _ox) * _e, 190 * _e, false);

	//FAIXA AMARELA INCLINADA (RETANGULO GIRADO ZORG_ANGULO GRAUS: COMEÇA FORA DA TELA E TERMINA CORTADO RETO). U = ONDE O TEXTO CORRE, V = PRA BAIXO DELA
	var _th = degtorad(ZORG_ANGULO);
	var _ux = cos(_th), _uy = -sin(_th);
	var _vx = sin(_th), _vy = cos(_th);
	var _sx = -20 + _ox, _sy = 300;
	var _ex = _sx + _ux * ZORG_FAIXA_COMP, _ey = _sy + _uy * ZORG_FAIXA_COMP;
	var _m = ZORG_FAIXA_ESP / 2;
	var _ax = _sx - _vx * _m, _ay = _sy - _vy * _m;	//CANTO DE CIMA, COMEÇO
	var _bx = _sx + _vx * _m, _by = _sy + _vy * _m;	//CANTO DE BAIXO, COMEÇO
	var _cx = _ex + _vx * _m, _cy = _ey + _vy * _m;	//CANTO DE BAIXO, FIM
	var _dx = _ex - _vx * _m, _dy = _ey - _vy * _m;	//CANTO DE CIMA, FIM
	draw_set_color(#FFD21F);
	draw_set_alpha(ZORG_ALPHA_FUNDO * _k * _pulso);
	draw_triangle(_ax * _e, _ay * _e, _bx * _e, _by * _e, _cx * _e, _cy * _e, false);
	draw_triangle(_ax * _e, _ay * _e, _cx * _e, _cy * _e, _dx * _e, _dy * _e, false);
	draw_set_color(#FFF08A);
	draw_set_alpha(ZORG_ALPHA_FUNDO * _k * 1.4);
	draw_line_width(_ax * _e, _ay * _e, _dx * _e, _dy * _e, 1.5 * _e);
	draw_line_width(_bx * _e, _by * _e, _cx * _e, _cy * _e, 1.5 * _e);
	draw_set_alpha(1);

	//ROSTO GRANDE (O MESMO DESENHO DA CARINHA, AUMENTADO 3.4X, SEM O FUNDO QUADRADO)
	var _s = 3.4;
	zorg_cara((19 + _ox) / _s, 44 / _s, _e * _s, ZORG_ALPHA_ROSTO * _k, _z.cara, false);

	//NOME (EMBAIXO DO ROSTO)
	draw_set_font(zorg_fonte());
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	zorg_texto(74 + _ox, 156, "ZORG", ZORG_NOME_ESC, 0, c_white, _k);
	draw_set_halign(fa_left);

	//FRASE (MAQUINA DE ESCREVER), GIRADA COMO A FAIXA E CENTRADA NA ESPESSURA DELA
	var _mostrar = string_copy(_z.txt, 1, floor(_z.chars));
	var _alt = string_height(_z.txt) * _z.esc;
	var _px = _sx + _ux * ZORG_FAIXA_RECUO - _vx * (_alt / 2);
	var _py = _sy + _uy * ZORG_FAIXA_RECUO - _vy * (_alt / 2);
	zorg_texto(_px, _py, _mostrar, _z.esc, ZORG_ANGULO, c_white, _k);
	draw_set_alpha(1);
	draw_set_color(c_white);
}


//==================== A ABERTURA DA PARTIDA: O PERSONAGEM CAI E O ZORG APARECE NO PULINHO ====================
//0) O PERSONAGEM CAI DO CEU. 1) BATE NO CHAO E FICA ESMAGADINHO UM INSTANTE. 2) DA UM PULINHO E NESSA HORA O ZORG APARECE E FALA.
//QUANDO POUSA DE NOVO O CONTROLE VOLTA. A PRIMEIRA PEÇA SO NASCE DEPOIS QUE O ZORG SOME (ZORG_SEGURANDO). 
global.zq = undefined;	//ESTADO DA CENA: { SUB, T } (UNDEFINED = NAO ESTA ACONTECENDO)

function zorg_queda_atualizar()
{
	var _q = global.zq;
	if(is_undefined(_q)) exit;
	var _p = player_n(1);
	if(_p == noone) exit;
	_q.t++;
	global.zorg_trava = true;
	//TRAVA DE SEGURANÇA: SE ALGO DER ERRADO A CENA ACABA SOZINHA
	if(_q.t > room_speed * 8)
	{
		global.zorg_trava = false;
		global.zq = undefined;
		if(!global.zorg_inicio) { global.zorg_inicio = true; zorg_falar("inicio", true); }
		exit;
	}
	switch(_q.sub)
	{
		//CAINDO: NO PRIMEIRO FRAME SOBE TODO MUNDO PRA FORA DA TELA
		case 0:
			if(_q.t == 1)
			{
				with(obj_player)
				{
					if(player_e_fantasma(id)) continue;
					y = -40;
					velh = 0;
					velv = 0;
					estado = state.jump;
				}
			}
			//BATEU NO CHAO
			if(_q.t > 10 and _p.solido(_p.x, _p.y + 1))
			{
				_q.sub = 1;
				_q.t = 0;
				with(obj_player)
				{
					velh = 0;
					velv = 0;
					poeira(x, y, 10);
					onda_choque(x, y - 8, 60, 5, 24);
				}
				shakes(10, 3);
				audio_play_sound(snd_hit2, 1, false, 1, 0, .6);
				audio_play_sound(snd_player_morte, 1, false, .4, 0, 1.6);
			}
			break;

		//ESMAGADINHO: FICA ACHATADO UM INSTANTE E DA O PULINHO (AI O ZORG APARECE)
		case 1:
			with(obj_player)
			{
				velh = 0;
				esc_x = 1.8 * sign(image_xscale);
				esc_y = .3;
			}
			if(_q.t > room_speed * .7)
			{
				_q.sub = 2;
				_q.t = 0;
				with(obj_player)
				{
					velv = -2.8;
					estado = state.jump;
					esc_x = .7 * sign(image_xscale);
					esc_y = 1.4;
				}
				audio_play_sound(snd_boing, 1, false, .9, 0, 1.3);
				global.zorg_inicio = true;
				zorg_falar("inicio", true);
			}
			break;

		//PULINHO: QUANDO POUSA DE NOVO O CONTROLE VOLTA (O ZORG CONTINUA FALANDO)
		case 2:
			if(_q.t > 8 and _p.solido(_p.x, _p.y + 1) and _p.velv >= 0)
			{
				global.zorg_trava = false;
				global.zq = undefined;
			}
			break;
	}
}

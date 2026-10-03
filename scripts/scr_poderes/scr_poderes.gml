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

//PEGOU TODAS AS LETRAS?
function letras_completas()
{
	for(var i = 0; i < array_length(global.letras); i++) if(!global.letras[i]) return false;
	return true;
}

//SORTEIA UMA LETRA QUE FALTA E QUE AINDA NAO TA NA TELA NEM DENTRO DE UM BLOCO (-1 SE NAO TIVER)
function letra_sortear()
{
	var _opcoes = [];
	for(var i = 0; i < array_length(global.letras); i++)
	{
		if(global.letras[i]) continue;
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

//PEGOU UMA LETRA
function letra_coletar(_i, _x, _y)
{
	if(global.letras[_i]) exit;
	global.letras[_i] = true;
	global.letra_pop[_i] = 2;
	//CADA LETRA PEGA TOCA A NOTA SEGUINTE (A PALAVRA VAI "SUBINDO"). COMPLETOU: JINGLE DO PODER
	var _pegas = 0;
	for(var k = 0; k < array_length(global.letras); k++) if(global.letras[k]) _pegas++;
	if(letras_completas()) som_tocar(snd_jingle_poder);
	else som_nota(4 + _pegas, .7);
	onda_choque(_x, _y, 34, 3, 18);
	efeito_texto(global.letras_nomes[_i], _x, _y - 10, c_yellow, 1.4);
}

//==================== PODER DE PARAR O TEMPO (ENERGIA CHEIA + TECLA 1) ====================
//O JOGO TODO PARA (A TELA FICA VERDE COM ANEIS DE RELOGIO) E SO O PLAYER SE MEXE POR TEMPO_DURACAO: DA PRA QUEBRAR E EMPURRAR
//BLOCOS, MAS NADA CAI. DEPOIS VEM A CONTAGEM DE 3S E TODOS OS BLOCOS SOLTOS CAEM DE UMA VEZ (DE BAIXO PRA CIMA), ENCAIXANDO
//DO JEITO QUE O JOGADOR ARRUMOU. O CONTROLE CHAMA O TEMPO_ATUALIZAR; O DESENHO FICA NO DRAW_64 E NO DRAW_77 DO OBJ_GAME_CONTROL
#macro TEMPO_DURACAO	(room_speed * 20)	//TEMPO COM TUDO PARADO (DEPOIS VEM A CONTAGEM DE 3S, ONDE O PLAYER AINDA ANDA)
#macro TEMPO_CONTAGEM	(room_speed * 3)
#macro TEMPO_TECLA		ord("1")
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

//APERTOU 1 COM A ENERGIA CHEIA: PARA O TEMPO (GASTA TODA A ENERGIA)
function tempo_parar()
{
	global.energia = 0;
	global.tempo_fase = "parado";
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
	with(obj_player) { alpha_fog = 1; esc_x = 1.4 * image_xscale; esc_y = .7; }
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

//FIM DA CONTAGEM: ENCAIXA TODO MUNDO NA GRADE E FAZ A LISTA DOS GRUPOS, DO MAIS BAIXO PRO MAIS ALTO
function tempo_preparar_queda()
{
	with(obj_peca) if(destruido_por == noone)
	{
		x = grid_alinhar_x(prox_x);
		prox_x = x;
		y = grid_alinhar_y_cima(y);
		gel_quicando = false;
	}
	var _grupos = [];
	with(obj_peca) if(destruido_por == noone)
	{
		var _l = (irmandade and instance_exists(pai)) ? pai : id;
		if(!array_contains(_grupos, _l)) array_push(_grupos, _l);
	}
	//FUNDO DE CADA GRUPO (O Y DO BLOCO MAIS BAIXO)
	var _fundo = function(_l) { var _m = tempo_membros(_l), _f = -infinity; for(var i = 0; i < array_length(_m); i++) _f = max(_f, _m[i].y); return _f; };
	array_sort(_grupos, method({ f : _fundo }, function(_a, _b) { return f(_b) - f(_a); }));
	global.tempo_queda = _grupos;
	global.tempo_moveu = false;
}

//DERRUBA O PROXIMO GRUPO DA LISTA ATE ONDE ELE CABE (COM RASTRO VERDE E O CLARAO NO CHAO). DEVOLVE SE CAIU
function tempo_derrubar_proximo()
{
	if(array_length(global.tempo_queda) == 0 or !instance_exists(obj_area)) return false;
	var _l = global.tempo_queda[0];
	array_delete(global.tempo_queda, 0, 1);
	var _m = tempo_membros(_l);
	if(array_length(_m) == 0) return false;
	var _limite = obj_area.y + obj_area.sprite_height;
	var _queda = 0;
	repeat(40)
	{
		var _prox = _queda + CEL, _livre = true;
		for(var i = 0; i < array_length(_m) and _livre; i++)
		{
			if(_m[i].y + _prox > _limite or tempo_ocupado(_m[i].x, _m[i].y + _prox, _m)) _livre = false;
		}
		if(!_livre) break;
		_queda = _prox;
	}
	if(_queda <= 0) return false;
	//TOPO E FUNDO DE CADA COLUNA (UM RASTRO POR COLUNA)
	var _topos = {}, _fundos = {};
	for(var i = 0; i < array_length(_m); i++)
	{
		with(_m[i])
		{
			esvaziar_grid();
			var _k = string(x);
			if(!variable_struct_exists(_topos, _k) or y < _topos[$ _k]) _topos[$ _k] = y;
			y += _queda;
			if(!variable_struct_exists(_fundos, _k) or y > _fundos[$ _k]) _fundos[$ _k] = y;
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
	var _ks = variable_struct_get_names(_topos);
	for(var i = 0; i < array_length(_ks); i++)
	{
		var _rx = real(_ks[i]);
		var _r = instance_create_depth(_rx, _topos[$ _ks[i]] - CEL / 2, -1700, obj_efeito_animacao);
		_r.sprite_index = spr_efeito_teleporte;
		_r.image_yscale = _queda / sprite_get_height(spr_efeito_teleporte);
		_r.image_blend = TEMPO_VERDE;
		var _im = instance_create_depth(_rx, _fundos[$ _ks[i]] + CEL / 2, -1800, obj_efeito_pontos);
		_im.modo = "tele";
		_im.y_chao = _im.y;
	}
	audio_play_sound(snd_acelerar_peca, 1, false, .5, 0, .9 + random(.4));
	shakes(3, 1);
	global.tempo_moveu = true;
	return true;
}

//RODA TODO FRAME NO OBJ_GAME_CONTROL (MENOS NA PAUSA DE VERDADE): CONTA O TEMPO, A CONTAGEM E FAZ A QUEDA
function tempo_atualizar()
{
	if(global.tempo_fase == "") exit;
	global.tempo_t++;
	desafio_segurar(true); //NADA NASCE NEM ANDA (OS ALARMES FICAM SEGURADOS)
	switch(global.tempo_fase)
	{
		case "parado":
			global.tempo_timer--;
			//TIQUE DO RELOGIO A CADA SEGUNDO (MAIS FORTE NOS 3 ULTIMOS)
			if(global.tempo_timer > 0 and global.tempo_timer mod room_speed == 0) audio_play_sound(Bip_2, 1, false, global.tempo_timer <= room_speed * 3 ? .8 : .35, 0, .7);
			if(global.tempo_timer <= 0)
			{
				global.tempo_fase = "contagem";
				global.tempo_timer = TEMPO_CONTAGEM;
				som_tocar(Bip_2);
			}
			break;
		case "contagem":
			global.tempo_timer--;
			if(global.tempo_timer > 0 and global.tempo_timer mod room_speed == 0) som_tocar(Bip_2);
			if(global.tempo_timer <= 0)
			{
				global.tempo_fase = "queda";
				global.tempo_passadas = 0;
				global.tempo_flash = .8;
				tempo_preparar_queda();
				som_tocar(snd_certo);
				audio_play_sound(snd_feitico, 2, false, 1, 0, 1.3);
				if(instance_exists(obj_area)) onda_choque(obj_area.x + obj_area.sprite_width / 2, obj_area.y + obj_area.sprite_height / 2, 220, 8, 40);
			}
			break;
		case "queda":
			//DOIS GRUPOS POR FRAME, DE BAIXO PRA CIMA (UMA CASCATA). ACABOU A LISTA: SE ALGUEM CAIU, PASSA DE NOVO (ATE 4 VEZES)
			var _caiu = 0;
			while(_caiu < 2 and array_length(global.tempo_queda) > 0) if(tempo_derrubar_proximo()) _caiu++;
			if(array_length(global.tempo_queda) == 0)
			{
				if(global.tempo_moveu and global.tempo_passadas < 4) { global.tempo_passadas++; tempo_preparar_queda(); }
				else
				{
					global.tempo_fase = "";
					shakes(12, 3);
					hitstop(6);
					with(obj_area) alarm[0] = max(alarm[0], room_speed);
				}
			}
			break;
	}
}
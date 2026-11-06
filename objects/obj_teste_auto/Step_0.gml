//TESTE AUTOMATICO: CADA ETAPA MONTA UMA SITUAÇAO, SIMULA AS TECLAS E ESCREVE O RESULTADO NO LOG.
//ETAPAS: BLOCO LENTO QUEBRADO PELO PLAYER (GIRO NO CHAO, NO AR E BAIXO+GIRO), COLMEIA (2 ABELHAS POR VEZ),
//GELATINA (BLOCO QUICANDO ATE TER OUTRO EM CIMA, PEÇA CAINDO NELA, TRAMPOLIM E EMPURRAO NA LATERAL)
//TEMPO DO TESTE E TEMPO DENTRO DA ETAPA ATUAL
timer++;
var _t = timer - marca;
//ATALHOS: IR PRA PROXIMA ETAPA, CRIAR UM BLOCO NA COLUNA/LINHA, LIMPAR A ARENA E POR O PLAYER
var _proxima = function(_etapa) { etapa = _etapa; marca = timer; keyboard_key_release(global.imputs.rigth); keyboard_key_release(global.imputs.jump); keyboard_key_release(global.imputs.giro); keyboard_key_release(global.imputs.down); };
var _tecla = function(_k) { global.teste_tecla = _k; }; //O MENU DE DEBUG LE ESSA "TECLA" (AS SIMULADAS NAO CHEGAM COM A JANELA MINIMIZADA)
var _bloco = function(_col, _row, _cor = cores.c_green) { return criar_bloco_solto(288 + 16 * _col, 56 + 16 * _row, _cor); };
var _limpar = function() { with(obj_peca) { efeito_morte = false; instance_destroy(); } with(obj_letra) instance_destroy(); with(obj_inimigo) instance_destroy(); with(obj_abelha) instance_destroy(); with(obj_bloco_fogo) instance_destroy(); with(obj_moeda) instance_destroy(); with(obj_block) if(bbox_top < obj_area.y + obj_area.sprite_height - 2 and object_index != obj_parede) instance_destroy(); }; //(TAMBEM O CHAO SOLIDO QUE AS LINHAS CRIAM, MAS NAO AS PAREDES)
var _player = function(_x, _y, _estado = state.idle) { with(obj_player) { x = _x; y = _y; velh = 0; velv = 0; estado = _estado; imune = 0; lento = 0; image_xscale = 1; } };
var _gel = function(_col, _row) { var _g = criar_bloco_solto(288 + 16 * _col, 56 + 16 * _row, cores.c_green); _g.sou_gelatina = true; _g.sou_normal = false; _g.coloracao = -1; return _g; };
var _lento = function(_col, _row) { var _l = criar_bloco_solto(288 + 16 * _col, 56 + 16 * _row, cores.c_purple); _l.sou_lento = true; _l.sou_normal = false; return _l; };

//NENHUMA PEÇA DO TESTE SORTEIA TIPO ESPECIAL
if(etapa != "consistencia") with(obj_peca) if(alarm[1] > 0) alarm[1] = -1;

//(A ETAPA gorz_natural DEIXA O JOGO ABRIR SOZINHO, SEM MEXER EM NADA)
if(timer == 1 and etapa != "gorz_natural")
{
	with(obj_area) alarm[0] = 99999;
	with(obj_game_control) { onda_proxima = 99999; letra_timer = 99999; laser_proxima = 99999; }
	player_longe();
	etapa = "pausa_coop";
	marca = timer;
}
if(etapa != "gorz_natural") global.tempo_partida = 30; //SEM DESAFIO NO MEIO DO TESTE

switch(etapa)
{
	#region PAUSA NOVA (VISUAL DO MENU PRINCIPAL) NO SOLO, NO COOP (COM A VEZ DO TELEPORTE) E NO VERSUS
	case "pausa_solo":
		if(_t == 2 and room != rm_arcade) { global.coop = false; room_goto(rm_arcade); exit; } //(A PRIMEIRA ROOM DO PROJETO PODE SER O COOP)
		if(_t == 5) { obj_game_control.pausado = true; log("room=" + room_get_name(room) + " coop=" + string(global.coop) + " dois=" + string(dois_players())); }
		if(_t == 40) screen_save("teste_p1_pausa_solo.png");
		if(_t == 42) obj_game_control.opcao_pause = 2;
		if(_t == 70) screen_save("teste_p1b_pausa_solo_sel.png");
		if(_t == 75) { log("FIM"); game_end(); }
		break;
	case "pausa_versus":
		if(_t == 2 and room != rm_versus) { room_goto(rm_versus); exit; }
		if(_t == 5) obj_game_control.pausado = true;
		if(_t == 40) { screen_save("teste_p6_pausa_versus.png"); log("room=" + room_get_name(room) + " dois=" + string(dois_players()) + " linhas=" + string(array_length(pausa_comandos_linhas()))); }
		if(_t == 45) { log("FIM"); game_end(); }
		break;
	case "pausa_coop":
		if(_t == 2)
		{
			if(room != rm_coop) { global.coop = true; room_goto(rm_coop); exit; }
			_limpar(); _player(-200, 100);
		}
		//DUAS PEÇAS NASCEM: A DA ESQUERDA E A ATUAL (PECA_INST), A DA DIREITA E A SEGUINTE
		if(_t == 5 or _t == 6)
		{
			global.prox_tipo = tipo_peca.O; global.prox_especie = "normal"; global.prox_fantasmas = 0; global.prox_gelo = false; global.prox_cor = _t == 5 ? cores.c_green : cores.c_red;
			var _c = instance_create_layer(obj_area.x + 8 + 16 * (_t == 5 ? 3 : 11), obj_area.y + 8 - 32, "Linha", obj_cria_peca);
			with(_c) event_perform(ev_alarm, 0);
		}
		if(_t == 12) log("inicio: vez=" + string(global.coop_vez) + " de_quem=" + string(coop_vez_de()) + " peca_atual existe=" + string(instance_exists(global.peca_inst)));
		if(_t == 30) screen_save("teste_p2_vez_p1.png");
		if(_t == 32) { var _a = global.peca_inst; coop_teleporte(2); log("P2 tentou na vez do P1: peca atual igual=" + string(_a == global.peca_inst) + " vez=" + string(global.coop_vez) + " (esperado: igual, vez 1)"); }
		if(_t == 45) screen_save("teste_p3_recusa.png");
		if(_t == 50) { var _a = global.peca_inst; coop_teleporte(1); log("P1 teleportou: peca atual trocou=" + string(_a != global.peca_inst) + " vez=" + string(global.coop_vez) + " (esperado: trocou, vez 2)"); }
		if(_t == 75) screen_save("teste_p4_vez_p2.png");
		if(_t == 78) { var _a = global.peca_inst; coop_teleporte(1); log("P1 tentou na vez do P2: peca atual igual=" + string(_a == global.peca_inst) + " vez=" + string(global.coop_vez) + " (esperado: igual, vez 2)"); }
		if(_t == 90) { var _a = global.peca_inst; coop_teleporte(2); log("P2 teleportou: peca atual trocou=" + string(_a != global.peca_inst) + " vez=" + string(global.coop_vez) + " (esperado: trocou, vez 1)"); }
		if(_t == 95) { var _p1 = player_n(1); _p1.estado = state.morte; log("P1 morto: vez de quem=" + string(coop_vez_de()) + " (esperado 2, pois o dono da vez morreu)"); _p1.estado = state.idle; }
		if(_t == 100) { obj_game_control.pausado = true; }
		if(_t == 140) { screen_save("teste_p5_pausa_coop.png"); log("tabela: " + string(array_length(pausa_comandos_linhas())) + " linhas, P2 teleporte=" + tecla_nome(imputs_jogador(2).acelerar) + " soco=" + tecla_nome(imputs_jogador(2).soco)); }
		if(_t == 145) { log("FIM"); game_end(); }
		break;
	#endregion

	#region BRILHO DA PEÇA ATUAL NA COR DE QUEM TEM A VEZ (COOP)
	case "brilho":
		if(_t == 2)
		{
			if(room != rm_coop) { global.coop = true; room_goto(rm_coop); exit; }
			_limpar(); _player(-200, 100);
		}
		if(_t == 5 or _t == 6)
		{
			global.prox_tipo = tipo_peca.O; global.prox_especie = "normal"; global.prox_fantasmas = 0; global.prox_gelo = false; global.prox_cor = _t == 5 ? cores.c_green : cores.c_red;
			var _c = instance_create_layer(obj_area.x + 8 + 16 * (_t == 5 ? 3 : 8), obj_area.y + 8 + 8, "Linha", obj_cria_peca);
			with(_c) event_perform(ev_alarm, 0);
		}
		if(_t == 12) screen_save("teste_b1_brilho_p1.png");
		if(_t == 13) global.coop_vez = 2;
		if(_t == 20) { screen_save("teste_b2_brilho_p2.png"); log("FIM"); game_end(); }
		break;
	#endregion

	#region GORZ (FAIXA, CABEÇA, LINHAS E TEXTO ANIMADO)
	case "gorz":
		if(_t == 2)
		{
			if(room != rm_coop) { global.coop = true; room_goto(rm_coop); exit; }
			_limpar(); _player(-200, 100);
			global.zq = undefined; global.gorz_trava = false; global.gorz_intro = false;
		}
		if(_t == 4) { gorz_falar("inicio", true); log("gorz falando=" + string(!is_undefined(global.gorz)) + " letras=" + string(is_undefined(global.gorz) ? -1 : global.gorz.n)); }
		if(_t == 12) screen_save("teste_g1_entrando.png");
		if(_t == 40) screen_save("teste_g2_escrevendo.png");
		if(_t == 90) screen_save("teste_g3_completo.png");
		if(_t == 120) { global.gorz = undefined; global.gorz_cd = 0; gorz_falar("laser", true); }
		if(_t == 190) screen_save("teste_g4_laser.png");
		if(_t == 200) { global.gorz = undefined; global.gorz_cd = 0; gorz_falar("frio", true); }
		if(_t == 280) screen_save("teste_g5_frio.png");
		if(_t == 285) { log("FIM"); game_end(); }
		break;
	#endregion

	#region GORZ: ABERTURA NATURAL (QUEDA, FALA, PRIMEIRA PEÇA SO DEPOIS)
	case "gorz_natural":
		if(_t == 2 and room != rm_coop) { global.coop = true; room_goto(rm_coop); exit; }
		//O TESTE TIRA OS PLAYERS DE CENA NO COMEÇO (X = -200): VOLTA ELES PRO CENTRO DA ARENA E RECOMEÇA A ABERTURA
		if(_t == 3) { var _k = 0; with(obj_player) { x = obj_area.x + 100 + 90 * _k; y = obj_area.y + 200; velh = 0; velv = 0; _k++; } gorz_iniciar(); }
		if(_t == 20 or _t == 60 or _t == 120 or _t == 200 or _t == 320 or _t == 420)
		{
			log("t=" + string(_t) + " zq=" + string(!is_undefined(global.zq)) + " gorz=" + string(!is_undefined(global.gorz)) + " segurando=" + string(gorz_segurando()) + " pecas=" + string(instance_number(obj_peca)) + " trava=" + string(global.gorz_trava) + " sub=" + string(is_undefined(global.zq) ? -1 : global.zq.sub) + " qt=" + string(is_undefined(global.zq) ? -1 : global.zq.t) + " p1y=" + string(player_n(1) == noone ? -999 : player_n(1).y) + " p1estado=" + string(player_n(1) == noone ? -1 : player_n(1).estado) + " coop=" + string(global.coop) + " room=" + room_get_name(room) + " tp=" + string(global.tempo_partida) + " fantasma=" + string(player_n(1) == noone ? -1 : player_e_fantasma(player_n(1))) + " p1x=" + string(player_n(1).x) + " blocos=" + string(instance_number(obj_block)) + " solido=" + string(player_n(1).solido(player_n(1).x, player_n(1).y + 1)) + " velv=" + string(player_n(1).velv) + " p2y=" + string(player_n(2) == noone ? -1 : player_n(2).y) + " area=" + string(obj_area.x) + "," + string(obj_area.y) + "," + string(obj_area.sprite_height));
		}
		if(_t == 90) screen_save("teste_n1_queda.png");
		if(_t == 160) screen_save("teste_n2_fala.png");
		if(_t == 440) { log("FIM"); game_end(); }
		break;
	#endregion

	#region COOP: SCORE DE CADA UM + TOTAL NA FAIXA DE BAIXO
	case "pontos_coop":
		if(_t == 2)
		{
			if(room != rm_coop) { global.coop = true; room_goto(rm_coop); exit; }
			_limpar();
			global.zq = undefined; global.gorz_trava = false; global.gorz_intro = false;
			var _k = 0;
			with(obj_player) { x = obj_area.x + 80 + 140 * _k; y = obj_area.y + 200; velh = 0; velv = 0; estado = state.idle; _k++; }
			global.pontos_1 = 0; global.coop_pts = [0, 0]; global.coop_pend = [0, 0]; global.pontos_pendentes = 0;
		}
		if(_t == 10) pontos_somar(100, player_n(1).x, player_n(1).y - 20);
		if(_t == 12) pontos_somar(250, player_n(2).x, player_n(2).y - 20);
		if(_t == 14) pontos_somar(40, obj_area.x + 150, obj_area.y + 60, c_yellow, 1, 0);
		if(_t == 20) log("apos ganhos: P1=" + string(global.coop_pts[0]) + " P2=" + string(global.coop_pts[1]) + " total=" + string(global.pontos_1) + " (esperado 120 / 270 / 390)");
		if(_t == 240) screen_save("teste_c1_pontos.png");
		if(_t == 241) { player_n(2).dano_cobrar(); log("P2 levou dano: P1=" + string(global.coop_pts[0]) + " P2=" + string(global.coop_pts[1]) + " total=" + string(global.pontos_1) + " (esperado 120 / 170 / 290)"); }
		if(_t == 243) { var _v = player_n(2).vida_atual; player_n(2).dano_cobrar(); log("P2 sem pontos levou dano de novo: vida antes=" + string(_v) + " depois=" + string(player_n(2).vida_atual) + " P1=" + string(global.coop_pts[0]) + " (IMORTAL protege coracao; P1 tem que seguir 120)"); }
		if(_t == 244) { player_n(1).dano_cobrar(); log("P1 levou dano: P1=" + string(global.coop_pts[0]) + " total=" + string(global.pontos_1) + " (esperado P1 20, total 90: o P2 tambem levou o segundo dano)"); }
		if(_t == 300) { log("FIM"); game_end(); }
		break;
	#endregion

	#region DANO TIRA 100 PONTOS (SOLO E VERSUS)
	case "dano100":
		if(_t == 2 and room != rm_versus) { room_goto(rm_versus); exit; }
		if(_t == 10) { global.pontos_1 = 50; global.pontos_2 = 300; }
		if(_t == 12) { player_n(1).dano_cobrar(); player_n(2).dano_cobrar(); log("versus: P1 50->" + string(global.pontos_1) + " (esperado 0) P2 300->" + string(global.pontos_2) + " (esperado 200)"); }
		if(_t == 14) { var _v = player_n(1).vida_atual; player_n(1).dano_cobrar(); log("versus P1 sem pontos: vida " + string(_v) + "->" + string(player_n(1).vida_atual) + " (IMORTAL segura o coracao)"); }
		if(_t == 20) { log("room=" + room_get_name(room) + " FIM"); game_end(); }
		break;
	#endregion

	#region COOP: PEÇAS COM BLOCO 2-3 CASAS ACIMA DO PAI (J EM PE E I EM PE) NASCENDO NO TOPO DA ARENA DO COOP (Y = 32)
	case "jcoop":
		if(_t == 2)
		{
			if(room != rm_coop) { global.coop = true; room_goto(rm_coop); exit; }
			_limpar(); _player(-200, 100);
		}
		if(_t == 5 or _t == 6 or _t == 7)
		{
			//UMA PEÇA POR FRAME (O CRIADOR LE AS GLOBAIS PROX_* QUANDO NASCE A PEÇA)
			var _tipos = [tipo_peca.J3, tipo_peca.J1, tipo_peca.I1];
			var _cols = [1, 7, 13];
			var _k = _t - 5;
			global.prox_tipo = _tipos[_k]; global.prox_especie = "normal"; global.prox_fantasmas = 0; global.prox_gelo = false; global.prox_cor = cores.c_red;
			var _c = instance_create_layer(obj_area.x + 8 + 16 * _cols[_k], obj_area.y + 8 - 32, "Linha", obj_cria_peca);
			with(_c) event_perform(ev_alarm, 0);
		}
		if(_t == 90 or _t == 400)
		{
			var _pos = [], _dup = 0;
			with(obj_peca) array_push(_pos, string(x) + "_" + string(y));
			for(var i = 0; i < array_length(_pos); i++) for(var j = i + 1; j < array_length(_pos); j++) if(_pos[i] == _pos[j]) _dup++;
			log("t=" + string(_t) + " arena y=" + string(obj_area.y) + " blocos=" + string(instance_number(obj_peca)) + " (esperado 12) casas com dois blocos=" + string(_dup) + " (esperado 0) " + string(_pos));
			if(_t == 400) screen_save("teste_jcoop.png");
		}
		if(_t == 405) { log("FIM"); game_end(); }
		break;
	#endregion

	#region COOP: PROCURA DOIS BLOCOS NA MESMA CASA (JOGO NORMAL + SOCOS E TELEPORTES ALEATORIOS)
	case "sobrepor":
		if(_t == 2)
		{
			if(room != rm_coop) { global.coop = true; room_goto(rm_coop); exit; }
			randomize();
			game_set_speed(600, gamespeed_fps);
			with(obj_area) alarm[0] = 1;
			with(obj_game_control) onda_proxima = 300;
			viradas = 0;
			pais_vistos = {};
		}
		if(_t == 3) log("room=" + room_get_name(room) + " coop=" + string(global.coop) + " players=" + string(instance_number(obj_player)) + " cols=" + string(obj_area.cols));
		if(_t > 2 and _t mod 2000 == 0) screen_save("teste_sobrepor_" + string(_t) + ".png");
		if(_t > 2)
		{
			global.tempo_partida = 30 + _t / 60;
			//PEÇA NOVA (30 FRAMES DE VIDA) TEM QUE TER 4 BLOCOS EM 4 CASAS DIFERENTES
			with(obj_peca) if(sou_pai and tipo != tipo_peca.F)
			{
				var _k = string(id);
				if(!variable_struct_exists(other.pais_vistos, _k)) other.pais_vistos[$ _k] = _t;
				else if(_t - other.pais_vistos[$ _k] == 30)
				{
					var _casas = [], _meu = id;
					with(obj_peca) if(pai == _meu and destruido_por == noone) { var _c = string(round(x)) + "_" + string(round(y)); if(!array_contains(_casas, _c)) array_push(_casas, _c); }
					if(array_length(_casas) != 4) { other.log("PECA NOVA COM " + string(array_length(_casas)) + " CASAS t=" + string(_t) + " tipo=" + string(tipo) + " x=" + string(x) + " y=" + string(y) + " casas=" + string(_casas)); other.viradas++; }
				}
			}
			//SOCO ALEATORIO NUMA PEÇA (NORMAL OU SUPER) E TELEPORTE ALEATORIO
			if(_t mod 7 == 0 and instance_number(obj_peca) > 0) with(instance_find(obj_peca, irandom(instance_number(obj_peca) - 1))) velocidade_h(choose(-1, 1), choose(true, false));
			if(_t mod 97 == 0 and instance_number(obj_peca) > 0) with(instance_find(obj_peca, irandom(instance_number(obj_peca) - 1))) if(sou_pai and !estou_parado) teleportar_peca();
			//DOIS BLOCOS VIVOS COM O CENTRO A MENOS DE 8PX UM DO OUTRO
			var _n = instance_number(obj_peca);
			for(var i = 0; i < _n and viradas < 15; i++)
			{
				var _a = instance_find(obj_peca, i);
				if(_a.destruido_por != noone) continue;
				for(var j = i + 1; j < _n; j++)
				{
					var _b = instance_find(obj_peca, j);
					if(_b.destruido_por != noone) continue;
					if(abs(_a.x - _b.x) < 8 and abs(_a.y - _b.y) < 8)
					{
						viradas++;
						var _txt = function(_p) { return "id=" + string(_p.id) + " pai=" + string(_p.pai) + " sou_pai=" + string(_p.sou_pai) + " tipo=" + string(instance_exists(_p.pai) ? _p.pai.tipo : -1) + " x=" + string(_p.x) + " y=" + string(_p.y) + " prox_x=" + string(_p.prox_x) + " andar=" + string(_p.andar) + " parado=" + string(_p.estou_parado) + " irm=" + string(_p.irmandade) + " raiv=" + string(_p.sou_raivoso) + " fujao=" + string(_p.sou_fujao) + " gel=" + string(_p.gel_quicando) + " init=" + string(_p.inicializando); };
						log("SOBREPOSTO t=" + string(_t) + " | A " + _txt(_a) + " | B " + _txt(_b));
						if(viradas == 1) screen_save("teste_sobrepor.png");
					}
				}
			}
		}
		if(_t == 12000) { log("fim: sobrepostos=" + string(viradas) + " pecas=" + string(instance_number(obj_peca))); log("FIM"); game_end(); }
		break;
	#endregion

	#region PECA QUE NAO CABE NAO NASCE (SO NASCE QUANDO A CASA LIBERA)
	case "cabe":
		if(_t == 2) { _limpar(); _player(-200, 100); }
		if(_t == 5)
		{
			var _a = obj_area;
			global.prox_tipo = tipo_peca.O; global.prox_especie = "normal"; global.prox_fantasmas = 0; global.prox_gelo = false; global.prox_cor = cores.c_green;
			peca_t = criar_bloco_solto(_a.x + 8 + 16 * 4, _a.y - 24, cores.c_green);
			instance_create_layer(_a.x + 8 + 16 * 4, _a.y - 24, "Linha", obj_cria_peca);
		}
		if(_t == 30) { var _tent = instance_exists(obj_cria_peca) ? obj_cria_peca.tentativas : -1; log("bloco no lugar: criadores=" + string(instance_number(obj_cria_peca)) + " tentativas=" + string(_tent) + " pecas O nascidas=" + string(instance_number(obj_peca) - 1)); }
		if(_t == 31) { instance_destroy(peca_t); log("bloco tirado"); }
		if(_t == 60)
		{
			var _pos = [], _dup = 0;
			with(obj_peca) array_push(_pos, string(x) + "_" + string(y));
			for(var i = 0; i < array_length(_pos); i++) for(var j = i + 1; j < array_length(_pos); j++) if(_pos[i] == _pos[j]) _dup++;
			log("depois: criadores=" + string(instance_number(obj_cria_peca)) + " pecas=" + string(instance_number(obj_peca)) + " casas com dois blocos=" + string(_dup) + " (esperado 0)");
			screen_save("teste_z1_cabe.png");
		}
		if(_t == 70) { log("FIM"); game_end(); }
		break;
	#endregion

	#region PODER DE PARAR O TEMPO E PEÇAS DUPLAS
	//TEMPO PARADO: A GELATINA NAO QUICA O PLAYER, E NA CONTAGEM ELE AINDA ANDA
	//BLOCO NOVO DESCOBERTO E LASER LATERAL
	case "pausa_cmd":
		if(_t == 5) { obj_game_control.pausado = true; obj_game_control.ver_comandos = true; }
		if(_t == 30) screen_save("teste_y1_comandos.png");
		if(_t == 32) { obj_game_control.ver_comandos = false; obj_game_control.opcao_pause = 1; }
		if(_t == 60) screen_save("teste_y2_pausa.png");
		if(_t == 62) { obj_game_control.pausado = false; global.energia = ENERGIA_MAX; _player(352, 352); }
		if(_t == 100) { screen_save("teste_y3_mob.png"); log("pads=" + string(array_length(pads_ligados())) + " partida=" + string(pad_na_partida())); }
		if(_t == 105) { log("FIM"); game_end(); }
		break;
	case "fundo":
		if(_t == 2) { _player(352, 352); for(var c = 0; c < 9; c++) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_green); }
		if(_t == 60) screen_save("teste_x1_fundo.png");
		if(_t == 65) { obj_player.imune = 0; obj_player.levar_dano(1); }
		if(_t == 68) screen_save("teste_x2_dano.png");
		if(_t == 100) global.level = 2;
		if(_t == 220) screen_save("teste_x3_level2.png");
		if(_t == 225) { log("FIM"); game_end(); }
		break;
	case "descobrir":
		if(_t == 2) { global.blocos_vistos = { normal : true }; _player(-200, 100); }
		if(_t == 5) { debug_preparar("Gelo"); with(obj_area) criar_bloco(); }
		if(_t == 40) { log("depois do gelo nascer: gelo visto=" + string(bloco_visto("gelo")) + " avisos na fila=" + string(array_length(global.avisos_bloco))); screen_save("teste_v1_descoberto.png"); }
		if(_t == 200) { _limpar(); for(var c = 0; c < 4; c++) _bloco(c, 18, cores.c_green); _bloco(5, 18, cores.c_red); var _l = _bloco(8, 18, cores.c_green); with(_l) { sou_normal = false; sou_laser = true; laser_lado = true; } peca_t = _l; }
		if(_t == 330) { var _cols = ""; with(obj_peca) if(round((y - 56) / 16) == 18) _cols += string(round((x - 288) / 16)) + " "; log("laser lateral na coluna 8 (direita): blocos que sobraram na linha: " + _cols + "(esperado: a 5 quebrada, 0-3 e 8 inteiras) visto=" + string(bloco_visto("laser_lado"))); screen_save("teste_v2_laser_lado.png"); }
		if(_t == 335) { log("FIM"); game_end(); }
		break;
	case "tempo_gel":
		if(_t == 2) { _gel(6, 18); _player(300, 352); }
		if(_t == 20) { log("duracao do tempo parado=" + string(TEMPO_DURACAO / room_speed) + "s"); tempo_parar(); global.tempo_timer = 90; with(obj_player) { x = 384; y = 318; velv = 1; estado = state.jump; } viradas = 0; }
		if(_t > 20 and _t < 100 and obj_player.velv < -1) viradas = 1;
		if(_t == 100) log("player caiu na gelatina com o tempo parado: quicou=" + string(viradas) + " (esperado 0) y=" + string(obj_player.y) + " (em cima da gelatina ~336)");
		if(_t == 115) { log("fase=" + global.tempo_fase + " (contagem)"); obj_player.velh = 2; passou = obj_player.x; }
		if(_t == 117) log("na contagem o player andou " + string(obj_player.x - passou) + "px (tem que andar)");
		if(_t == 330) { log("depois: fase='" + global.tempo_fase + "'"); log("FIM"); game_end(); }
		break;
	case "alerta":
		if(_t == 2) _player(352, 352);
		if(_t == 60) { log("energia=" + string(global.energia) + " alerta=" + string(obj_borda.alerta_tempo)); screen_save("teste_u1_alerta.png"); }
		if(_t == 65) { log("FIM"); game_end(); }
		break;
	case "dupla":
		if(_t == 2) { _limpar(); global.dupla_timer = 600; with(obj_area) alarm[0] = 1; }
		if(_t >= 2 and _t <= 60 and _t mod 4 == 0) { var _pais = 0; with(obj_peca) if(sou_pai) _pais++; log("t=" + string(_t) + " espera=" + string(obj_area.dupla_espera) + " tent=" + string(obj_area.dupla_tentativas) + " cria=" + string(instance_number(obj_cria_peca)) + " pais=" + string(_pais) + " alarm0=" + string(obj_area.alarm[0]) + " pausa=" + string(global.game_pause)); }
		if(_t == 62) { log("FIM"); game_end(); }
		break;
	case "tempo":
		var _ini = 10, _fimp = _ini + TEMPO_DURACAO, _fimc = _fimp + TEMPO_CONTAGEM;
		if(_t == 2) { _player(300, 352); for(var c = 0; c < 10; c++) if(c != 4) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_green); peca_o = _bloco(7, 17, cores.c_aqua); global.energia = ENERGIA_MAX; }
		if(_t == 4) { peca_t = _bloco(4, 6, cores.c_yellow); with(peca_t) { estou_parado = false; } }
		if(_t == _ini) { log("antes: energia=" + string(global.energia) + " bloco no ar y=" + string(peca_t.y)); tempo_parar(); }
		if(_t == _ini + 3) { log("tempo parado: fase=" + global.tempo_fase + " pausa=" + string(global.game_pause) + " energia=" + string(global.energia)); obj_player.velh = 2; passou = obj_player.x; x_antes = peca_t.y; }
		if(_t == _ini + 5) { log("player andou " + string(obj_player.x - passou) + "px (tem que andar) | bloco no ar parado? y antes=" + string(x_antes) + " agora=" + string(peca_t.y)); with(peca_o) velocidade_h(-1); }
		if(_t == _ini + 40) { log("bloco empurrado no tempo parado: x=" + string(peca_o.x) + " (era 400, esperado 384)"); screen_save("teste_t1_parado.png"); }
		if(_t == _ini + 200) screen_save("teste_t2_parado_meio.png");
		if(_t == _fimp - 30) screen_save("teste_t3_fim_parado.png");
		if(_t == _fimp + 20) { log("contagem: fase=" + global.tempo_fase); screen_save("teste_t4_contagem.png"); }
		if(_t == _fimc + 4) screen_save("teste_t5_queda.png");
		if(_t == _fimc + 12) screen_save("teste_t6_queda_b.png");
		if(_t == _fimc + 120) { var _n = 0; with(obj_peca) if(round((y - 56) / 16) == 18) _n++; log("depois da queda: fase='" + global.tempo_fase + "' pausa=" + string(global.game_pause) + " blocos na linha 18=" + string(_n) + " (0 = o bloco do ar caiu no buraco e fechou a linha)"); _limpar(); global.dupla_timer = 600; with(obj_area) alarm[0] = 1; }
		if(_t == _fimc + 200) { var _pais = 0; with(obj_peca) if(sou_pai) _pais++; log("peças duplas: pecas nascidas em 80 frames=" + string(_pais) + " (esperado 2)"); screen_save("teste_t7_dupla.png"); log("FIM"); game_end(); }
		break;
	#endregion

	#region PREMIO DO DESAFIO, LENTO QUEBRADO PELO PLAYER E FESTA DA PALAVRA
	case "rodada20":
		var _pegas = function() { var _n = 0; for(var i = 0; i < array_length(global.letras); i++) if(global.letras[i]) _n++; return _n; };
		if(_t == 2) { _player(320, 352); global.tempo_partida = 400; viradas = _pegas(); qc_iniciar(); }
		if(_t == 10) { with(obj_quebra_cabeca) terminar(true); log("desafio completo: letras antes=" + string(viradas) + " depois=" + string(_pegas()) + " (esperado +1) pontos=" + string(global.pontos_1)); }
		if(_t == 60) { with(obj_quebra_cabeca) instance_destroy(); with(obj_encaixe) instance_destroy(); var _l = _lento(4, 18); peca_t = _l; }
		if(_t == 90) { with(peca_t) { destruido_por = "player"; instance_destroy(); } }
		if(_t == 92) log("lento quebrado pelo player: rapido=" + string(obj_player.rapido) + " (esperado ~" + string(RAPIDO_TEMPO) + ") lento=" + string(obj_player.lento));
		if(_t == 96) { obj_player.velh = 2; passou = obj_player.x; }
		if(_t == 97) log("andou com velh 2 em 1 frame: " + string(obj_player.x - passou) + "px (esperado ~" + string(2 * RAPIDO_MULT) + ")");
		if(_t == 98) screen_save("teste_s1_rapido.png");
		if(_t == 120) { _limpar(); global.poderes = []; for(var i = 0; i < array_length(global.letras); i++) letra_coletar(i, 360, 200); log("palavra completa: festa=" + string(global.palavra_festa)); }
		if(_t == 125) log("na festa: pausa=" + string(global.game_pause) + " festa=" + string(global.palavra_festa) + " menu=" + string(obj_game_control.menu_poder));
		if(_t == 140) screen_save("teste_s2_festa_a.png");
		if(_t == 170) screen_save("teste_s3_festa_b.png");
		if(_t == 240) { var _o = obj_game_control.poder_opcoes; log("depois da festa: menu=" + string(obj_game_control.menu_poder) + " opcoes=" + string(_o) + " (o primeiro tem que ser asas ou dash)"); screen_save("teste_s4_menu.png"); }
		if(_t == 250) { var _ok = 0; repeat(20) { with(obj_game_control) { poder_menu_abrir(); if(poder_opcoes[0] == "asas" or poder_opcoes[0] == "dash") _ok++; } } log("20 sorteios do primeiro menu: primeiro card asas/dash em " + string(_ok) + " de 20"); log("FIM"); game_end(); }
		break;
	#endregion

	#region GRADE ERRADA SE CONSERTA (CASA PRESA EM 2 OU VAZIA COM BLOCO)
	case "reparo":
		if(_t == 1) { player_longe(); for(var c = 0; c < 9; c++) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_green); }
		if(_t == 40) { global.grid[# 9, 18] = 2; _bloco(9, 18, cores.c_aqua); log("linha cheia com a casa 9 presa em 2"); }
		if(_t == 120) { var _n = 0; with(obj_peca) if(round((y - 56) / 16) == 18) _n++; log("casa presa em 2: blocos que sobraram=" + string(_n) + " (esperado 0)"); }
		if(_t == 130) { for(var c = 0; c < 9; c++) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_green); }
		if(_t == 170) { _bloco(9, 18, cores.c_aqua); }
		if(_t == 172) { global.grid[# 9, 18] = -1; }
		if(_t == 175) { global.grid[# 9, 18] = -1; log("linha cheia com a casa 9 vazia na grade"); }
		if(_t == 260) { var _n = 0; with(obj_peca) if(round((y - 56) / 16) == 18) _n++; log("casa vazia com bloco: blocos que sobraram=" + string(_n) + " (esperado 0)"); _proxima("linha_peca"); }
		break;
	#endregion

	#region LINHA FECHADA POR UMA PEÇA (NORMAL/GELO, CAINDO OU TELEPORTADA)
	//6 BLOCOS PARADOS NA LINHA DE BAIXO E UMA PEÇA DEITADA (I) COMPLETA AS 4 CASAS QUE FALTAM. 4 VARIAÇOES
	case "linha_peca":
		var _var = _t div 800, _f = _t mod 800;
		var _nomes = ["normal caindo", "gelo caindo", "normal teleporte", "gelo teleporte"];
		if(_var < 4)
		{
			if(_f == 1) _limpar();
			if(_f == 3) { player_longe(); global.linhas_completadas = 0; ds_grid_clear(global.grid, -1); for(var c = 0; c < 6; c++) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_yellow); }
			if(_f == 20)
			{
				debug_preparar((_var mod 2) ? "Gelo" : "Normal");
				global.prox_tipo = tipo_peca.I2;
				global.peca_inst = noone; global.prox_peca_int = [];
				instance_create_layer(288 + 16 * 7, 56 + 16 * 12, "Linha", obj_cria_peca);
			}
			if(_f == 30 and _var >= 2 and instance_exists(global.peca_inst)) teleporte_acionar();
			if(_f == 700) screen_save("teste_p_" + string(_var) + ".png");
			if(_f == 790)
			{
				var _s = ""; for(var i = 0; i < 10; i++) _s += string(global.grid[# i, 18]) + ",";
				var _n = 0; with(obj_peca) if(round((y - 56) / 16) == 18) _n++;
				log(_nomes[_var] + ": blocos na linha 18=" + string(_n) + " (0 = fechou) linhas=" + string(global.linhas_completadas) + " grade=" + _s);
				if(_n > 0) with(obj_peca) if(round((y - 56) / 16) == 18) other.log("   col " + string(round((x - 288) / 16)) + " y=" + string(y) + " parado=" + string(estou_parado) + " andar=" + string(andar) + " velv=" + string(velv) + " gelo=" + string(sou_gelo) + " irm=" + string(irmandade) + " timer_move=" + string(timer_move) + " prox_x=" + string(prox_x) + " x=" + string(x));
			}
		}
		if(_t == 3220) { log("FIM"); game_end(); }
		break;
	#endregion

	#region CONSISTENCIA DA GRADE (LINHA CHEIA QUE NAO FECHA)
	//O JOGO RODA SOZINHO COM TUDO LIBERADO. A CADA 20 FRAMES CONFERE: BLOCO PARADO COM A CASA VAZIA NA GRADE, CASA PRESA EM 2
	//SEM EFEITO DE LINHA, E LINHA CHEIA DE BLOCOS PARADOS QUE NAO FECHOU
	case "consistencia":
		global.tempo_partida = 1500;
		if(_t == 2) { with(obj_area) alarm[0] = 30; with(obj_game_control) { laser_proxima = room_speed * 20; } erros = 0; }
		if(_t mod 90 == 0 and instance_exists(global.peca_inst)) teleporte_acionar();
		//LINHA COM BLOCO EM TODAS AS CASAS (QUALQUER ESTADO) POR 3 CONFERIDAS SEGUIDAS SEM FECHAR
		if(_t == 2) cheias = array_create(19, 0);
		if(_t mod 20 == 0 and erros < 40)
		{
			for(var j = 0; j < obj_area.lins; j++)
			{
				var _todas = true;
				for(var i = 0; i < obj_area.cols and _todas; i++)
				{
					var _b = collision_point(obj_area.x + 8 + 16 * i, obj_area.y + 8 + 16 * j, obj_peca, false, true);
					if(_b == noone or _b.destruido_por != noone) _todas = false;
				}
				cheias[j] = _todas ? cheias[j] + 1 : 0;
				if(cheias[j] == 3)
				{
					erros++;
					var _s = ""; for(var i = 0; i < obj_area.cols; i++) _s += string(global.grid[# i, j]) + ",";
					log("LINHA CHEIA HA 60 FRAMES lin=" + string(j) + " grade=" + _s);
					for(var i = 0; i < obj_area.cols; i++)
					{
						var _b = collision_point(obj_area.x + 8 + 16 * i, obj_area.y + 8 + 16 * j, obj_peca, false, true);
						with(_b) other.log("   col " + string(i) + " x=" + string(x) + " y=" + string(y) + " parado=" + string(estou_parado) + " andar=" + string(andar) + " velv=" + string(velv) + " irm=" + string(irmandade) + " pai=" + string(sou_pai) + " gelo=" + string(sou_gelo) + " gel=" + string(sou_gelatina) + " quica=" + string(gel_quicando) + " fujao=" + string(sou_fujao) + " fant=" + string(sou_fantasma) + " raiv=" + string(sou_raivoso) + " colm=" + string(sou_colmeia) + " pedra=" + string(sou_pedra) + " init=" + string(inicializando) + " prox_x=" + string(prox_x));
					}
					screen_save("teste_q_" + string(erros) + ".png");
				}
			}
		}
		if(_t mod 20 == 0 and erros < 40)
		{
			var _a = obj_area;
			var _ocup = array_create(_a.lins * _a.cols, false);
			with(obj_peca)
			{
				if(!estou_parado or andar or velv != 0 or destruido_por != noone or inicializando > 0 or prox_x != x or gel_quicando) continue;
				var _cx = (x - _a.x) div CEL, _cy = (y - _a.y) div CEL;
				if(_cx < 0 or _cy < 0 or _cx >= _a.cols or _cy >= _a.lins) continue;
				if(abs(y - (_a.y + CEL / 2 + CEL * _cy)) > .5) continue; //NO MEIO DE UMA QUEDA
				_ocup[_cy * _a.cols + _cx] = true;
				if(global.grid[# _cx, _cy] == -1 and other.erros < 40)
				{
					other.erros++;
					other.log("BLOCO PARADO SEM GRADE col=" + string(_cx) + " lin=" + string(_cy) + " gelo=" + string(sou_gelo) + " gel=" + string(sou_gelatina) + " pedra=" + string(sou_pedra) + " fantasma=" + string(sou_fantasma) + " raivoso=" + string(sou_raivoso) + " irmandade=" + string(irmandade) + " pai=" + string(sou_pai) + " colmeia=" + string(sou_colmeia) + " lento=" + string(sou_lento) + " fujao=" + string(sou_fujao) + " buraco=" + string(sou_buraco) + " timer_move=" + string(timer_move));
				}
			}
			for(var j = 0; j < _a.lins; j++)
			{
				var _cheia = true, _tem2 = false;
				for(var i = 0; i < _a.cols; i++) { if(!_ocup[j * _a.cols + i]) _cheia = false; if(global.grid[# i, j] == 2) _tem2 = true; }
				if(_tem2 and !instance_exists(obj_efeito_line) and erros < 40) { erros++; var _s = ""; for(var i = 0; i < _a.cols; i++) _s += string(global.grid[# i, j]) + ","; log("CASA PRESA EM 2 lin=" + string(j) + " grade: " + _s); }
				if(_cheia and erros < 40) { erros++; var _s = ""; for(var i = 0; i < _a.cols; i++) _s += string(global.grid[# i, j]) + ","; log("LINHA CHEIA SEM FECHAR lin=" + string(j) + " grade: " + _s); }
			}
		}
		if(_t == 10800) { log("consistencia: " + string(erros) + " problemas em 180s, linhas totais=" + string(global.linhas_total)); log("FIM"); game_end(); }
		break;
	#endregion

	#region RM_COOP (ARENA LARGA)
	//A ROOM DO COOP: ARENA DE 16 COLUNAS, OS DOIS PLAYERS, A BORDA/HUD, UMA LINHA DE 16 FECHANDO E OS BLOCOS NOVOS
	case "sala_coop":
		var _a = obj_area;
		if(_t == 3)
		{
			log("room=" + room_get_name(room) + " coop=" + string(global.coop) + " arena x=" + string(_a.x) + " y=" + string(_a.y) + " cols=" + string(_a.cols) + " lins=" + string(_a.lins) + " players=" + string(instance_number(obj_player)) + " linha=" + string(instance_number(obj_linha)) + " paredes=" + string(instance_number(obj_parede)) + " dx_hud=" + string(obj_borda.dx_hud));
			with(obj_player) other.log("  P" + string(jogador) + " x=" + string(x) + " y=" + string(y));
			with(obj_player) { x = jogador == 1 ? _a.x + 40 : _a.x + 216; y = _a.y + _a.sprite_height; }
		}
		if(_t == 10) screen_save("teste_o1_coop_sala.png");
		//LINHA DE 16 NO CHAO: TEM QUE FECHAR
		if(_t == 20) { for(var c = 0; c < _a.cols; c++) criar_bloco_solto(_a.x + 8 + 16 * c, _a.y + 8 + 16 * (_a.lins - 1), c mod 2 ? cores.c_red : cores.c_green); }
		if(_t == 30) screen_save("teste_o2_coop_linha.png");
		if(_t == 150) log("linha de 16: blocos que sobraram=" + string(instance_number(obj_peca)) + " (esperado 0) linhas=" + string(global.linhas_completadas) + " pontos=" + string(global.pontos_1));
		//OS BLOCOS NOVOS PELO MENU DE DEBUG (UM A CADA 100 FRAMES)
		var _lista = debug_lista_blocos();
		var _i = (_t - 160) div 100, _f = (_t - 160) mod 100;
		if(_t >= 160 and _i < array_length(_lista))
		{
			if(_f == 0) { if(_i mod 5 == 0) _limpar(); debug_preparar(_lista[_i]); with(obj_area) { criar_bloco(); alarm[0] = instance_exists(obj_cria_peca) ? 99999 : 10; } }
			if(_f == 20 and instance_exists(global.peca_inst)) teleporte_acionar();
			if(_f == 30) with(obj_area) alarm[0] = 99999;
			if(_f == 50 and (_i == 7 or _i == 16)) screen_save("teste_o3_coop_" + _lista[_i] + ".png");
		}
		var _fim = 160 + array_length(_lista) * 100;
		if(_t == _fim) { var _o = instance_create_depth(0, 0, -2050, obj_onda_laser); _o.qtd = 2; _o.espera = 1; }
		if(_t == _fim + 60) screen_save("teste_o4_coop_laser.png");
		if(_t == _fim + 150) { with(obj_linha) elevar_nivel(); }
		if(_t == _fim + 170) screen_save("teste_o5_coop_andar.png");
		if(_t == _fim + 260) { log("rm_coop FIM sem erro: players=" + string(instance_number(obj_player)) + " pecas=" + string(instance_number(obj_peca))); log("FIM"); game_end(); }
		break;
	#endregion

	#region PISAO ENTRE OS PLAYERS (COOP)
	//P2 CAI NA CABEÇA DO P1: O P2 QUICA E O P1 LEVA SO O EFEITO DO DANO (SEM PERDER VIDA, SEM FICAR IMUNE)
	case "pisao":
		if(_t == 2)
		{
			global.coop = true;
			if(instance_number(obj_player) < 2) instance_create_layer(400, 352, "Player", obj_player, { jogador : 2 });
			with(obj_player) { x = 352; y = jogador == 1 ? 352 : 300; velh = 0; velv = 0; estado = jogador == 1 ? state.idle : state.jump; imune = 0; vida_atual = 3; }
			passou = 0; viradas = 0;
		}
		if(_t > 2 and passou == 0) { var _p1 = player_n(1), _p2 = player_n(2); if(_p1.estado == state.dano) { passou = _t; log("pisao no frame " + string(_t) + ": P1 estado dano, vida=" + string(_p1.vida_atual) + " imune=" + string(_p1.imune) + " pisca=" + string(_p1.pisca_dano) + " | P2 velv=" + string(_p2.velv) + " (subindo = quicou)"); } }
		if(passou > 0 and _t == passou + 3) screen_save("teste_n1_pisao.png");
		if(_t == 90) { log("depois: P1 vida=" + string(player_n(1).vida_atual) + " estado=" + string(player_n(1).estado) + (passou == 0 ? " SEM PISAO" : "")); _proxima("coop"); }
		break;
	#endregion

	#region COOP: TODOS OS BLOCOS COM DOIS PLAYERS
	case "coop":
		var _lista = debug_lista_blocos();
		var _passo = 150;
		if(_t == 2)
		{
			global.coop = true;
			if(instance_number(obj_player) < 2) instance_create_layer(400, 352, "Player", obj_player, { jogador : 2 });
			with(obj_player) { x = jogador == 1 ? 320 : 400; y = 352; velh = 0; velv = 0; estado = state.idle; imune = 0; }
			passou = 0; viradas = 0; imune_antes = [0, 0, 0];
			log("coop: players=" + string(instance_number(obj_player)));
		}
		//QUEM LEVOU DANO (O IMUNE PULA DE 0 PRA ALTO)
		if(_t > 2) with(obj_player) { if(imune > other.imune_antes[jogador] + 10) other.log("  P" + string(jogador) + " levou dano (x=" + string(round(x)) + ")"); other.imune_antes[jogador] = imune; }
		var _i = (_t - 10) div _passo;
		var _f = (_t - 10) mod _passo;
		if(_t >= 10 and _i < array_length(_lista))
		{
			if(_f == 0)
			{
				//OS DOIS PLAYERS VOLTAM PRO LUGAR E A ARENA LIMPA A CADA 4 BLOCOS (SENAO ENCHE)
				if(_i mod 4 == 0) _limpar();
				with(obj_player) if(estado != state.morte) { x = jogador == 1 ? 320 : 400; y = 352; velh = 0; velv = 0; }
				debug_preparar(_lista[_i]);
				with(obj_area) { criar_bloco(); alarm[0] = instance_exists(obj_cria_peca) ? 99999 : 10; }
				log(">> " + _lista[_i]);
			}
			if(_f == 25 and instance_exists(global.peca_inst)) teleporte_acionar();
			if(_f == 40) with(obj_area) alarm[0] = 99999;
			if(_f == 30) screen_save("teste_m_" + string(_i) + "_" + _lista[_i] + ".png");
			//LENTO: QUEBRA ELE POR OUTRO JEITO (LINHA) E VE SE OS DOIS FICAM LENTOS
			if(_lista[_i] == "Lento" and _f == 100) { with(obj_peca) if(sou_lento) { destruido_por = "linha"; instance_destroy(); } with(obj_player) other.log("  lento P" + string(jogador) + "=" + string(lento)); }
			if(_f == _passo - 1)
			{
				var _txt = "  fim: pecas=" + string(instance_number(obj_peca)) + " inimigos=" + string(instance_number(obj_inimigo)) + " abelhas=" + string(instance_number(obj_abelha)) + " fogo=" + string(instance_number(obj_bloco_fogo));
				with(obj_player) _txt += " | P" + string(jogador) + " estado=" + string(estado) + " x=" + string(round(x));
				log(_txt);
			}
		}
		//NO FIM: UMA ONDA DE LASER (MIRA UM DOS DOIS) E O CUBO DO ANDAR
		var _fim = 10 + array_length(_lista) * _passo;
		if(_t == _fim) { _limpar(); with(obj_player) if(estado != state.morte) { x = jogador == 1 ? 320 : 400; y = 352; } var _o = instance_create_depth(0, 0, -2050, obj_onda_laser); _o.qtd = 3; _o.espera = 1; }
		if(_t == _fim + 150) { with(obj_linha) elevar_nivel(); log("andar: pausa=" + string(global.andar_pausa)); }
		if(_t == _fim + 260) { log("coop FIM sem erro: players=" + string(instance_number(obj_player))); log("FIM"); game_end(); }
		break;
	#endregion

	#region GELATINA, TELEPORTE, CALOR, SNIPER E CABEÇUDO NA PAREDE
	//PLAYER ANDANDO CONTRA A LATERAL DA GELATINA (VELOCIDADE NA MAO: AS TECLAS SIMULADAS NAO CHEGAM): QUANTO ELE E JOGADO PRA TRAS
	case "gel_lado":
		if(_t == 1) { _gel(6, 18); _player(350, 352); passou = 0; x_antes = 0; viradas = 999; }
		if(_t >= 20 and passou == 0) { if(obj_player.velh < 0) { passou = _t; x_antes = obj_player.x; } else obj_player.velh = 1; }
		if(passou > 0) viradas = min(viradas, obj_player.x);
		if(_t == 120) { log("gelatina lateral: empurrao no x=" + string(x_antes) + " foi ate x=" + string(viradas) + " = " + string(x_antes - viradas) + "px pra tras (GEL_EMPURRAO=" + string(GEL_EMPURRAO) + ")"); _limpar(); _proxima("tele_fx"); }
		break;
	//TELEPORTE: O BRILHO DESCE DO TOPO DA TELA ATE O CHAO
	case "tele_fx":
		if(_t == 1) { player_longe(); for(var c = 0; c < 9; c++) if(c != 4 and c != 5) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_yellow); global.prox_tipo = tipo_peca.O; global.prox_especie = "normal"; global.prox_gelo = false; global.prox_fantasmas = 0; with(obj_area) criar_bloco(); }
		if(_t == 30) { log("teleporte: peca atual existe=" + string(instance_exists(global.peca_inst))); teleporte_acionar(); }
		if(_t == 31) screen_save("teste_l1_tele_a.png");
		if(_t == 33) screen_save("teste_l1_tele_b.png");
		if(_t == 36) screen_save("teste_l1_tele_c.png");
		if(_t == 41) screen_save("teste_l1_tele_d.png");
		if(_t == 48) screen_save("teste_l1_tele_e.png");
		if(_t == 70) { _limpar(); _proxima("calor"); }
		break;
	//LASER DO CEU COM BLOCOS NA COLUNA DO LADO (PRA VER A ONDULAÇAO)
	case "calor":
		if(_t == 1) { _player(352, 352); for(var r = 10; r <= 18; r++) { _bloco(3, r, cores.c_green); _bloco(5, r, cores.c_purple); } with(obj_onda_laser) instance_destroy(); var _o = instance_create_depth(0, 0, -1000, obj_onda_laser); _o.qtd = 1; _o.espera = 1; }
		if(_t == LASER_AVISO + 4) { log("calor: entradas=" + string(array_length(global.calor))); screen_save("teste_l2_calor_a.png"); }
		if(_t == LASER_AVISO + 10) screen_save("teste_l2_calor_b.png");
		if(_t == LASER_AVISO + 16) screen_save("teste_l2_calor_c.png");
		if(_t == LASER_AVISO + LASER_ATIVO + 30) { log("calor depois: entradas=" + string(array_length(global.calor))); _limpar(); player_longe(); _proxima("sniper"); }
		break;
	//SNIPER VOANDO PRA DIREITA NA LINHA 18 COM 4 BLOCOS NO CAMINHO
	case "sniper":
		if(_t == 1) { _bloco(2, 18, cores.c_red); _bloco(4, 18, cores.c_red); _bloco(5, 18, cores.c_green); _bloco(8, 18, cores.c_aqua); _bloco(4, 17, cores.c_aqua); peca_t = instance_create_depth(288, 56 + 16 * 18, -100, obj_sensor_voando); peca_t.dir = 1; viradas = 0; }
		if(_t == 4) screen_save("teste_l3_sniper.png");
		if(_t > 1 and viradas == 0 and !instance_exists(peca_t)) viradas = _t;
		if(_t mod 10 == 0 and instance_exists(peca_t)) log("sniper x=" + string(peca_t.x) + " pausa=" + string(global.game_pause));
		if(_t == 60) { var _n18 = 0, _n17 = 0; with(obj_peca) { if(round((y - 56) / 16) == 18) _n18++; else _n17++; } log("sniper: blocos na linha dele=" + string(_n18) + " (esperado 0) bloco de cima=" + string(_n17) + " (esperado 1) sumiu no frame " + string(viradas) + " (na parede)"); _limpar(); _proxima("cab_parede"); }
		break;
	//CABEÇUDO PRENSANDO O PLAYER NA PAREDE DA DIREITA: DANO E O PLAYER E JOGADO PRO OUTRO LADO (POR CIMA DELE)
	case "cab_parede":
		if(_t == 1) { with(obj_area) alarm[0] = 99999; peca_t = instance_create_layer(288 + 16 * 6, 56 + 16 * 18, "Blocos", obj_inimigo, { cabecudo : true }); _player(434, 352); viradas = 0; passou = 0; x_antes = 999; }
		if(_t == 30) { peca_t.dir = 1; with(obj_parede) other.log("parede x=" + string(x) + " bbox " + string(bbox_left) + "-" + string(bbox_right) + " / " + string(bbox_top) + "-" + string(bbox_bottom) + " mask=" + sprite_get_name(mask_index) + " spr=" + sprite_get_name(sprite_index)); with(obj_player) other.log("player bbox " + string(bbox_left) + "-" + string(bbox_right) + " / " + string(bbox_top) + "-" + string(bbox_bottom) + " parede a direita=" + string(place_meeting(x + 16, y - 2, obj_block)) + " " + string(place_meeting(x + 16, y - 2, obj_parede))); }
		if(_t mod 20 == 0 and instance_exists(peca_t)) log("cab x=" + string(peca_t.x) + " estado=" + string(peca_t.estado) + " player x=" + string(obj_player.x) + " imune=" + string(obj_player.imune));
		if(_t > 30 and obj_player.imune > 0 and viradas == 0) { viradas = _t; passou = obj_player.velh; }
		if(viradas > 0) x_antes = min(x_antes, obj_player.x);
		if(viradas > 0 and _t == viradas + 6) screen_save("teste_l4_cab_parede.png");
		if(_t == 260) { log("cabecudo na parede: dano no frame " + string(viradas) + " velh do player=" + string(passou) + " (esperado negativo) foi ate x=" + string(x_antes) + " cabecudo x=" + string(instance_exists(peca_t) ? peca_t.x : -1) + " vivo=" + string(instance_exists(peca_t) and peca_t.vivo())); log("FIM"); game_end(); }
		break;
	#endregion

	#region MENU DE DEBUG E DANO DO CABEÇUDO
	case "debug_menu":
		//ENTER ABRE, SETAS ESCOLHEM O CABEÇUDO, ENTER FAZ NASCER; DEPOIS A COLMEIA; ESC FECHA
		if(_t == 1) _player(320, 352);
		if(_t == 10) _tecla(vk_enter);
		if(_t == 20) log("enter: menu aberto=" + string(obj_game_control.menu_debug) + " pausa=" + string(global.game_pause));
		if(_t == 25) _tecla(vk_right);
		if(_t == 30) _tecla(vk_down);
		if(_t == 35) { log("opcao=" + debug_lista_blocos()[obj_game_control.debug_opcao] + " (esperado Cabecudo)"); screen_save("teste_k1_menu_debug.png"); }
		if(_t == 40) _tecla(vk_enter);
		if(_t == 60) { var _c = 0; with(obj_inimigo) if(cabecudo) _c++; log("escolheu: menu aberto=" + string(obj_game_control.menu_debug) + " pausa=" + string(global.game_pause) + " cabecudos=" + string(_c)); }
		if(_t == 70) { _tecla(vk_enter); obj_game_control.debug_opcao = 7; }
		if(_t == 75) _tecla(vk_enter);
		if(_t == 110) { var _c = 0, _col = 0; with(obj_peca) { _c++; if(sou_colmeia) _col++; } log("colmeia escolhida: blocos=" + string(_c) + " colmeias=" + string(_col) + " (esperado 1) menu=" + string(obj_game_control.menu_debug)); screen_save("teste_k2_colmeia.png"); }
		if(_t == 115) _tecla(vk_enter);
		if(_t == 120) _tecla(vk_escape);
		if(_t == 125) { log("esc fecha: menu=" + string(obj_game_control.menu_debug) + " pausa normal=" + string(obj_game_control.pausado)); _limpar(); _proxima("cab_dano"); }
		break;
	case "cab_dano":
		if(_t == 1) { with(obj_area) alarm[0] = 99999; peca_t = instance_create_layer(288 + 16 * 2, 56 + 16 * 18, "Blocos", obj_inimigo, { cabecudo : true }); _player(368, 352); viradas = 0; passou = 999; }
		if(_t == 40) peca_t.dir = 1;
		if(_t > 40 and obj_player.imune > 0 and viradas == 0) { viradas = _t; passou = obj_player.x; }
		if(_t == 300) { log("cabecudo de lado no player: levou dano=" + string(viradas > 0) + " no frame " + string(viradas) + " player x no dano=" + string(passou)); log("FIM"); game_end(); }
		break;
	#endregion

	#region PROFUNDIDADE EM TODOS
	//CHAO SOLIDO, PEÇA, CABEÇUDO E INIMIGO LADO A LADO: O DA ESQUERDA SEMPRE NA FRENTE DO DA DIREITA
	case "todos_prof":
		if(_t == 1)
		{
			instance_create_layer(288, 56 + 16 * 18, "Blocos", obj_block); instance_create_layer(288 + 16, 56 + 16 * 18, "Blocos", obj_block);
			_bloco(2, 18, cores.c_red);
			instance_create_layer(288 + 48, 56 + 16 * 18, "Blocos", obj_block);
			_bloco(4, 18, cores.c_yellow);
			instance_create_layer(288 + 16 * 5, 56 + 16 * 18, "Blocos", obj_inimigo, { cabecudo : true });
			_bloco(6, 18, cores.c_aqua); _bloco(7, 18, cores.c_green);
			instance_create_layer(288 + 16 * 8, 56 + 16 * 18, "Blocos", obj_inimigo);
			_bloco(9, 18, cores.c_purple);
			for(var c = 8; c >= 0; c--) _bloco(c, 16, cores.c_green); //CRIADOS DA DIREITA PRA ESQUERDA (ORDEM DE CRIAÇAO NAO PODE MUDAR NADA)
			_player(-200, 100);
		}
		with(obj_inimigo) { cab_espera = 99; velh = 0; }
		if(_t == 20)
		{
			with(obj_block) if(bbox_top < 350) other.log("chao solido col=" + string(round((x - 288) / 16)) + " depth=" + string(depth));
			with(obj_peca) other.log("peca col=" + string(round((x - 288) / 16)) + " lin=" + string(round((y - 56) / 16)) + " depth=" + string(depth) + " camada=" + string(layer_get_depth(layer)));
			with(obj_inimigo) other.log((cabecudo ? "cabecudo" : "inimigo") + " col=" + string(round((x - 288) / 16)) + " depth=" + string(depth));
			screen_save("teste_j4_profundidade_todos.png");
		}
		if(_t == 25) { log("FIM"); game_end(); }
		break;
	#endregion

	#region PROFUNDIDADE
	//PILHA DE GELO NA PAREDE (COMO NO PRINT DO USUARIO), DOIS LADO A LADO E DOIS NA DIAGONAL
	case "profundidade":
		if(_t == 1)
		{
			var _g1 = _bloco(0, 18); _g1.sou_gelo = true; _g1.sou_normal = false; _g1.coloracao = -1;
			var _g2 = _bloco(0, 17); _g2.sou_gelo = true; _g2.sou_normal = false; _g2.coloracao = -1;
			_bloco(3, 18, cores.c_green); _bloco(4, 18, cores.c_red);
			_bloco(6, 18, cores.c_yellow); _bloco(7, 18, cores.c_aqua); _bloco(6, 17, cores.c_purple); _bloco(8, 18, cores.c_red); _bloco(8, 17, cores.c_green);
			_player(-200, 100);
		}
		if(_t == 40) { with(obj_peca) other.log("bloco col=" + string(round((x - 288) / 16)) + " lin=" + string(round((y - 56) / 16)) + " depth=" + string(depth)); screen_save("teste_j2_profundidade_nova.png"); }
		if(_t == 45) { _limpar(); _proxima("cab_encosta"); }
		break;
	//CABEÇUDO ANDANDO PRO PLAYER QUE TEM UM BLOCO ATRAS: ELE PARA (NAO PRENSA NEM EMPURRA O PLAYER)
	case "cab_encosta":
		if(_t == 1) { peca_t = instance_create_layer(288 + 16 * 5, 56 + 16 * 16, "Blocos", obj_inimigo, { cabecudo : true }); _bloco(8, 18, cores.c_red); _player(400, 352); passou = 999; viradas = 0; dir_antes = 0; }
		if(_t == 70) peca_t.dir = 1;
		if(_t > 70) { passou = min(passou, obj_player.x); viradas = max(viradas, obj_player.x); if(place_meeting(obj_player.x, obj_player.y, peca_t)) dir_antes = 1; }
		if(_t == 150) screen_save("teste_j3_cabecudo_encostado.png");
		if(_t == 400) { log("cabecudo e player com bloco atras: player ficou entre x=" + string(passou) + " e " + string(viradas) + " (comecou em 400) cabecudo x=" + string(peca_t.x) + " dentro do player=" + string(dir_antes == 1) + " vida=" + string(obj_player.vida_atual)); _limpar(); player_longe(); _proxima("colmeia_tempo"); }
		break;
	//COLMEIA: AS PRIMEIRAS ABELHAS SO SAEM UNS 2S DEPOIS DE ASSENTAR
	case "colmeia_tempo":
		if(_t == 1) { for(var c = 0; c < 9; c++) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_green); var _c = _bloco(5, 17); _c.sou_colmeia = true; _c.sou_normal = false; _c.coloracao = -1; peca_t = _c; passou = 0; viradas = 0; }
		if(_t > 1 and viradas == 0 and peca_t.estou_parado) viradas = _t;
		if(_t > 1 and passou == 0 and instance_number(obj_abelha) > 0) { passou = _t; log("colmeia: assentou no frame " + string(viradas) + ", primeiras abelhas no frame " + string(_t) + " (" + string((_t - viradas) / room_speed) + "s depois, esperado ~2s)"); }
		if(_t == 260) { log("FIM"); game_end(); }
		break;
	#endregion

	#region PEÇA NO PLAYER PULANDO E FESTA DO ANDAR
	//PEÇA DESCENDO NA CABEÇA DO PLAYER QUE TEM ESPAÇO EMBAIXO: SO EMPURRA (SEM DANO)
	case "sem_dano":
		if(_t == 1) { peca_t = _bloco(4, 11, cores.c_red); with(peca_t) { estou_parado = false; meu_timer = 1; timer_move = 1; } viradas = 0; passou = 0; }
		if(_t == 2) with(obj_player) { x = 352; y = 250; velh = 0; velv = -1; estado = state.jump; imune = 0; }
		if(_t > 2 and _t < 40) { if(obj_player.imune > 0) viradas = 1; passou = max(passou, obj_player.y); }
		if(_t == 40) { log("peça descendo no player pulando (no ar): levou dano=" + string(viradas) + " (esperado 0) foi empurrado ate y=" + string(passou)); _limpar(); _proxima("andar_festa"); }
		break;
	//SUBIU DE ANDAR: O JOGO TODO PARA ENQUANTO A REGUA VAI PRO LUGAR NOVO (UM BLOCO CAINDO FICA PARADO NO AR)
	case "andar_festa":
		if(_t == 1) { _player(320, 352); peca_o = _bloco(7, 4, cores.c_aqua); with(peca_o) { estou_parado = false; meu_timer = 1; timer_move = 1; } }
		if(_t == 20) { x_antes = obj_linha.y; passou = peca_o.y; with(obj_linha) elevar_nivel(); log("subiu de andar: andar=" + string(global.andar) + " pausa=" + string(global.andar_pausa) + " titulo=" + obj_linha.festa_titulo + " | " + obj_linha.festa_sub); }
		if(_t == 28) screen_save("teste_i1_festa_entrando.png");
		if(_t == 50) screen_save("teste_i2_festa_meio.png");
		if(_t == 90) { log("na pausa (frame 90): bloco caindo y=" + string(peca_o.y) + " (antes " + string(passou) + ", esperado igual) regua y=" + string(obj_linha.y) + " (antes " + string(x_antes) + ") pausa=" + string(global.andar_pausa)); screen_save("teste_i3_festa_fim.png"); }
		if(_t == 160) log("depois da pausa: bloco caindo y=" + string(peca_o.y) + " (esperado mais baixo) pausa=" + string(global.andar_pausa) + " game_pause=" + string(global.game_pause));
		if(_t == 170) { log("FIM"); game_end(); }
		break;
	#endregion

	#region DANO DE QUEDA E LASER
	//BLOCO CAINDO NO PLAYER PARADO NO CHAO: ESMAGADO (AGORA PISCA E FICA IMUNE MESMO NO MODO IMORTAL)
	case "dano_chao":
		if(_t == 1) { _player(352, 352); peca_t = _bloco(4, 13, cores.c_red); with(peca_t) { estou_parado = false; meu_timer = 5; timer_move = 5; } viradas = 0; }
		if(_t > 1 and obj_player.imune > 0 and viradas == 0) { viradas = _t; log("dano (esmagado no chao) no frame " + string(_t) + ": imune=" + string(obj_player.imune) + " estado dano=" + string(obj_player.estado == state.dano)); }
		if(_t == 200) { if(viradas == 0) log("dano (esmagado no chao): NAO levou dano"); _limpar(); _proxima("dano_ar"); }
		break;
	//BLOCO CAINDO NA CABEÇA DO PLAYER COM ESPAÇO EMBAIXO: LEVA DANO E E EMPURRADO PRA BAIXO/PRO LADO
	case "dano_ar":
		if(_t == 1) { peca_t = _bloco(4, 16, cores.c_red); with(peca_t) { estou_parado = false; meu_timer = 1; timer_move = 1; } viradas = 0; }
		if(_t == 2) with(obj_player) { x = 352; y = 331; velh = 0; velv = -1; estado = state.jump; imune = 0; }
		if(_t > 2 and obj_player.imune > 0 and viradas == 0) { viradas = _t; log("dano (bloco na cabeça, com espaço embaixo) no frame " + string(_t) + ": estado dano=" + string(obj_player.estado == state.dano) + " velh=" + string(obj_player.velh)); }
		if(_t == 120) { if(viradas == 0) log("dano (bloco na cabeça): NAO levou dano"); _limpar(); _proxima("dano_cab"); }
		break;
	//CABEÇUDO CAINDO EM CIMA DO PLAYER: DANO (DE LADO ELE SO EMPURRA)
	case "dano_cab":
		if(_t == 1) { _player(352, 352); peca_t = instance_create_layer(352, 56 + 16 * 13, "Blocos", obj_inimigo, { cabecudo : true }); viradas = 0; }
		if(_t > 1 and obj_player.imune > 0 and viradas == 0) { viradas = _t; log("dano (cabecudo caiu em cima) no frame " + string(_t) + ": estado dano=" + string(obj_player.estado == state.dano)); }
		if(_t == 120) { if(viradas == 0) log("dano (cabecudo caiu em cima): NAO levou dano"); _limpar(); _player(352, 352); _proxima("laser_topo"); }
		break;
	//ONDA DE LASER: O AVISO E O FEIXE COMEÇAM NO TOPO DA TELA
	case "laser_topo":
		if(_t == 1) instance_create_depth(0, 0, -2050, obj_onda_laser);
		with(obj_onda_laser) for(var i = 0; i < array_length(lasers); i++)
		{
			if(lasers[i].t == round(LASER_AVISO / 2)) screen_save("teste_h1_laser_aviso.png");
			if(lasers[i].t == LASER_AVISO + 3) screen_save("teste_h2_laser_feixe.png");
		}
		if(_t == 200) { log("FIM"); game_end(); }
		break;
	#endregion

	#region CABEÇUDO (OBJ_INIMIGO COM CABECUDO = TRUE)
	//CAI, ANDA PRA DIREITA, EMPURRA O BLOCO ATE A PAREDE (LA ELE QUEBRA) E DEPOIS DA 3 CABEÇADAS NA PAREDE E MORRE
	case "cab_anda":
		if(_t == 1)
		{
			peca_t = instance_create_layer(288 + 32, 56 + 16 * 15, "Blocos", obj_inimigo, { cabecudo : true });
			peca_o = _bloco(5, 18, cores.c_aqua);
			dir_antes = 5; viradas = 0; passou = 0; x_antes = 0;
		}
		if(_t == 70) { peca_t.dir = 1; log("cabecudo pousou: estado=" + peca_t.estado + " y=" + string(peca_t.y)); }
		if(_t > 70)
		{
			if(instance_exists(peca_o))
			{
				var _col = round((peca_o.x - 288) / 16);
				if(_col != dir_antes and peca_o.x == peca_o.prox_x) { log("cabecudo empurrou o bloco pra coluna " + string(_col) + " no frame " + string(_t)); dir_antes = _col; }
			}
			else if(viradas == 0) { viradas = _t; log("bloco empurrado quebrou no frame " + string(_t) + " (na parede, sem espaço)"); }
			if(instance_exists(peca_t))
			{
				if(peca_t.cab_batidas != x_antes) { x_antes = peca_t.cab_batidas; if(x_antes > 0) log("cabeçada na parede " + string(x_antes) + " no frame " + string(_t)); }
				if(!peca_t.vivo() and passou == 0) { passou = _t; log("cabecudo morreu no frame " + string(_t) + " estado=" + peca_t.estado); }
			}
		}
		if(_t == 330) screen_save("teste_g1_cabecudo.png");
		if(_t == 1500 or passou > 0 and _t == passou + 60) { log("cab_anda fim: bloco existe=" + string(instance_exists(peca_o)) + " cabecudo existe=" + string(instance_exists(peca_t)) + " (esperado 0 e 0)"); _limpar(); _proxima("cab_esmaga"); }
		break;
	//BLOCO CAINDO EM CIMA DO CABEÇUDO PARADO: MORRE ESMAGADO
	case "cab_esmaga":
		if(_t == 1) peca_t = instance_create_layer(288 + 64, 56 + 16 * 16, "Blocos", obj_inimigo, { cabecudo : true });
		if(_t == 70) peca_t.cab_espera = 99999;
		if(_t == 80) { peca_o = _bloco(4, 12, cores.c_yellow); with(peca_o) { estou_parado = false; meu_timer = 5; timer_move = 5; } }
		if(_t == 300) { log("esmagado: cabecudo vivo=" + string(instance_exists(peca_t) and peca_t.vivo()) + " (esperado 0) bloco de cima y=" + string(peca_o.y) + " (esperado 344)"); _limpar(); _proxima("cab_player"); }
		break;
	//CABEÇUDO ANDANDO NA DIREÇAO DO PLAYER: CABEÇADA EMPURRA ELE (SEM DANO)
	case "cab_player":
		if(_t == 1) { peca_t = instance_create_layer(288 + 48, 56 + 16 * 16, "Blocos", obj_inimigo, { cabecudo : true }); passou = 0; }
		if(_t == 5) _player(400, 352);
		if(_t == 70) peca_t.dir = 1;
		if(_t > 70) passou = max(passou, obj_player.x);
		if(_t == 400) { log("cabecudo no player: player foi ate x=" + string(passou) + " (comecou em 400) vida=" + string(obj_player.vida_atual) + " estado dano=" + string(obj_player.estado == state.dano) + " cabecudo vivo=" + string(instance_exists(peca_t) and peca_t.vivo())); log("FIM"); game_end(); }
		break;
	#endregion

	#region GELATINA CAINDO NO PLAYER E BLOCO EMPURRADO PRA CIMA DELA
	//GELATINA CAINDO EM CIMA DO PLAYER PARADO: EMPURRA/ESMAGA COMO BLOCO NORMAL, SEM O PLAYER FICAR PRESO DENTRO DELA
	case "gel_cima":
		if(_t == 1) { peca_t = _gel(4, 17); with(peca_t) { estou_parado = false; meu_timer = 400; timer_move = 400; } _player(352, 352); viradas = 0; passou = 0; }
		if(_t == 20) with(obj_player) { velv = -vel_jump; estado = state.jump; }
		if(_t >= 20 and _t < 60) keyboard_key_press(global.imputs.jump);
		if(_t > 1 and instance_exists(peca_t))
		{
			if(place_meeting(obj_player.x, obj_player.y, peca_t)) { viradas++; passou = max(passou, viradas); } else viradas = 0; //FRAMES SEGUIDOS DENTRO DELA
		}
		if(_t == 40) screen_save("teste_e1_gel_cima.png");
		if(_t == 400) log("gelatina caindo no player: mais frames seguidos dentro dela=" + string(passou) + " (esperado 0 ou 1-2) player y=" + string(obj_player.y) + " estado=" + string(obj_player.estado) + " dentro agora=" + string(place_meeting(obj_player.x, obj_player.y, peca_t)));
		if(_t == 405) { _limpar(); player_longe(); _proxima("gel_empurra"); }
		break;
	//BLOCO EMPURRADO DE LADO PRA CIMA DA GELATINA: QUICA
	case "gel_empurra":
		if(_t == 1) { _bloco(4, 18); _gel(5, 18); peca_t = _bloco(4, 17, cores.c_yellow); viradas = 0; }
		if(_t == 30) with(peca_t) velocidade_h(1); //O MESMO QUE O SOCO FAZ
		if(_t > 30 and instance_exists(peca_t) and peca_t.gel_quicando) viradas = 1;
		if(_t == 120) { log("bloco empurrado pra cima da gelatina: quicou=" + string(viradas) + " (esperado 1) x=" + string(peca_t.x) + " (esperado 368)"); log("FIM"); game_end(); }
		break;
	#endregion

	#region PAREDE DA ARENA E BURACO
	//PULANDO CONTRA A PAREDE DA ARENA (OBJ_PAREDE) SEGURANDO PRO LADO: AGARRA SEM DAR ERRO
	case "parede_arena":
		if(_t == 5) _player(292, 280, state.jump);
		if(_t >= 5 and _t < 50) keyboard_key_press(global.imputs.left);
		if(_t == 30) log("parede da arena: estado=" + string(obj_player.estado) + " velv=" + string(obj_player.velv) + " x=" + string(obj_player.x) + " (sem erro, velv ~.3)");
		if(_t == 50) { keyboard_key_release(global.imputs.left); _limpar(); _proxima("buraco_fx"); }
		break;
	//BURACO: O BLOCO E ENGOLIDO GIRANDO, SAI DO PORTAL NO TOPO E CAI
	case "buraco_fx":
		if(_t == 1) { var _h = _bloco(7, 18); _h.sou_buraco = true; _h.sou_normal = false; _h.coloracao = -1; _player(320, 352); dir_antes = ""; }
		if(_t == 20) { peca_t = _bloco(7, 14, cores.c_yellow); with(peca_t) { estou_parado = false; meu_timer = 5; timer_move = 5; } }
		if(_t == 60) { peca_o = _bloco(7, 12, cores.c_red); with(peca_o) { estou_parado = false; meu_timer = 5; timer_move = 5; } viradas = 0; }
		//CONTA OS BLOCOS EM CHAMAS NASCENDO (CADA UM QUE APARECE NA FASE DE ENGOLIR)
		with(obj_bloco_fogo) if(fase == "engolir" and timer_fase == 1) { other.viradas++; other.log("engoliu o " + string(other.viradas) + "o bloco no frame " + string(_t) + " (fogos ao mesmo tempo: " + string(instance_number(obj_bloco_fogo)) + ")"); }
		with(obj_peca) if(sou_buraco and buraco_espera == round(BURACO_ESPERA / 2)) screen_save("teste_d4_recarregando.png");
		if(instance_exists(obj_bloco_fogo))
		{
			with(obj_bloco_fogo)
			{
				if(other.dir_antes != fase) { other.log("fogo fase=" + fase + " no frame " + string(_t) + " x=" + string(x) + " y=" + string(y)); other.dir_antes = fase; }
				if(fase == "engolir" and timer_fase == 12) screen_save("teste_d1_engolindo.png");
				if(fase == "portal" and timer_fase == 10) screen_save("teste_d2_portal.png");
				if(fase == "portal" and aviso == 0 and y > 150 and y < 152) screen_save("teste_d3_caindo.png");
			}
		}
		if(_t == 450) { log("buraco: engoliu " + string(viradas) + " (esperado 2) fogo existe=" + string(instance_exists(obj_bloco_fogo)) + " (esperado 0)"); log("FIM"); game_end(); }
		break;
	#endregion
	#region LENTO
	//GIRO NO CHAO: CORRE ATE ENCOSTAR NO BLOCO LENTO E GIRA
	case "lento_giro":
		if(_t == 1) { peca_t = _lento(5, 18); _player(344, 352); }
		if(_t >= 10 and _t < 24) keyboard_key_press(global.imputs.rigth);
		if(_t >= 20 and _t < 24) { keyboard_key_release(global.imputs.giro); keyboard_key_press(global.imputs.giro); }
		if(_t == 24) { keyboard_key_release(global.imputs.giro); keyboard_key_release(global.imputs.rigth); }
		if(_t == 21 or _t == 30) log("giro chao t=" + string(_t) + ": player x=" + string(obj_player.x) + " estado=" + string(obj_player.estado) + " bloco x=" + string(instance_exists(peca_t) ? peca_t.x : -1));
		if(_t == 100) log("lento (giro no chao): bloco existe=" + string(instance_exists(peca_t)) + " player.lento=" + string(obj_player.lento) + " (esperado 0 e 0: foi o player)");
		if(_t == 105) { _limpar(); _proxima("lento_quique"); }
		break;
	//GIRO NO AR: CAI GIRANDO EM CIMA DO BLOCO LENTO (QUIQUE)
	case "lento_quique":
		if(_t == 1) peca_t = _lento(5, 18);
		if(_t == 10) _player(368, 250, state.jump);
		if(_t >= 12 and _t < 16) { keyboard_key_release(global.imputs.giro); keyboard_key_press(global.imputs.giro); }
		if(_t == 16) keyboard_key_release(global.imputs.giro);
		if(_t == 80) log("lento (giro no ar): bloco existe=" + string(instance_exists(peca_t)) + " player.lento=" + string(obj_player.lento) + " (esperado 0 e 0: foi o player)");
		if(_t == 85) { _limpar(); _proxima("lento_baixo"); }
		break;
	//BAIXO + GIRO EM PE NO BLOCO LENTO
	case "lento_baixo":
		if(_t == 1) peca_t = _lento(5, 18);
		if(_t == 10) _player(368, 336);
		if(_t >= 20 and _t < 30) keyboard_key_press(global.imputs.down);
		if(_t >= 22 and _t < 26) { keyboard_key_release(global.imputs.giro); keyboard_key_press(global.imputs.giro); }
		if(_t == 26) keyboard_key_release(global.imputs.giro);
		if(_t == 30) keyboard_key_release(global.imputs.down);
		if(_t == 60) log("lento (baixo + giro): bloco existe=" + string(instance_exists(peca_t)) + " player.lento=" + string(obj_player.lento) + " (esperado 0 e 0: foi o player)");
		if(_t == 65) { _limpar(); player_longe(); obj_player.lento = 0; _proxima("lento_linha"); }
		break;
	//LINHA FECHANDO COM O BLOCO LENTO: AI O FEITIÇO PEGA NO PLAYER
	case "lento_linha":
		if(_t == 1) { for(var c = 0; c < 9; c++) _bloco(c, 18); _lento(9, 18); }
		if(_t == 120) log("lento (linha): player.lento=" + string(obj_player.lento) + " (esperado >0)");
		if(_t == 125) { _limpar(); player_longe(); obj_player.lento = 0; _proxima("gelo_parede"); }
		break;
	//PAREDE DE GELO: AGARRA MAS ESCORREGA RAPIDO, E O WALL JUMP E SO UM PULINHO
	case "gelo_parede":
		if(_t == 1) { for(var r = 12; r <= 18; r++) { var _b = _bloco(6, r); _b.sou_gelo = true; _b.sou_normal = false; _b.coloracao = -1; } passou = 0; dir_antes = 999; }
		if(_t == 15) _player(370, 280, state.jump);
		if(_t >= 15 and _t < 92) keyboard_key_press(global.imputs.rigth);
		if(_t == 27) { log("parede de gelo: velv=" + string(obj_player.velv) + " (esperado ~" + string(GELO_PAREDE_VEL) + ", na parede normal .3) y=" + string(obj_player.y)); passou = obj_player.y; }
		if(_t >= 28 and _t < 32) { keyboard_key_release(global.imputs.jump); keyboard_key_press(global.imputs.jump); }
		if(_t >= 28 and _t < 90) dir_antes = min(dir_antes, obj_player.y);
		if(_t == 90) log("wall jump no gelo: subiu " + string(passou - dir_antes) + "px (na parede normal sobe ~48px)");
		if(_t == 95) { _limpar(); player_longe(); _proxima("colmeia"); }
		break;
	#endregion

	#region COLMEIA
	//A COLMEIA SOLTA 2 ABELHAS DE CADA VEZ
	case "colmeia":
		if(_t == 1) { for(var c = 0; c < 9; c++) _bloco(c, 18, c mod 2 ? cores.c_red : cores.c_green); var _c = _bloco(5, 17); _c.sou_colmeia = true; _c.sou_normal = false; _c.coloracao = -1; peca_t = _c; viradas = 0; passou = 0; }
		if(_t > 1 and passou == 0 and instance_number(obj_abelha) > 0) { passou = _t; log("colmeia: primeiras abelhas no frame " + string(_t) + " (assentou no frame ~2): " + string(instance_number(obj_abelha))); }
		if(_t > 1) viradas = max(viradas, instance_number(obj_abelha));
		if(_t == 200) screen_save("teste_c1_abelhas.png");
		if(_t == 520) log("colmeia: no maximo " + string(viradas) + " abelhas voando juntas (esperado 2 ou mais) blocos=" + string(instance_number(obj_peca)) + " ABELHA_VEL=" + string(ABELHA_VEL));
		if(_t == 525) { _limpar(); _proxima("gel_quica"); }
		break;
	#endregion

	#region GELATINA
	//UM BLOCO CAI NA GELATINA E FICA QUICANDO. DEPOIS CAI OUTRO EM CIMA E OS DOIS ASSENTAM
	case "gel_quica":
		if(_t == 1) { _gel(4, 18); peca_t = _bloco(4, 15, cores.c_yellow); with(peca_t) { estou_parado = false; meu_timer = 5; timer_move = 5; } viradas = 0; dir_antes = 0; passou = 999; }
		if(_t > 1 and instance_exists(peca_t))
		{
			if(dir_antes >= 0 and peca_t.gel_vel < 0) viradas++; //CONTA OS QUIQUES (A VELOCIDADE FICOU NEGATIVA DE NOVO)
			dir_antes = peca_t.gel_vel;
			if(peca_t.gel_quicando) passou = min(passou, peca_t.y);
		}
		if(_t == 120) screen_save("teste_c2_gel_quicando.png");
		if(_t == 400) { log("gel: quiques=" + string(viradas) + " (esperado 3+) ainda quicando=" + string(peca_t.gel_quicando) + " (esperado 1) mais alto y=" + string(passou) + " (" + string((328 - passou) / 16) + " casas)"); peca_o = _bloco(4, 6, cores.c_red); with(peca_o) { estou_parado = false; meu_timer = 5; timer_move = 5; } }
		if(_t == 800) log("gel com outro bloco em cima: quicando=" + string(peca_t.gel_quicando) + " parado=" + string(peca_t.estou_parado) + " y=" + string(peca_t.y) + " (esperado 0, 1, 328) | de cima parado=" + string(peca_o.estou_parado) + " y=" + string(peca_o.y) + " (esperado 1, 312)");
		if(_t == 805) { _limpar(); _proxima("gel_peca"); }
		break;
	//PEÇA INTEIRA (I DEITADA) CAINDO NA GELATINA: SO O BLOCO QUE ENCOSTOU SAI E QUICA
	case "gel_peca":
		if(_t == 1) { _bloco(3, 18); _gel(4, 18); _bloco(5, 18); _bloco(6, 18); global.prox_gelo = false; criar(tipo_peca.I2, 4, cores.c_aqua); }
		if(_t == 25) { teleporte_acionar(); with(obj_area) alarm[0] = 99999; } //(ESPERA A GELATINA ASSENTAR)
		if(_t >= 25 and _t <= 28) with(obj_peca) if(coloracao == cores.c_aqua or sou_gelatina) other.log("gel_peca t=" + string(_t) + " " + (sou_gelatina ? "GEL" : "aqua") + " x=" + string(x) + " y=" + string(y) + " pai=" + string(sou_pai) + " irm=" + string(irmandade) + " parado=" + string(estou_parado) + " andar=" + string(andar) + " embaixo=" + string(gel_embaixo()) + " cima=" + string(gel_tem_cima()) + " quic=" + string(gel_quicando) + " ini=" + string(inicializando));
		if(_t == 80)
		{
			var _q = 0, _p = 0, _irm = 0;
			with(obj_peca) if(coloracao == cores.c_aqua) { if(gel_quicando) _q++; else if(estou_parado and y == 328) _p++; if(irmandade) _irm++; }
			log("I na gelatina: quicando=" + string(_q) + " (esperado 1) parados na linha 17=" + string(_p) + " (esperado 3) ainda na irmandade=" + string(_irm) + " (esperado 0)");
			screen_save("teste_c3_gel_peca.png");
		}
		if(_t == 85) { _limpar(); _proxima("trampolim"); }
		break;
	//PLAYER CAINDO NA GELATINA: E JOGADO PRA CIMA BEM MAIS ALTO QUE UM PULO
	case "trampolim":
		if(_t == 1) { _gel(4, 18); viradas = 999; dir_antes = 0; }
		if(_t == 10) _player(352, 260, state.jump);
		if(_t > 10)
		{
			if(obj_player.velv < 0) dir_antes = 1;
			if(dir_antes) viradas = min(viradas, obj_player.y);
		}
		if(_t == 60) screen_save("teste_c4_trampolim.png");
		if(_t == 150) log("trampolim: subiu ate y=" + string(viradas) + " = " + string(336 - viradas) + "px acima da gelatina (pulo normal ~48px, esperado ~53)");
		if(_t == 155) { _limpar(); _proxima("lateral"); }
		break;
	//PLAYER CORRENDO CONTRA A LATERAL DA GELATINA: E JOGADO PRO OUTRO LADO
	case "lateral":
		if(_t == 1) { _gel(6, 18); _player(320, 352); x_antes = 999; passou = 0; }
		if(_t >= 10 and _t < 80) keyboard_key_press(global.imputs.rigth);
		if(_t > 10) { passou = max(passou, obj_player.x); if(obj_player.velh < -1) x_antes = min(x_antes, obj_player.velh); }
		if(_t == 80) keyboard_key_release(global.imputs.rigth);
		if(_t == 120) log("lateral: chegou ate x=" + string(passou) + " (a gelatina comeca em x=376) velh mais forte pra tras=" + string(x_antes) + " (esperado -" + string(GEL_EMPURRAO) + ") x final=" + string(obj_player.x));
		if(_t == 125) { log("FIM"); game_end(); }
		break;
	#endregion
}

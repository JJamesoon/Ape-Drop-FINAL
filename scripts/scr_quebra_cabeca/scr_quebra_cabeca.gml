//DESAFIOS: CUBO MAGICO (OBJ_QUEBRA_CABECA) E MURO DO ENCAIXE (OBJ_ENCAIXE)==================================
//OS DOIS: AVISO DE 3S, TUDO PARA, ALGO DESCE QUEBRANDO OS BLOCOS (CADA UM TIRA PONTOS) E O JOGADOR RESOLVE COM AS SETAS.
//SE O QUE DESCE ENCOSTAR NO PLAYER, ELE MORRE
#macro QC_TESTE_ENTER	true				//PRA TESTAR: ENTER LIGA O CUBO E BACKSPACE O MURO DO ENCAIXE
#macro QC_ALERTA		(room_speed * 3)	//CONTAGEM ANTES DE TUDO PARAR (A GRADE VAI TREMENDO CADA VEZ MAIS)
#macro QC_FIM			(room_speed * 1.2)	//ESPINHOS VOLTANDO PRA CIMA
#macro QC_PASSOS_MAX	8					//ETAPAS DO CUBO (SEQUENCIAS CERTAS PRA COMPLETAR): COMEÇA COM 2-3 E VAI SUBINDO ATE ISSO
#macro QC_SETAS_MIN		3					//SETAS EM CADA SEQUENCIA
#macro QC_SETAS_MAX		5
#macro QC_ESPINHO_VEL	.15					//PX POR FRAME QUE OS ESPINHOS DESCEM
#macro QC_ERRO_DESCE	4					//ERROU A SETA: OS ESPINHOS DESCEM ISSO NA HORA
#macro QC_BONUS			3000				//PONTOS (X LEVEL) POR COMPLETAR O CUBO

//MURO DO ENCAIXE
#macro ENC_PECAS_MAX	6		//PEÇAS PRA ENCAIXAR: COMEÇA COM 2-3 E VAI SUBINDO ATE ISSO
#macro ENC_VEL			.12		//PX POR FRAME QUE O MURO DESCE
#macro ENC_ERRO_DESCE	6		//ENCAIXOU ERRADO: O MURO DESCE ISSO NA HORA
#macro ENC_INICIO		56		//O MURO JA ENTRA COM ESSA ALTURA (PRO BURACO APARECER)
#macro ENC_CELULA		6		//PX DE CADA CASA DA PEÇA 3D (SPRITE STACKING)
#macro ENC_BURACO		8		//PX DE CADA CASA DO BURACO NO MURO
#macro ENC_BONUS		3000	//PONTOS (X LEVEL) POR COMPLETAR

//APARECE SOZINHO (OU NO BLOCO ESPECIAL). QUANTO MELHOR O JOGADOR TA INDO, MAIS CHANCE
#macro QC_ESPERA_MIN	(room_speed * 120)	//TEMPO MINIMO SEM DESAFIO (NO COMEÇO E DEPOIS DE CADA UM). ERA 45S
#macro QC_CHANCE		.25					//CHANCE (0-100) POR SEGUNDO COM O JOGADOR INDO MAL... (BEM MAIS RARO: ERA .85)
#macro QC_CHANCE_BOM	1.25				//...E ATE ISSO A MAIS COM ELE INDO MUITO BEM (ERA 4.25)
#macro QC_RITMO_CAI		.999				//CADA LINHA FECHADA SOMA 1 NO RITMO, QUE VAI CAINDO (METADE A CADA ~11S)

//OS DESAFIOS SO APARECEM DEPOIS DE DESAFIO_TEMPO_MIN SEGUNDOS DE PARTIDA E COMEÇAM PEQUENOS:
//O 1O PEDE 2 OU 3 (ETAPAS DO CUBO OU PEÇAS DO MURO), CADA DESAFIO SEGUINTE PEDE 1 A MAIS, ATE O MAXIMO DE CADA UM
#macro DESAFIO_TEMPO_MIN	180		//SEGUNDOS DE PARTIDA (3 MINUTOS)
#macro DESAFIO_INICIO		2		//TAMANHO DO PRIMEIRO DESAFIO (+0 OU +1 SORTEADO)

//JA PODE APARECER DESAFIO NESSA PARTIDA? (DEPOIS DE 3 MINUTOS)
function desafio_liberado()
{
	return global.tempo_partida >= DESAFIO_TEMPO_MIN;
}

//QUANTAS ETAPAS/PEÇAS O PROXIMO DESAFIO PEDE (CRESCE A CADA DESAFIO DA PARTIDA, ATE _MAX)
function desafio_tamanho(_max)
{
	return clamp(DESAFIO_INICIO + global.desafios_feitos + irandom(1), DESAFIO_INICIO, _max);
}

//0 A 1: PILHA BAIXA, FECHANDO MUITAS LINHAS E FEBRE
function qc_desempenho()
{
	var _d = (1 - global.altura_pilha) * .35;
	_d += min(1, global.qc_ritmo / 6) * .45;
	if(global.febre > 0) _d += .2;
	return clamp(_d, 0, 1);
}

//TEM ALGUM DESAFIO RODANDO?
function desafio_ativo()
{
	return instance_exists(obj_quebra_cabeca) or instance_exists(obj_encaixe);
}

//PODE COMEÇAR UM DESAFIO AGORA? (SO NO ARCADE E SEM OUTRO RODANDO)
function desafio_pode()
{
	return modo_arcade() and !desafio_ativo() and instance_exists(obj_area);
}

//COMEÇA O CUBO MAGICO (DEVOLVE FALSE SE NAO PUDER)
function qc_iniciar()
{
	if(!desafio_pode()) return false;
	instance_create_depth(0, 0, -1600, obj_quebra_cabeca);
	zorg_falar("minigame");
	return true;
}

//COMEÇA O MURO DO ENCAIXE (DEVOLVE FALSE SE NAO PUDER)
function enc_iniciar()
{
	if(!desafio_pode()) return false;
	instance_create_depth(0, 0, -1600, obj_encaixe);
	zorg_falar("minigame");
	return true;
}

//RODA TODO FRAME NO OBJ_GAME_CONTROL (SO COM O JOGO RODANDO): SORTEIA UM DOS DOIS DESAFIOS
function qc_sortear()
{
	global.qc_ritmo *= QC_RITMO_CAI;
	if(!desafio_liberado()) exit; //SO DEPOIS DE 3 MINUTOS DE PARTIDA
	if(desafio_ativo()) { global.qc_espera = QC_ESPERA_MIN; exit; }
	if(global.qc_espera > 0) { global.qc_espera--; exit; }
	if(global.contagem > 0 or global.onda_timer > 0 or global.perigo) exit; //NAO EMBOLA COM A ONDA NEM COM A PILHA NO TOPO
	//CHANCE POR FRAME: (CHANCE BASE + EXTRA PELO DESEMPENHO) DIVIDIDO PELOS FRAMES DE UM SEGUNDO
	if(random(100) < (QC_CHANCE + QC_CHANCE_BOM * qc_desempenho()) / room_speed)
	{
		//METADE DAS VEZES CADA UM
		if(irandom(1) == 0) qc_iniciar();
		else enc_iniciar();
	}
}

//DURANTE O DESAFIO NAO NASCEM PEÇAS NEM VEM ONDA (OS ALARMES FICAM SEGURADOS). _PECAS: SEGURA OS DAS PEÇAS TAMBEM
function desafio_segurar(_pecas)
{
	with(obj_area) if(alarm[0] > 0) alarm[0]++;
	with(obj_cria_peca) if(alarm[0] > 0) alarm[0]++;
	with(obj_game_control) if(onda_proxima > 0) onda_proxima++;
	if(_pecas) with(obj_peca) for(var i = 0; i < 4; i++) if(alarm[i] > 0) alarm[i]++;
}

//SETA (0 = DIREITA, 1 = CIMA, 2 = ESQUERDA, 3 = BAIXO) COM CONTORNO ESCURO
function seta_desenhar(_x, _y, _dir, _tam, _cor, _a)
{
	//DIREÇAO DA SETA EM VETOR
	var _ang = _dir * 90;
	var _px = lengthdir_x(1, _ang), _py = lengthdir_y(1, _ang);	//PRA FRENTE
	var _qx = -_py, _qy = _px;									//PRO LADO
	var _t = _tam;
	draw_set_alpha(_a);
	//DESENHA DUAS VEZES: PRIMEIRO O CONTORNO ESCURO (UM POUCO MAIOR) E DEPOIS A SETA NA COR
	for(var k = 0; k < 2; k++)
	{
		var _c = k == 0 ? #0E071B : _cor;
		var _o = k == 0 ? _t * .22 : 0;
		var _pt = _t + _o, _lt = _t * .9 + _o, _ht = _t * .32 + _o;
		//PONTA DA SETA (TRIANGULO)
		draw_triangle_color(_x + _px * _pt, _y + _py * _pt,
			_x + _qx * _lt, _y + _qy * _lt,
			_x - _qx * _lt, _y - _qy * _lt, _c, _c, _c, false);
		//CABO DA SETA (RETANGULO)
		draw_primitive_begin(pr_trianglestrip);
		draw_vertex_color(_x + _qx * _ht, _y + _qy * _ht, _c, _a);
		draw_vertex_color(_x - _qx * _ht, _y - _qy * _ht, _c, _a);
		draw_vertex_color(_x + _qx * _ht - _px * (_t + _o), _y + _qy * _ht - _py * (_t + _o), _c, _a);
		draw_vertex_color(_x - _qx * _ht - _px * (_t + _o), _y - _qy * _ht - _py * (_t + _o), _c, _a);
		draw_primitive_end();
	}
	draw_set_alpha(1);
}

//ESPINHOS APONTANDO PRA BAIXO NUMA FILEIRA (PONTA EM _Y), DE _X1 ATE _X2
function espinhos_desenhar(_x1, _x2, _y)
{
	var _base = _y - 8;
	for(var xx = _x1; xx < _x2; xx += 8)
	{
		//CADA ESPINHO: SOMBRA ESCURA E O ESPINHO CLARO POR CIMA
		draw_triangle_color(xx, _base, xx + 8, _base, xx + 4, _base + 8, #6E6A88, #6E6A88, #6E6A88, false);
		draw_triangle_color(xx + 1, _base, xx + 5, _base, xx + 4, _base + 7, #E6E4F2, #E6E4F2, #B8B4CC, false);
	}
}

//AVISO DOS DESAFIOS (DRAW GUI): BORDA VERMELHA PULSANDO + NOME + CONTAGEM GRANDE
function desafio_alerta_desenhar(_texto, _timer, _a, _area)
{
	var _tl = gui_tela();
	var _e = gui_esc();
	var _cx = (_area.x + _area.sprite_width / 2) * _e;
	var _cy = (_area.y + _area.sprite_height * .4) * _e;
	var _pulso = .5 + .5 * sin(current_time / 120);
	//BORDA VERMELHA EM VOLTA DA TELA INTEIRA, PULSANDO
	var _b = 10 * _e;
	draw_set_alpha(_a * (.25 + .35 * _pulso));
	draw_set_color(c_red);
	draw_rectangle(_tl[0], _tl[1], _tl[2], _tl[1] + _b, false);
	draw_rectangle(_tl[0], _tl[3] - _b, _tl[2], _tl[3], false);
	draw_rectangle(_tl[0], _tl[1], _tl[0] + _b, _tl[3], false);
	draw_rectangle(_tl[2] - _b, _tl[1], _tl[2], _tl[3], false);
	draw_set_alpha(1);

	//NUMERO DA CONTAGEM (NASCE GRANDE E ENCOLHE A CADA SEGUNDO)
	var _num = ceil(_timer / room_speed);
	var _frac = (_timer mod room_speed) / room_speed;
	var _esc = (2.6 + 1.4 * power(_frac, 3)) * _e;
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	//NOME DO DESAFIO EM CIMA E O NUMERO COM CONTORNO
	draw_text_transformed_color(_cx + _e, _cy - 34 * _e + _e, _texto, _e * 1.2, _e * 1.2, 0, #0E071B, #0E071B, #0E071B, #0E071B, _a);
	draw_text_transformed_color(_cx, _cy - 34 * _e, _texto, _e * 1.2, _e * 1.2, 0, c_red, c_red, c_orange, c_orange, _a);
	for(var i = 0; i < 4; i++) draw_text_transformed_color(_cx + lengthdir_x(2 * _e, i * 90), _cy + lengthdir_y(2 * _e, i * 90), string(_num), _esc, _esc, 0, #0E071B, #0E071B, #0E071B, #0E071B, _a);
	draw_text_transformed_color(_cx, _cy, string(_num), _esc, _esc, 0, c_red, c_red, c_red, c_red, _a);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

//CUBO: 5 FACES VISIVEIS (0 = TOPO, 1 = FRENTE, 2 = DIREITA, 3 = TRAS, 4 = ESQUERDA), 9 ADESIVOS CADA
#macro QC_ADESIVO		5		//PX DE CADA ADESIVO
#macro QC_CUBO_W		(QC_ADESIVO * 3 + 4)	//LADO DO CUBO EM PX (COM AS LINHAS PRETAS)
global.qc_cores = [ #F4F4F4, #FF3237, #31FCFF, #FFE600, #8BFF32];

//CUBO EMBARALHADO (OS CENTROS FICAM CERTOS, IGUAL UM CUBO DE VERDADE)
function qc_cubo_novo()
{
	var _c = array_create(45, 0);
	//CADA FACE: O CENTRO E A COR DA FACE, O RESTO E SORTEADO
	for(var f = 0; f < 5; f++) for(var i = 0; i < 9; i++) _c[f * 9 + i] = i == 4 ? f : irandom(4);
	//GARANTE QUE TEM BASTANTE COISA FORA DO LUGAR
	for(var k = 0; k < 20; k++)
	{
		var _i = irandom(44);
		if(_i mod 9 != 4) _c[_i] = ((_i div 9) + 1 + irandom(3)) mod 5;
	}
	return _c;
}

//UMA ETAPA: ARRUMA UMA PARTE DOS ADESIVOS FORA DO LUGAR (NA ULTIMA ETAPA, TODOS)
function qc_cubo_resolver(_c, _etapas_restantes)
{
	var _errados = [];
	//LISTA DOS ADESIVOS NA COR ERRADA, EMBARALHADA
	for(var i = 0; i < 45; i++) if(_c[i] != i div 9) array_push(_errados, i);
	array_shuffle_ext(_errados);
	//QUANTOS ARRUMAR NESSA ETAPA (DIVIDE O QUE FALTA PELAS ETAPAS QUE FALTAM)
	var _n = _etapas_restantes <= 1 ? array_length(_errados) : ceil(array_length(_errados) / _etapas_restantes);
	for(var i = 0; i < _n; i++) _c[_errados[i]] = _errados[i] div 9;
}

//PIXEL BRANCO 1X1 PRA PINTAR NAS SURFACES (DRAW_POINT NA BORDA DA SURFACE FALHAVA: AS FACES DO LADO SAIAM PRETAS)
function qc_pixel_garantir()
{
	if(variable_global_exists("qc_pixel") and sprite_exists(global.qc_pixel)) exit;
	//DESENHA UM PIXEL BRANCO NUMA SURFACE 1X1 E VIRA SPRITE
	var _p = surface_create(1, 1);
	surface_set_target(_p);
	draw_clear(c_white);
	surface_reset_target();
	global.qc_pixel = sprite_create_from_surface(_p, 0, 0, 1, 1, false, false, 0, 0);
	surface_free(_p);
}

//MONTA AS FATIAS DO CUBO (FRAME 0 = FATIA DE BAIXO). CADA FATIA E O CORTE DO CUBO VISTO DE CIMA:
//AS BORDAS SAO OS ADESIVOS DAS FACES DO LADO E A ULTIMA FATIA E A FACE DO TOPO
function qc_cubo_sprite(_c)
{
	var _w = QC_CUBO_W, _s = QC_ADESIVO + 1;
	var _cores = global.qc_cores;
	var _preto = #101018;
	var _surf = surface_create(_w, _w);
	var _spr = -1;
	
	qc_pixel_garantir();
	var _px = global.qc_pixel, _a = QC_ADESIVO;
	//UMA FATIA POR LINHA DE ALTURA DO CUBO
	for(var h = 0; h < _w; h++)
	{
		surface_set_target(_surf);
		draw_clear(_preto);
		var _v = _w - 1 - h; //LINHA DA FACE DO LADO (0 = EM CIMA)
		//FATIA DE CIMA: OS 9 ADESIVOS DO TOPO
		if(h == _w - 1)
		{
			for(var r = 0; r < 3; r++) for(var k = 0; k < 3; k++)
			{
				draw_sprite_ext(_px, 0, 1 + k * _s, 1 + r * _s, _a, _a, 0, _cores[_c[r * 3 + k]], 1);
			}
		}
		//FATIAS DO MEIO (FORA AS LINHAS PRETAS ENTRE OS ADESIVOS): SO AS BORDAS, COM OS ADESIVOS DAS 4 FACES DO LADO
		else if(_v mod _s != 0)
		{
			var _r = _v div _s;
			for(var k = 0; k < 3; k++)
			{
				var _p0 = 1 + k * _s;
				draw_sprite_ext(_px, 0, _p0, _w - 1, _a, 1, 0, _cores[_c[9 * 1 + _r * 3 + k]], 1);				//FRENTE
				draw_sprite_ext(_px, 0, _w - 1, _w - 1 - _p0 - (_a - 1), 1, _a, 0, _cores[_c[9 * 2 + _r * 3 + (2 - k)]], 1);	//DIREITA
				draw_sprite_ext(_px, 0, _w - _p0 - _a, 0, _a, 1, 0, _cores[_c[9 * 3 + _r * 3 + k]], 1);				//TRAS
				draw_sprite_ext(_px, 0, 0, _p0, 1, _a, 0, _cores[_c[9 * 4 + _r * 3 + k]], 1);					//ESQUERDA
			}
		}
		surface_reset_target();
		//A PRIMEIRA FATIA CRIA A SPRITE, AS OUTRAS VIRAM FRAMES NOVOS
		if(_spr == -1) _spr = sprite_create_from_surface(_surf, 0, 0, _w, _w, false, false, _w / 2, _w / 2);
		else sprite_add_from_surface(_spr, _surf, 0, 0, _w, _w, false, false);
	}
	surface_free(_surf);
	return _spr;
}

//MURO DO ENCAIXE: PEÇAS==================================
//AS MESMAS PEÇAS DO JOGO (CASAS [X, Y]). O ESPELHO DO J VIRA L
global.enc_pecas = [
	[[0, 0], [1, 0], [2, 0], [1, 1]],	//T
	[[1, 0], [1, 1], [1, 2], [0, 2]],	//J
	[[1, 0], [2, 0], [0, 1], [1, 1]],	//S
	[[0, 0], [1, 0], [1, 1], [2, 1]],	//Z
	[[0, 0], [1, 0], [2, 0], [3, 0]],	//I
];
global.enc_cores = [ #8BFF32, #FFFF00, #DE65FF, #31FCFF, #FF3237];

//CASAS DA PEÇA ESPELHADA (_M) E GIRADA _R VEZES PRA ESQUERDA, DO MESMO JEITO QUE O DRAW_SPRITE_EXT DESENHA
//(PRIMEIRO ESPELHA NO X, DEPOIS GIRA). VOLTA AS CASAS ARRUMADAS A PARTIR DE [0, 0]
function enc_forma(_base, _r, _m)
{
	var _c = [];
	for(var i = 0; i < array_length(_base); i++)
	{
		var _x = _base[i][0] * (_m ? -1 : 1), _y = _base[i][1];
		repeat(((_r mod 4) + 4) mod 4) { var _t = _x; _x = _y; _y = -_t; } //90 GRAUS PRA ESQUERDA NA TELA
		array_push(_c, [_x, _y]);
	}
	//ARRASTA PRA COMEÇAR EM [0, 0]
	var _mx = 999, _my = 999;
	for(var i = 0; i < array_length(_c); i++) { _mx = min(_mx, _c[i][0]); _my = min(_my, _c[i][1]); }
	for(var i = 0; i < array_length(_c); i++) { _c[i][0] -= _mx; _c[i][1] -= _my; }
	return _c;
}

//TEXTO PRA COMPARAR DUAS FORMAS (A ORDEM DAS CASAS NAO IMPORTA)
function enc_forma_chave(_c)
{
	var _s = [];
	for(var i = 0; i < array_length(_c); i++) array_push(_s, _c[i][0] * 10 + _c[i][1]);
	array_sort(_s, true);
	return string(_s);
}

//MONTA A PEÇA 3D EM FATIAS (SPRITE STACKING), ORIGEM NO MEIO DELA. AS FATIAS DE BAIXO SAO A COR ESCURA (LADOS)
//E A DE CIMA E A COR NORMAL COM BRILHO. USA O PIXEL BRANCO DO CUBO (GLOBAL.QC_PIXEL)
function enc_peca_sprite(_base, _cor)
{
	qc_pixel_garantir();
	var _s = ENC_CELULA;
	var _w = 0, _h = 0;
	//TAMANHO DA PEÇA EM CASAS -> PIXELS
	for(var i = 0; i < array_length(_base); i++) { _w = max(_w, _base[i][0] + 1); _h = max(_h, _base[i][1] + 1); }
	_w *= _s;
	_h *= _s;
	var _escura = merge_color(_cor, c_black, .45);
	var _clara = merge_color(_cor, c_white, .45);
	var _surf = surface_create(_w, _h);
	var _spr = -1;
	var _px = global.qc_pixel;
	//UMA FATIA POR PIXEL DE ALTURA (A PEÇA TEM A ALTURA DE UMA CASA)
	for(var k = 0; k < _s; k++)
	{
		surface_set_target(_surf);
		draw_clear_alpha(c_black, 0);
		for(var i = 0; i < array_length(_base); i++)
		{
			var _x = _base[i][0] * _s, _y = _base[i][1] * _s;
			//FATIAS DE BAIXO: COR ESCURA (A PRIMEIRA AINDA MAIS ESCURA, COMO SOMBRA)
			if(k < _s - 1)
			{
				draw_sprite_ext(_px, 0, _x, _y, _s, _s, 0, _escura, 1);
				if(k == 0) draw_sprite_ext(_px, 0, _x, _y, _s, _s, 0, merge_color(_escura, c_black, .4), 1);
			}
			else
			{
				//FATIA DE CIMA: COR NORMAL COM LUZ EM CIMA/ESQUERDA E SOMBRA EMBAIXO/DIREITA
				draw_sprite_ext(_px, 0, _x, _y, _s, _s, 0, _cor, 1);
				draw_sprite_ext(_px, 0, _x, _y, _s, 1, 0, _clara, 1);
				draw_sprite_ext(_px, 0, _x, _y, 1, _s, 0, _clara, 1);
				draw_sprite_ext(_px, 0, _x, _y + _s - 1, _s, 1, 0, _escura, 1);
				draw_sprite_ext(_px, 0, _x + _s - 1, _y, 1, _s, 0, _escura, 1);
			}
		}
		surface_reset_target();
		if(_spr == -1) _spr = sprite_create_from_surface(_surf, 0, 0, _w, _h, false, false, _w / 2, _h / 2);
		else sprite_add_from_surface(_spr, _surf, 0, 0, _w, _h, false, false);
	}
	surface_free(_surf);
	return _spr;
}

//COMPLETOU UM DESAFIO: ALEM DOS PONTOS, GANHA UMA LETRA QUE FALTA (SE ELA TAVA NA ARENA OU NUM BLOCO, SAI DE LA)
function desafio_premio_letra(_x, _y)
{
	if(!modo_arcade()) exit;
	//NO COOP O PREMIO VAI PRO JOGADOR MAIS PERTO
	var _pp = player_perto(_x, _y);
	var _n = (_pp != noone and variable_instance_exists(_pp, "jogador")) ? _pp.jogador : 1;
	var _l = letras_de(_n);
	var _faltam = [];
	for(var i = 0; i < array_length(_l); i++) if(!_l[i]) array_push(_faltam, i);
	if(array_length(_faltam) == 0) exit;
	var _i = _faltam[irandom(array_length(_faltam) - 1)];
	with(obj_letra) if(letra == _i) instance_destroy();
	with(obj_peca) if(letra == _i) letra = -1;
	letra_coletar(_i, _x, _y, _n);
	letra_chamar_atencao(_x, _y - 20, _i);
}
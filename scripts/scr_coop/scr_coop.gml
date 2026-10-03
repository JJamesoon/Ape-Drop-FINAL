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
	with(obj_player) if(jogador == _n) { _r = id; break; }
	return _r;
}

//PLAYER VIVO MAIS PERTO DO PONTO (NOONE SE NAO TIVER NENHUM VIVO)
function player_perto(_x, _y)
{
	var _r = noone, _d = infinity;
	with(obj_player)
	{
		if(estado == state.morte) continue;
		var _dd = point_distance(_x, _y, x, y);
		if(_dd < _d) { _d = _dd; _r = id; }
	}
	return _r;
}

//TODOS OS PLAYERS ESTAO MORTOS? (SEM PLAYER NA ROOM = NAO)
function todos_mortos()
{
	if(!instance_exists(obj_player)) return false;
	var _vivo = false;
	with(obj_player) if(estado != state.morte) _vivo = true;
	return !_vivo;
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
	return global.coop ? global.record_coop : global.record_1;
}

//O ARCADE DE VERDADE: O RM_ARCADE (SOLO, OU O COOP ANTIGO NA ARENA ESTREITA) OU O RM_COOP (O COOP NA ARENA LARGA).
//TUDO QUE ERA "SO NO ARCADE" (BLOCOS NOVOS, ONDAS, LASER, LETRAS, PODERES, DESAFIOS...) VALE NOS DOIS
function modo_arcade()
{
	return room == rm_arcade or room == rm_coop;
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
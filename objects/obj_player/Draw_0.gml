//TREME JUNTO COM A ARENA
var shake_x = global.shake_x;
var shake_y = global.shake_y + global.lerp_y;

//PISCANDO ENQUANTO TA IMUNE (DEPOIS DE LEVAR DANO)
//GAMEFEEL: SOMBRAS DO DASH (AS POSIÇOES DOS ULTIMOS FRAMES, EM AZUL, SUMINDO)
if(estado == state.dash and !global.game_pause) array_push(rastro_dash, [x, y, sprite_index, image_index, esc_x, esc_y]);
if(array_length(rastro_dash) > 4 or (estado != state.dash and array_length(rastro_dash) > 0 and !global.game_pause)) array_delete(rastro_dash, 0, 1);
gpu_set_fog(true, #31FCFF, 0, 1);
for(var i = 0; i < array_length(rastro_dash); i++)
{
	var _r = rastro_dash[i];
	draw_sprite_ext(_r[2], _r[3], _r[0] + shake_x, _r[1] + shake_y, _r[4], _r[5], 0, c_white, .15 + .1 * i);
}
gpu_set_fog(false, c_white, 0, 1);

//PISCANDO ENQUANTO TA IMUNE (DEPOIS DE LEVAR DANO)
var _alpha = (imune > 0 and !imune_escudo and mortal <= 0 and (imune div 4) mod 2 == 0) ? .3 : 1; //BLOQUEIO DO ESCUDO NAO PISCA
if(pisca_dano > 0 and (pisca_dano div 4) mod 2 == 0) _alpha = .3; //COOP: PISAO DO PARCEIRO
var _ang = mortal > 0 ? -360 * (1 - mortal / 18) * sign(image_xscale) : 0; //MORTAL DA ESQUIVA (REFLEXO)
var _yd = mortal > 0 ? -10 : 0; //NO MORTAL GIRA EM VOLTA DO MEIO DO CORPO (A ORIGEM DA SPRITE E NO PE)
aqua_inicio(); //BLOCO RAIO LIGADO: O PLAYER SAI AQUA
draw_sprite_ext(sprite_index, image_index, x + shake_x + lengthdir_x(10, _ang - 90) * (mortal > 0), y + shake_y + _yd + lengthdir_y(10, _ang - 90) * (mortal > 0), esc_x, esc_y, _ang, c_white, _alpha);
aqua_fim();
//GIRO DE FOGO: O PERSONAGEM FICA PISCANDO LARANJA E, GIRANDO, AS CHAMAS DO GIRO (SPR_GIRO_FIRE) POR CIMA
if(em_fogo() and estado != state.morte)
{
	gpu_set_fog(true, #FF7A1A, 0, 1);
	draw_sprite_ext(sprite_index, image_index, x + shake_x, y + shake_y, esc_x, esc_y, 0, c_white, .25 + .15 * sin(current_time / 60));
	gpu_set_fog(false, c_white, 0, 1);
	if(estado == state.giro) draw_sprite_ext(spr_giro_fire, current_time / 50, x + shake_x, y + shake_y, esc_x, esc_y, 0, c_white, 1);
}

//RAPIDO (QUEBROU O BLOCO LENTO): DOIS RASTROS AMARELOS ATRAS DELE (PISCA NO FINAL)
if(rapido > 0 and estado != state.morte and !(rapido < room_speed and (rapido div 5) mod 2 == 0))
{
	gpu_set_fog(true, #FFE600, 0, 1);
	for(var k = 2; k >= 1; k--) draw_sprite_ext(sprite_index, image_index, x + shake_x - velh * 3 * k, y + shake_y - velv * 2 * k, esc_x, esc_y, 0, c_white, .35 / k);
	gpu_set_fog(false, c_white, 0, 1);
}

//FEITIÇO DO BLOCO LENTO: O PERSONAGEM FICA ROXO E A ESPIRAL GIRA EM CIMA DA CABEÇA (PISCA NO FINAL)
if(lento > 0 and estado != state.morte and !(lento < room_speed and (lento div 5) mod 2 == 0))
{
	gpu_set_fog(true, #9A5CFF, 0, 1);
	draw_sprite_ext(sprite_index, image_index, x + shake_x, y + shake_y, esc_x, esc_y, 0, c_white, .45 + .1 * sin(current_time / 120));
	draw_sprite_ext(spr_icone_lento, 0, x + shake_x, bbox_top - 8 + shake_y, 1.5, 1.5, -current_time / 4, c_white, .4);
	gpu_set_fog(false, c_white, 0, 1);
	draw_sprite_ext(spr_icone_lento, 0, x + shake_x, bbox_top - 8 + shake_y, 1.1, 1.1, -current_time / 4, c_white, 1);
}

//BRILHO BRANCO POR CIMA (ALPHA_FOG)
gpu_set_fog(true, c_white, 0, 1);	
draw_sprite_ext(sprite_index, image_index, x + shake_x, y + shake_y, esc_x, esc_y, 0, c_white, alpha_fog * (mortal <= 0));
gpu_set_fog(false, c_white, 0, 1);

//ESCUDO: BOLHA EM VOLTA DO PLAYER (MAIS FRACA CONFORME PERDE RESISTENCIA)
if(tem_poder("escudo") and !escudo_quebrado and estado != state.morte)
{
	var _ea = (.25 + .45 * escudo_vida / 100) * (.85 + .15 * sin(current_time / 200));
	draw_set_alpha(_ea);
	draw_set_color(#5CC8FF);
	draw_circle(x + shake_x, y + shake_y - 10, 13, true);
	draw_circle(x + shake_x, y + shake_y - 10, 12, true);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

//ESCUDO BLOQUEOU: A BOLHA ACENDE (PREENCHIDA), UM ANEL CRESCE E SAEM FAISCAS DO LADO ONDE BATEU
if(escudo_bloqueio > 0 and estado != state.morte)
{
	var _bp = escudo_bloqueio / 20;	//1 NO COMEÇO, 0 NO FIM
	var _bx = x + shake_x, _by = y + shake_y - 10;
	draw_set_color(#BDEBFF);
	draw_set_alpha(.45 * _bp);
	draw_circle(_bx, _by, 13, false);
	draw_set_alpha(_bp);
	draw_set_color(c_white);
	var _r = 13 + 10 * (1 - _bp);
	draw_circle(_bx, _by, _r, true);
	draw_circle(_bx, _by, _r - 1, true);
	//FAISCAS DO LADO DO IMPACTO
	draw_set_color(#5CC8FF);
	var _base = escudo_lado > 0 ? 0 : 180;
	for(var k = -1; k <= 1; k++)
	{
		var _a = _base + k * 35;
		var _d1 = 13 + 3 * (1 - _bp), _d2 = _d1 + 6 * _bp;
		draw_line_width(_bx + lengthdir_x(_d1, _a), _by + lengthdir_y(_d1, _a), _bx + lengthdir_x(_d2, _a), _by + lengthdir_y(_d2, _a), 2);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}


//DEBUG: PONTOS DE COLISAO
//DRAW_SPRITE(SPR_MASK, 0, X, Y);
if(DEBUG)
{
	draw_set_colour(c_black)
	draw_circle(x, y - sprite_height/3, 1, 5)
	draw_set_colour(c_lime)
	draw_circle(x, y + 8, 1, 5)
	draw_set_colour(c_white)
}

//O SQUASH/STRETCH E O BRILHO VOLTAM AO NORMAL AOS POUCOS
esc_x = lerp(esc_x, image_xscale, .1);
esc_y = lerp(esc_y, image_yscale, .1);
alpha_fog = lerp(alpha_fog, 0, .1);

//COOP: ETIQUETA "P1"/"P2" EM CIMA DA CABEÇA (OS DOIS PODEM TER A MESMA SKIN)
if(global.coop and estado != state.morte)
{
	var _tc = jogador == 2 ? COOP_COR_P2 : COOP_COR_P1;
	var _tx = x + shake_x, _ty = bbox_top - 8 + shake_y;
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed_color(_tx + 1, _ty + 1, "P" + string(jogador), .6, .6, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
	draw_text_transformed_color(_tx, _ty, "P" + string(jogador), .6, .6, 0, _tc, _tc, _tc, _tc, 1);
	draw_triangle_color(_tx - 2, _ty + 4, _tx + 2, _ty + 4, _tx, _ty + 6, _tc, _tc, _tc, false);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

//DEBUG: MOSTRA O ESTADO
if(DEBUG) draw_text(x, y - 25, estado);

//DICA DO ESPECIAL: EM PE EM CIMA DE UM BLOCO QUE O ESPECIAL PODE DESTRUIR, MOSTRA A TECLA
var _pb = peca_solida(x, y + 1);
if(_pb and _pb.pode_especial and global.energia >= 1 and estado != state.morte)
{
	var _txt = tecla_nome(imp.down) + " + " + tecla_nome(imp.soco);
	var _yy = bbox_top - (global.coop ? 20 : 12) + sin(current_time / 150) * 2; //NO COOP FICA ACIMA DA ETIQUETA
	draw_set_font(fnt_hud);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_transformed_color(x + 1, _yy + 1, _txt, .8, .8, 0, #0E071B, #0E071B, #0E071B, #0E071B, 1);
	draw_text_transformed_color(x, _yy, _txt, .8, .8, 0, #31FCFF, #31FCFF, #31FCFF, #31FCFF, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}
//CODIGO ANTIGO DESLIGADO (SUBIR NO BLOCO AGARRANDO A BEIRADA)
/*
IF(ESTADO == STATE.JUMP)
{
	VAR _X = X;
	VAR _XX = X + 10*IMAGE_XSCALE;
	VAR _Y = BBOX_TOP + 8;
	VAR _YY = _Y - 15;
	
	DRAW_RECTANGLE(_X, _Y, _XX, _YY, 1);
	VAR _BLOCK = COLLISION_RECTANGLE(_X, _Y, _XX, _YY, OBJ_PECA, 0, 1);
	IF(_BLOCK)
	{
		IF(BBOX_TOP <= _BLOCK.BBOX_TOP+4 AND VELV > -2)
		{
			VAR _CLIMB = FALSE;
			WITH(_BLOCK)
			{
				IF(!PLACE_MEETING(X, Y - 2, OBJ_PECA))
				{
					_CLIMB = TRUE;
				}
			}
			IF(_CLIMB)
			{
				VELH = 0;
				VELV = 0;
				MEU_CLIMB = _BLOCK;
				ESTADO = STATE.CLIMB;
				NOVA_SPR(SPR_PLAYER_CLIMB);
				X = _BLOCK.X - (8*IMAGE_XSCALE);
				Y = _BLOCK.Y - 8;
			}
		}
	}
}


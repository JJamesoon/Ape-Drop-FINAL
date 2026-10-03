//TEXTO CENTRALIZADO PRO PLACAR DE BLOCOS
draw_set_font(fnt_mini_hud);

draw_set_valign(1);
draw_set_halign(1);

//TREME JUNTO COM A TELA (E O EMPURRAOZINHO DO TELEPORTE)
var shake_x = global.shake_x;
var shake_y = global.shake_y + global.lerp_y;
//DRAW_SELF()

var _minha_linha = instance_place(x, y, obj_linha);

//DRAW_SPRITE(SPR_LINHA, 1, _MINHA_LINHA.X, _MINHA_LINHA.Y);

//DENTRO DA ARENA: UM PRETO MEIO TRANSPARENTE POR CIMA DA PAREDE DE AZULEJOS (IGUAL AO PROJETO ANTIGO), PROS BLOCOS APARECEREM
if(modo_arcade())
{
	draw_set_alpha(FUNDO_ARENA);
	draw_set_color(c_black);
	draw_rectangle(x + shake_x, y + shake_y, x + sprite_width - 1 + shake_x, y + sprite_height - 1 + shake_y, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

//FUNDO DA ARENA
if(modo_arcade()) borda_desenhar(spr_borda, 0, x + shake_x, y + shake_y, sprite_width - sprite_get_width(spr_area));
else draw_sprite(spr_borda_vesus, 0, x + shake_x, y + shake_y);



//DETECTANDO LINHAS COMPLETAS (TODAS AS CELULAS DA LINHA COM 1 NA GRID)
//A LIMPEZA (EFEITO, PONTOS, CHAO E CONTAGEM DO ANDAR) FICA NO LIMPAR_LINHAS() DO CREATE
var _linhas = [];
for(var j = 0; j < lins; j++)
{
	var _completa = true;
	for(var i = 0; i < cols; i++)
	{
		if(global.grid[# i, j] != 1)
		{
			_completa = false;
			break;
		}
	}
	if(_completa) array_push(_linhas, j);
}
if(timer_reset == 0 and array_length(_linhas) > 0) limpar_linhas(_linhas);

//CODIGO ANTIGO DESLIGADO: O QUEBRA-CABEÇA ANTIGO DAS SETAS COM ESPINHOS NAS LATERAIS
////ESTADO DE AREA FANTASMA COM ESPINHOS
//IF(GLOBAL.ROOM_STATE == "FANTASMA")
//{
//	//CETAS
//	IF(QTD_CETAS == NOONE)
//	{
//		QTD_CETAS = IRANDOM_RANGE(3, 5);
//		REPEAT(QTD_CETAS)
//		{
//			ARRAY_PUSH(ALPHA_GERAL, 1);
//			ARRAY_PUSH(ALPHA_CETAS, 0);
//			ARRAY_PUSH(ARRAY_CETAS, CHOOSE(0, 90, 180, 270));
//			ARRAY_PUSH(ALPHA_FOG, 0); 
//			ARRAY_PUSH(ALPHA_FOG_ERROR, 0); 
//		}
//	}
	
//	VAR _LEFT	= KEYBOARD_CHECK_PRESSED(ORD("A"));
//	VAR _UP		= KEYBOARD_CHECK_PRESSED(ORD("W"));
//	VAR _RIGHT	= KEYBOARD_CHECK_PRESSED(ORD("D"));
//	VAR _DOWN	= KEYBOARD_CHECK_PRESSED(ORD("S"));

	
//	VAR _MARG = 10;
//	VAR _LARGURA_TOTAL = QTD_CETAS * SPRITE_GET_WIDTH(SPR_CETAS) + (QTD_CETAS - 1) * _MARG;
//    VAR _X = X + SPRITE_WIDTH / 2 - _LARGURA_TOTAL / 2;
//	VAR _Y = ROOM_HEIGHT - SPRITE_GET_HEIGHT(SPR_CETAS) - 10;
	
//	FOR(VAR I = 0; I < QTD_CETAS; I++)
//	{
//		_X += RANDOM_RANGE(-ARRAY_SHAKE, ARRAY_SHAKE);
//		_Y += RANDOM_RANGE(-ARRAY_SHAKE, ARRAY_SHAKE);
		
//		DRAW_SPRITE_EXT(SPR_CETAS, 0, _X + (_MARG + SPRITE_GET_WIDTH(SPR_CETAS)) * I, _Y, 1, 1, ARRAY_CETAS[I], C_WHITE, ALPHA_GERAL[I]);
//		DRAW_SPRITE_EXT(SPR_CETAS, 0, _X + (_MARG + SPRITE_GET_WIDTH(SPR_CETAS)) * I, _Y, 1, 1, ARRAY_CETAS[I], C_GREEN, ALPHA_FOG[I]);
//		DRAW_SPRITE_EXT(SPR_CETAS, 0, _X + (_MARG + SPRITE_GET_WIDTH(SPR_CETAS)) * I, _Y, 1, 1, ARRAY_CETAS[I], C_RED, ALPHA_FOG_ERROR[I]);
		
//		IF(I < ACERTOS)  ALPHA_GERAL[I] = LERP(ALPHA_GERAL[I], .5, .2);
//		ELSE			 ALPHA_GERAL[I] = LERP(ALPHA_GERAL[I], 1, .35);
		
//		ALPHA_FOG[I] = LERP(ALPHA_FOG[I], 0, .2);
//		ARRAY_SHAKE = LERP(ARRAY_SHAKE, 0, .05);
//		ALPHA_FOG_ERROR[I] = LERP(ALPHA_FOG_ERROR[I], 0, .2);
		
//	}
//	IF (_LEFT || _UP || _DOWN || _RIGHT)
//		{
//		    VAR _DIR = POINT_DIRECTION(0, 0, _RIGHT - _LEFT, _DOWN - _UP);
//		    IF(_DIR == ARRAY_CETAS[ACERTOS])
//			{
//				IF(ACERTOS <= QTD_CETAS)
//				{
//					ALPHA_FOG[ACERTOS] = 1;
//					IF(ACERTOS < QTD_CETAS)ACERTOS++;
//				}
//			}ELSE
//			{
//				ALPHA_FOG_ERROR[ACERTOS] = 1;
//				ACERTOS = 0;
//				ARRAY_SHAKE = 1;
//			}
//		}
	
//	IF(FECHANDO)
//	{
//		IF(ALARM[1] == -1) ALARM[1] = ROOM_SPEED*2.5;
//		POS_ESPINHOS_X[0] = LERP(POS_ESPINHOS_X[0], PROX_ESPINHOS_X[0], .1);
//		POS_ESPINHOS_X[1] = LERP(POS_ESPINHOS_X[1], PROX_ESPINHOS_X[1], .1);
//	}
//	FOR(VAR I = 0; I < 2; I++)
//	{
//		IF(!FECHANDO)
//		{
//			POS_ESPINHOS_X[I] = LERP(POS_ESPINHOS_X[I], X, .3);
//			POS_ESPINHOS_Y[I] = LERP(POS_ESPINHOS_Y[I], Y, .3);
//			IF(POS_ESPINHOS_X[I] == X) FECHANDO = TRUE;
//		}
		
//		DRAW_SPRITE(SPR_BORDA_ESPINHOS, I, POS_ESPINHOS_X[I], POS_ESPINHOS_Y[I]);
//	}
//}


///DEBUGS==============================
//DRAW_RECTANGLE(X, Y + CEL, X + SPRITE_WIDTH, (Y + CEL) - CEL*3, 1);
//CRIANDO PECASS COM O MOUSE

//SO FUNCIONA COM A MACRO DEBUG LIGADA (SCRIPT GLOBAIS)
if(DEBUG)
{
//ALT APERTADO: O CLIQUE CRIA UMA AREA DE DANO EM VEZ DE UMA PEÇA
var _index = cr_handpoint;
var _cor = c_aqua;
if(keyboard_check(vk_alt)) 
{
	_cor = c_red
	_index = cr_size_all
}
window_set_cursor(_index);

//MOUSE DENTRO DA ARENA: MOSTRA A CASA E CRIA NO CLIQUE
if(mouse_x > x and mouse_x < x + sprite_width and mouse_y > y and mouse_y < y + sprite_height)
{
	var base_x = x;
	var base_y = y;
	
	var _x = (base_x + ((mouse_x - base_x) div CEL) * CEL) + 8;
	var _y = (base_y + ((mouse_y - base_y) div CEL) * CEL) + 8;
	
	//DRAW_TEXT(_X - 8, _Y - 8, (MOUSE_X - X) DIV CEL)
	//DRAW_TEXT(_X - 8, _Y - 8, (MOUSE_Y - Y) DIV CEL)
	

	
	draw_sprite_ext(spr_cria_peca, 0, _x, _y, 1, 1,0, _cor, 1);
	if(mouse_check_button_pressed(mb_left))
	{
		if(_index == cr_handpoint)
		{	
			var _criador = instance_create_layer(_x, _y, "Blocos", obj_cria_peca);
			//_CRIADOR.TIPO = "BLOCO_UNICO_DEBUG";
		}else if(_index == cr_size_all)
		{
			var dano = instance_create_layer(_x, _y, "Blocos", obj_dano);
		}
	}
}
}

//PLACAR DE BLOCOS POR COR EMBAIXO DA ARENA (DESLIGADO POR PADRAO)
if(somar_blocos_hud)
{
	var _y = y + sprite_height + 22;
	var _y_array = [_y, _y + sprite_get_height(spr_cx_blocos), _y, _y + sprite_get_height(spr_cx_blocos), _y];

	for(var i = 0; i < 5; i++)
	{
		blocos_cx[blocos_caixa.esc][i] = lerp(blocos_cx[blocos_caixa.esc][i], 1, .2);
		blocos_cx[blocos_caixa.alpha][i] = lerp(blocos_cx[blocos_caixa.alpha][i], 0, .2);
		
		_x = (x - 12) + (sprite_get_width(spr_cx_blocos)*.9) * i;
		
		draw_sprite(spr_cx_blocos, 0, _x, _y_array[i]);
		draw_sprite_ext(spr_cx_mini_blocos, i, _x - 16, _y_array[i] + 1, blocos_cx[blocos_caixa.esc][i], blocos_cx[blocos_caixa.esc][i], 0, c_white, 1);
		
		draw_text_colour(_x + 8, _y_array[i], blocos_cx[blocos_caixa.qtd][i], c_white, c_white, c_white, c_white, 1);
		draw_text_colour(_x + 8, _y_array[i], blocos_cx[blocos_caixa.qtd][i], c_green, c_green, c_green, c_green, blocos_cx[blocos_caixa.alpha][i]);
		
		//GUARDA ONDE CADA CAIXINHA FICA (A PEÇA QUE CAI VOA PRA LA)
		if(array_length(blocos_cx[blocos_caixa.pos_x]) < 5) 
		{
			array_push(blocos_cx[blocos_caixa.pos_x], _x - 16)
			array_push(blocos_cx[blocos_caixa.pos_y], _y_array[i] + 1 - 16)
		}
	}
	//SHOW_MESSAGE(BLOCOS_CX_X)
}

//VOLTA O PADRAO DE TEXTO
draw_set_font(-1);
draw_set_valign(-1);
draw_set_halign(-1);


//DEBUG ANTIGO DESLIGADO
/////DEBUGS==============================
////DRAW_TEXT(30, 30, GLOBAL.LINHAS_COMPLETADAS);
//DRAW_TEXT(30, 30, GLOBAL.PECA_INST)
//DRAW_TEXT(30, 60, GLOBAL.PROX_PECA_INT)

//IF(KEYBOARD_CHECK(VK_SPACE)) 
//{
//	POS_X = LERP(POS_X, MEU_X + 10, .25);
//	POS_Y = LERP(POS_Y, MEU_Y + 10, .25);
	
//	WITH(OBJ_PAREDE) 
//	{
//		POS_X = LERP(POS_X, MEU_X + 10, .25);
//		POS_Y = LERP(POS_Y, MEU_Y + 10, .25);
//	}
//	WITH(OBJ_PECA) 
//	{
//		POS_X = LERP(POS_X, X + 10, .25);
//		POS_Y = LERP(POS_Y, Y + 10, .25);
//	}
//}
//ELSE
//{
	
//	WITH(OBJ_PECA)
//	{
//		POS_X = LERP(POS_X, X, .25);
//		POS_Y = LERP(POS_Y, Y, .25);
//	}
//	POS_X = LERP(POS_X, MEU_X, .25);
//	POS_Y = LERP(POS_Y, MEU_Y, .25);
//}


//DEBUG: ANDAR E LINHAS FEITAS NO CANTO
if(DEBUG)
{
	draw_text(15, 15, global.andar);
	draw_text(15, 45, global.linhas_completadas);
}
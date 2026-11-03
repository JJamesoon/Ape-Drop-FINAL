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

//FUNDO DA ARENA (O DE CADA MODO FICA NO CREATE DO OBJ_AREA OU DO FILHO)
desenhar_fundo(shake_x, shake_y);



//TEMPO PARADO, PREVIA DA QUEDA: UM FEIXE DE LUZ VERDE SAINDO DE BAIXO DOS BLOCOS QUE VAO CAIR, SUMINDO NA PONTA (POR BAIXO DOS BLOCOS)
if(global.tempo_fase == "parado" or global.tempo_fase == "contagem")
{
	var _pulso = .8 + .2 * sin(current_time / 180);
	gpu_set_blendmode(bm_add);
	for(var i = 0; i < array_length(global.tempo_rastros); i++)
	{
		var _r = global.tempo_rastros[i], _fx = _r[0] + shake_x, _t = _r[1] + CEL / 2 + shake_y, _b = _r[2] + shake_y;
		if(_b <= _t) continue;
		//HALO LARGO E NUCLEO FINO, OS DOIS SUMINDO PRA BAIXO
		draw_primitive_begin(pr_trianglestrip);
		draw_vertex_colour(_fx - 7, _t, TEMPO_VERDE, .22 * _pulso);
		draw_vertex_colour(_fx + 7, _t, TEMPO_VERDE, .22 * _pulso);
		draw_vertex_colour(_fx - 7, _b, TEMPO_VERDE, 0);
		draw_vertex_colour(_fx + 7, _b, TEMPO_VERDE, 0);
		draw_primitive_end();
		draw_primitive_begin(pr_trianglestrip);
		draw_vertex_colour(_fx - 2.3, _t, c_white, .4 * _pulso);
		draw_vertex_colour(_fx + 2.3, _t, c_white, .4 * _pulso);
		draw_vertex_colour(_fx - 2.3, _b, TEMPO_VERDE, 0);
		draw_vertex_colour(_fx + 2.3, _b, TEMPO_VERDE, 0);
		draw_primitive_end();
	}
	gpu_set_blendmode(bm_normal);
}

//TELEPORTE DO TEMPO PARADO: DE CADA BLOCO SAI UM FEIXE VERDE; NO LUGAR DE ONDE ELE SAIU FICA UMA SOMBRA VERDE QUE VAI SUMINDO
for(var i = array_length(global.tempo_sombras) - 1; i >= 0; i--)
{
	var _s = global.tempo_sombras[i];
	var _t = 1 - _s.idade / TEMPO_SOMBRA_VIDA;
	if(_t <= 0) { array_delete(global.tempo_sombras, i, 1); continue; }
	_s.idade++;
	var _sx = _s.x + shake_x, _s0 = _s.y0 + shake_y, _s1 = _s.y1 + shake_y;
	//SOMBRA NO LUGAR DE ONDE O BLOCO SAIU: SILHUETA VERDE, BRILHO E UM CONTORNO QUE ABRE
	if(sprite_exists(_s.spr))
	{
		gpu_set_fog(true, TEMPO_VERDE, 0, 1);
		draw_sprite_ext(_s.spr, _s.img, _sx, _s0, 1, 1, 0, c_white, .8 * _t);
		gpu_set_fog(false, c_white, 0, 1);
	}
	gpu_set_blendmode(bm_add);
	draw_set_color(TEMPO_VERDE);
	draw_set_alpha(.4 * _t);
	draw_rectangle(_sx - 8, _s0 - 8, _sx + 7, _s0 + 7, false);
	var _ab = (1 - _t) * 6;
	draw_set_alpha(.8 * _t);
	draw_rectangle(_sx - 8 - _ab, _s0 - 8 - _ab, _sx + 7 + _ab, _s0 + 7 + _ab, true);
	draw_set_alpha(1);
	draw_set_color(c_white);
	//FEIXE: FORTE NO BLOCO (LUGAR NOVO) E AFINANDO ATE A SOMBRA
	var _w = 8 * (.5 + .5 * _t);
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_colour(_sx - _w, _s1, TEMPO_VERDE, .7 * _t);
	draw_vertex_colour(_sx + _w, _s1, TEMPO_VERDE, .7 * _t);
	draw_vertex_colour(_sx - _w, _s0, TEMPO_VERDE, .25 * _t);
	draw_vertex_colour(_sx + _w, _s0, TEMPO_VERDE, .25 * _t);
	draw_primitive_end();
	gpu_set_blendmode(bm_normal);
	//COPIAS DO BLOCO PELO CAMINHO, MAIS FRACAS QUANTO MAIS LONGE DELE
	if(sprite_exists(_s.spr))
	{
		gpu_set_fog(true, TEMPO_VERDE, 0, 1);
		for(var k = 1; k <= 4; k++)
		{
			var _f = k / 5;
			draw_sprite_ext(_s.spr, _s.img, _sx, lerp(_s1, _s0, _f), 1, 1, 0, c_white, .5 * _t * (1 - _f));
		}
		gpu_set_fog(false, c_white, 0, 1);
	}
}

//LINHAS COMPLETAS (CADA MODO TEM A SUA DETECÇAO: DETECTAR_LINHAS)
detectar_linhas();

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
//ARENA DO MODO COOP (ARENA LARGA): DESENHA A ARENA E A GRADE, E PROCURA LINHAS COMPLETAS (CODIGO ANTIGO)
draw_set_font(fnt_mini_hud);
draw_set_valign(1);
draw_set_halign(1);

//TREME JUNTO COM A TELA
var shake_x = global.shake_x;
var shake_y = global.shake_y + global.lerp_y;

draw_self()
var _minha_linha = instance_place(x, y, obj_linha_coop);

//DRAW_SPRITE(SPR_LINHA, 1, _MINHA_LINHA.X, _MINHA_LINHA.Y);

draw_sprite(spr_borda_coop, 0, x + shake_x, y + shake_y);

//NUMERO DO PLAYER EM CIMA DA ARENA
draw_text(x + 50, y - 15, 1);

var _cont = 0;
var _linhas = [];
var _line = false;

//PASSA POR TODAS AS LINHAS: DESENHA A GRADE E VE QUAIS ESTAO COMPLETAS
for(var j = 0; j < lins; j++)
{
	var linha_completa = true;
	for(var i = 0; i < cols; i++)
	{
		var _x = (x+shake_x) + cel * i;
		var _y = (y+shake_y) + cel * j;
		
		//DRAW_TEXT(_X, _Y, GLOBAL.GRID[# I, J]);
		
		draw_line(_x, y, _x, y + sprite_height);
		draw_line(x, _y, x + sprite_width, _y);
		
		if(global.grid_2[# i, j] != 1) linha_completa = false;
	}
	if(linha_completa) 
	{
		
		//IF(_CONT == 0) _CONT = J;
		//ELSE _CONT ++;
		//SO CONTA A LINHA NA ALTURA DA LINHA DO ANDAR OU ABAIXO
		if(floor(y + CEL * j) >= floor(_minha_linha.y))
		{
			if(floor(y + CEL * j) == floor(_minha_linha.y)) _line = true;
			array_push(_linhas, j);
		}else _line = true;
	}
}
//DESTROI AS LINHAS COMPLETAS (O EFEITO SO E CRIADO NA PRIMEIRA)
if(array_length(_linhas) > 0) 
{
	var criei_line = true;
	for(var i = array_length(_linhas)-1; i >= 0; i--)
	{
		destroy_linha(_linhas[i], array_length(_linhas), criei_line, _line)
		criei_line = false;
	}
}

///DEBUGS==============================
draw_rectangle(x, y + cel, x + sprite_width, (y + cel) - cel*3, 1);
//CRIANDO PECASS COM O MOUSE

//DEBUG: CLICAR NA ARENA CRIA UMA PEÇA
if(mouse_x > x and mouse_x < x + sprite_width and mouse_y > y and mouse_y < y + sprite_height)
{
	var _x = ((mouse_x div CEL) * CEL) + 8;
	var _y = ((mouse_y div CEL) * CEL) + 8;
	
	//DRAW_TEXT(_X - 8, _Y - 8, (MOUSE_X - X) DIV CEL)
	//DRAW_TEXT(_X - 8, _Y - 8, (MOUSE_Y - Y) DIV CEL)
	

	
	draw_sprite(spr_cria_peca, 1, _x, _y);
	if(mouse_check_button_pressed(mb_left))
	{
		var _criador = instance_create_layer(_x, _y, "Blocos", obj_cria_peca);
		//_CRIADOR.TIPO = "BLOCO_UNICO_DEBUG";
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


draw_text(15, 15, global.andar);
draw_text(15, 45, global.linhas_completadas);
draw_text(15, 215, global.andar_2);
draw_text(15, 245, global.linhas_completadas_2);
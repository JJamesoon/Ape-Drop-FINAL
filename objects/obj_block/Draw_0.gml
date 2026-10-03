//BLOCO TREME JUNTO COM A ARENA DELE (NO VERSUS, A DA DIREITA USA A TREMIDA DO PLAYER 2)
var shake_x, shake_y;
if(modo_arcade() or x < room_width/2)
{
	shake_x = global.shake_x;
	shake_y = global.shake_y + global.lerp_y;
}
else 
{
	shake_x = global.shake_x_2;
	shake_y = global.shake_y_2 + global.lerp_y_2;
}


//PROFUNDIDADE: A MESMA REGRA DAS PEÇAS (SCR_GRIDS): EM CIMA NA FRENTE; NA MESMA LINHA, A DIREITA NA FRENTE.
//A PAREDE (FILHA DESTE OBJETO) OCUPA A ARENA DE CIMA A BAIXO, ENTAO FICA COMO ERA: ATRAS DE TODAS AS PEÇAS
if(object_index == obj_parede)
{
	var _y = (y + CEL/2) - CEL*2;
	depth = (_y - x) * 0.1;
}
else depth = profundidade(x, y);

//BLOCO EM CIMA DE OUTRO DESENHA DUAS VEZES (DEIXA MAIS FORTE)
if(place_meeting(x, y + 1, obj_block))
{
	draw_sprite(sprite_index, image_index, x + shake_x, y + shake_y);
}
draw_sprite(sprite_index, image_index, x + shake_x, y + shake_y);

//DRAW_SELF()

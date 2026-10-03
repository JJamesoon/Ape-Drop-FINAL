//LINHA DOS ANDARES DO PLAYER 2 NO VERSUS (IGUAL A OBJ_LINHA, MAS USA AS GLOBAIS _2)
//FICA NA FRENTE DE TUDO
depth = -10000;

//ARENA ONDE A LINHA ESTA
minha_area = instance_place(x, y, [obj_area, obj_area_versus]);
todos_andares = [0, 2, 6, 10];	//ALTURA DE CADA ANDAR EM CELULAS (ANDAR 1 = 2 CELULAS, 2 = 6, 3 = 10)
meu_y = minha_area.y + sprite_get_height(spr_area) - CEL*todos_andares[global.andar_2];
linhas_atuais = noone;	//QUANTAS LINHAS FORAM FEITAS NESSE ANDAR (PRO EFEITO DE LIMPAR)

//SOBE O ANDAR (1 -> 2 -> 3 -> VOLTA PRO 1) E MOVE A LINHA PRA ALTURA DO ANDAR NOVO
elevar_nivel = function()
{
	switch(global.andar_2)
	{
		case 1:
			global.andar_2++;
			break;
		case 2:
			global.andar_2++;
			break;
		case 3:
			global.andar_2 = 1;
			break;
	}
	var _meu_prox_y = todos_andares[global.andar_2];
	meu_y = minha_area.y + sprite_get_height(spr_area) - CEL*_meu_prox_y;
	
	//DESTRUINDO TODOS O BLOCOS PRA REINICIAR O LEVEL
	if(alarm[0] == -1) alarm[0] = 5
	//RESETANDO AS LINHAS	
	linhas_atuais = global.linhas_completadas_2;
	global.linhas_completadas_2 = 0;
}

//RETANGULO DE DEBUG ANTIGO (NAO E MAIS USADO)
draw_rec = false;
rec_x	= noone;
rec_xx	= noone;
rec_y	= noone;
rec_yy	= noone;
//LIMPA A ARENA: CRIA O EFEITO QUE QUEBRA TODOS OS BLOCOS
destruir_blocos = function()
{
	minha_area = obj_area_versus;
	
	if(place_meeting(x, y, minha_area)) 
	{
		if(place_meeting(x -1, y, obj_parede))
		{
			var _efeito = instance_create_layer(minha_area.x, y+(16*linhas_atuais)/2, "Linha", obj_efeito_animacao);
			_efeito.sprite_index = spr_efeito_destroi_block;
			_efeito.depth = -1000;
			_efeito.image_yscale = linhas_atuais;
			_efeito.destruir_blocos = true;
		}
	}
	
}








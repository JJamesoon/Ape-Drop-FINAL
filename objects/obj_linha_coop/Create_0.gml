//LINHA DOS ANDARES DO COOP (IGUAL A OBJ_LINHA, NA ARENA LARGA DO COOP)
//FICA NA FRENTE DE TUDO
depth = -10000;
intensidade = 0; //INTENCIDADE DO RAIO
tam_raio = 1; 

//ARENA ONDE A LINHA ESTA
minha_area = instance_place(x, y, obj_area_coop);
todos_andares = [0, 2, 6, 10];	//ALTURA DE CADA ANDAR EM CELULAS
meu_y = minha_area.y + sprite_get_height(spr_area_coop) - CEL*todos_andares[global.andar];

linhas_atuais = noone;	//QUANTAS LINHAS FORAM FEITAS NESSE ANDAR (PRO EFEITO DE LIMPAR)

//SOBE O ANDAR (1 -> 2 -> 3 -> VOLTA PRO 1) E MOVE A LINHA PRA ALTURA DO ANDAR NOVO
elevar_nivel = function()
{
	modificar_raios(25, id);
	switch(global.andar)
	{
		case 1:
			global.andar++;
			break;
		case 2:
			global.andar++;
			break;
		case 3:
			global.andar = 1;
			break;
	}
	var _meu_prox_y = todos_andares[global.andar];
	meu_y = minha_area.y + sprite_get_height(spr_area) - CEL*_meu_prox_y;
	
	//DESTRUINDO TODOS O BLOCOS PRA REINICIAR O LEVEL
	if(alarm[0] == -1) alarm[0] = 5
	//RESETANDO AS LINHAS
	linhas_atuais = global.linhas_completadas;
	global.linhas_completadas = 0;
}

//RETANGULO DE DEBUG ANTIGO (NAO E MAIS USADO)
draw_rec = false;
rec_x	= noone;
rec_xx	= noone;
rec_y	= noone;
rec_yy	= noone;

//LIMPA A ARENA: CRIA O EFEITO QUE QUEBRA TODOS OS BLOCOS (MAIS LARGO NO COOP)
destruir_blocos = function()
{
	minha_area = instance_place(x, y, obj_area_coop);
	
	if(place_meeting(x, y, minha_area)) 
	{
		if(place_meeting(x -1, y, obj_parede))
		{
			var _efeito = instance_create_layer(minha_area.x, y+(16*linhas_atuais)/2, "Linha", obj_efeito_animacao);
			_efeito.sprite_index = spr_efeito_destroi_block;
			_efeito.depth = -1000;
			_efeito.image_yscale = linhas_atuais;
			_efeito.image_xscale = 1.6;
			_efeito.destruir_blocos = true;
		}
	}
	
}








//ONDA DE LASER: DE 1 A 3 LASERS VERTICAIS, UM DEPOIS DO OUTRO. CADA UM MIRA ONDE O PLAYER ESTA NA HORA (A COLUNA DELE),
//MOSTRA O AVISO POR LASER_AVISO E DEPOIS DISPARA DO TOPO AO CHAO DA ARENA POR LASER_ATIVO: DA DANO NO PLAYER QUE
//ESTIVER NELE E QUEBRA TODOS OS BLOCOS DA COLUNA (E OS INIMIGOS). QUEM CRIA E O OBJ_GAME_CONTROL (LASER_ONDA_*)
qtd = irandom_range(LASER_ONDA_MIN, LASER_ONDA_MAX);	//QUANTOS LASERS NESSA ONDA
criados = 0;								//QUANTOS JA APARECERAM
espera = room_speed * .5;					//TEMPO ATE O PROXIMO (O PRIMEIRO ESPERA O AVISO "LASER!")
lasers = [];								//LASERS NA TELA: { X, T } (T = FRAMES DESDE QUE APARECEU)

//AVISO NO TOPO DA ARENA
if(instance_exists(obj_area))
{
	efeito_texto("LASER!", obj_area.x + obj_area.sprite_width / 2, obj_area.y + 40, c_red, 1.4);
	som_tocar(snd_menu_erro_03);
}

//DISPARO: QUEBRA OS BLOCOS DA COLUNA E MATA OS INIMIGOS (CHAMADO TODO FRAME ENQUANTO O LASER TA LIGADO,
//PRA PEGAR TAMBEM O QUE CAIR DENTRO DELE)
laser_queimar = function(_lx)
{
	with(obj_peca) if(destruido_por == noone and abs(x - _lx) < CEL / 2)
	{
		destruido_por = "laser";
		instance_destroy();
	}
	with(obj_inimigo) if(vivo() and abs(x - _lx) < CEL / 2 + 2)
	{
		if(bomba) explodir();
		else morrer_nocaute(choose(-1, 1), false);
	}
	//PLAYER DENTRO DO LASER: DANO (O LEVAR_DANO JA DEIXA ELE IMUNE UM TEMPO, ENTAO E UM DANO SO)
	with(obj_player) if(estado != state.morte and bbox_right > _lx - LASER_LARGURA / 2 and bbox_left < _lx + LASER_LARGURA / 2)
	{
		levar_dano(x < _lx ? -1 : 1);
	}
}

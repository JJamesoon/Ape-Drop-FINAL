//BLOCO SENSOR SE LANÇANDO PRA FRENTE (CRIADO PELO OBJ_PECA QUANDO O PLAYER PASSA NA LINHA DELE)
//VOA NA HORIZONTAL QUEBRANDO TODOS OS BLOCOS DO CAMINHO. NO PLAYER, MATA (O ESCUDO SEGURA, MAS QUEBRA).
//NO INIMIGO, MATA ELE. SO SE DESTROI NA PAREDE (OU NO CHAO SOLIDO)
sprite_index = spr_peca;
mask_index = spr_peca;
image_speed = 0;
dir = 1;	//1 = DIREITA, -1 = ESQUERDA
vel = 1;	//VELOCIDADE (ACELERA NO STEP)
frame = 0; //COR DO BLOCO (FRAME DA SPR_PECA)

//BATEU: EXPLODE EM MINI-BLOCOS E SOME
sensor_explodir = function()
{
	efeito_morte_irmandade(x, y, frame);
	onda_choque(x, y, 55, 5, 22);
	som_tocar(snd_peca_destroy, .1);
	shakes(8, 2);
	instance_destroy();
}

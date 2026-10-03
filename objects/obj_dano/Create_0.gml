//AREA DE DANO DE UM GOLPE DO PLAYER (SOCO, GIRO...). DURA 3 FRAMES
alarm[0] = 3;
super = false;	//SUPER SOCO (QUEBRA MAIS)
soco_fail = false;	//SOCO QUE NAO ACERTOU NADA
espiritual = false;

//EFEITO DO SOCO: NO NORMAL SO UM ANEL PEQUENO; NO SUPER SOCO ANEL MAIOR, ONDA DE CHOQUE E UM HITSTOP CURTO
soco_efeito = function(_x, _y)
{
	var _a = instance_create_depth(_x, _y, -1900, obj_efeito_pontos);
	_a.modo = "anel";
	_a.timer = super ? 10 : 7;
	_a.esc_anel = super ? .55 : .85;
	if(super)
	{
		onda_choque(_x, _y, 26, 3, 16);
		hitstop(3);
		shakes(6, 2);
	}
} //PODER DO SOCO ESPIRITUAL (SOCA FANTASMA, ACERTA INIMIGO ATRAS DO BLOCO, LIBERA LETRA E DESARMA O SENSOR)
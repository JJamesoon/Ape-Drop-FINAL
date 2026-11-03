//O EFEITO DA LINHA ACABOU. SE ELA VIROU CHAO, CONFERE SE O CHAO FICOU COMPLETO: O CHAO SO PODE SER DESTRUIDO AO SUBIR DE ANDAR,
//ENTAO NENHUMA CASA DESSA LINHA PODE FICAR SEM BLOCO (ANTES, UM BLOCO QUE NAO ESTAVA NA LINHA NA HORA, EX: INIMIGO OU BLOCO
//QUICANDO, DEIXAVA UM BURACO NO CHAO). NA LINHA DE COR UNICA O CHAO E APAGADO LOGO DEPOIS (SOBE DE ANDAR), ENTAO NAO COMPLETA
if(chao_y != noone and !subir_andar and instance_exists(minha_area))
{
	var _fx = zx == noone ? minha_area.x : zx;
	var _fc = zc == noone ? minha_area.cols : zc;
	for(var i = 0; i < _fc; i++)
	{
		var _bx = (_fx + CEL / 2) + CEL * i;
		var _by = chao_y + CEL / 2;
		if(!collision_point(_bx, _by, obj_block, false, true)) instance_create_layer(_bx, _by, "Blocos", obj_block);
	}
}

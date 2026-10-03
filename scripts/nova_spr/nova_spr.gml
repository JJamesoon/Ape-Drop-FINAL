// OS RECURSOS DE SCRIPT MUDARAM PARA A V2.3.0; VEJA
// HTTPS://HELP.YOYOGAMES.COM/HC/EN-US/ARTICLES/360005277377 PARA OBTER MAIS INFORMAÇÕES
//TROCA A SPRITE E VOLTA PRO FRAME 0. DEVOLVE TRUE SE JA ERA ESSA SPRITE (NAO MUDOU NADA)
function nova_spr(_spr){
	//SE QUEM CHAMOU TEM SKIN (PLAYER), TROCA A SPRITE DO MACACO PELA DA SKIN
	if(variable_instance_exists(id, "skin")) _spr = skin_sprite(skin, _spr);
	
	if(sprite_index != _spr)
	{
		sprite_index = _spr;
		image_index = 0;
		return false;
	}else
	{
		return true;
	}
}
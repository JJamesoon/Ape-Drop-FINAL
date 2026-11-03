//GRADE DO COOP (RM_COOP): ARENA MAIS LARGA (16 COLUNAS). TODO O RESTO (GRADE, PEÇAS, LINHAS, ONDAS) VEM DO OBJ_AREA
sprite_index = spr_area_coop;
mask_index = spr_area_coop;
event_inherited();

//A ROOM NAO TEM PLAYER. O PLAYER 1 NASCE NO MEIO DO CHAO DA ARENA E ELE MESMO CRIA O PLAYER 2
if(!instance_exists(obj_player))
{
	global.coop = true;
	instance_create_layer(x + sprite_width / 2 - CEL * 2, y + sprite_height, "Blocos", obj_player);
}

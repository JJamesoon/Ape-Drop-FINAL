//EFEITO QUE LIMPA A ARENA: SEGURA O JOGO E NO FRAME 3 QUEBRA TODOS OS BLOCOS DENTRO DELA
if(destruir_blocos)
{
	pausar_seg(10);
	if(image_index >= 3)
	{
		with(obj_block) if(place_meeting(x, y, obj_area)) instance_destroy();
	}
}

// OS RECURSOS DE SCRIPT MUDARAM PARA A V2.3.0; VEJA
// HTTPS://HELP.YOYOGAMES.COM/HC/EN-US/ARTICLES/360005277377 PARA OBTER MAIS INFORMAÇÕES
//CHEGOU NO ULTIMO FRAME DA ANIMAÇAO? SE SIM, TRAVA NELE E DEVOLVE TRUE
function ultima_spr(){
	if(image_index > image_number-1)
	{
		image_index = image_number-1;
		return true;
	}else
	{
		return false;
	}
}
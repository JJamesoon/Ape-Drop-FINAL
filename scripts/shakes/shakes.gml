// OS RECURSOS DE SCRIPT MUDARAM PARA A V2.3.0; VEJA
// HTTPS://HELP.YOYOGAMES.COM/HC/EN-US/ARTICLES/360005277377 PARA OBTER MAIS INFORMAÇÕES
//TREME A TELA DA ARENA CERTA: _TIMER = DURAÇAO EM FRAMES, _SHAKE = FORÇA
function shakes(_timer = 10, _shake = 2)
{
	if(!global.shake) exit; //TREMOR DESLIGADO NAS CONFIGURAÇOES
	
	if(modo_arcade() or room = rm_versus and x < room_width/2)
	{
		obj_area.shake_intensity = _shake;   // FORÇA DO SHAKE
		//ARCADE OU LADO ESQUERDO DO VERSUS: ARENA PRINCIPAL
		obj_area.shake_duration	= _timer;   // DURAÇÃO EM FRAMES
	}
	else 
	{
		if(room == rm_versus)
		{
			obj_area_versus.shake_intensity = _shake;   // FORÇA DO SHAKE
			//LADO DIREITO DO VERSUS: ARENA DO PLAYER 2
			obj_area_versus.shake_duration	= _timer;   // DURAÇÃO EM FRAMES
		}else
		{
			obj_area_coop.shake_intensity = _shake;   // FORÇA DO SHAKE
			//COOP: ARENA DO COOP
			obj_area_coop.shake_duration	= _timer;   // DURAÇÃO EM FRAMES
		}
	}
}

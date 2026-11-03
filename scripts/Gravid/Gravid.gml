//GRAVIDADE: SE NAO TEM CHAO EMBAIXO, A VELOCIDADE VERTICAL AUMENTA (_MASSA = MAIS PESADO CAI MAIS RAPIDO)
function scr_gravid(_massa = 1)
{
	//O PLAYER PASSA POR DENTRO DO BLOCO FANTASMA (USA A COLISAO DELE)
	var _block = variable_instance_exists(id, "solido") ? solido(x, y + 1) : place_meeting(x, y + 1, [obj_block, obj_peca]);
	
	var _vel_m = 6;
	
	//VELOCIDADE MAXIMA DE QUEDA
	if(!_block) 
	{
		//FEITIÇO DO BLOCO LENTO (SO O PLAYER TEM O LENTO): A GRAVIDADE FICA MAIS FRACA JUNTO COM O MOVIMENTO
		var _lento = variable_instance_exists(id, "lento") and lento > 0;
		var _rapido = variable_instance_exists(id, "rapido") and rapido > 0;
		velv += GRAVID * _massa * (_lento ? LENTO_MULT : (_rapido ? RAPIDO_MULT : 1));
		velv = clamp(velv, -_vel_m, _vel_m-1);
	}
}
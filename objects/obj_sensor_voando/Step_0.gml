//PAUSADO: FICA PARADO
if(global.game_pause) exit;

//ACELERA ATE 7 PIXELS POR FRAME
vel = min(vel + .5, 7);

//ANDA DE PIXEL EM PIXEL PRA NAO ATRAVESSAR NADA
repeat(ceil(vel))
{
	x += dir;
	
	//ACERTOU O PLAYER: O ESCUDO SEGURA (E QUEBRA). SEM ESCUDO, MORRE
	//PLAYER
	var _p = instance_place(x, y, obj_player);
	if(_p != noone and _p.estado != state.morte)
	{
		with(_p)
		{
			if(tem_poder("escudo") and !escudo_quebrado)
			{
				escudo_vida = 0;
				escudo_quebrado = true;
				alpha_fog = 1;
				shakes(10, 3);
				som_tocar(snd_hit);
			}
			else
			{
				levar_dano(other.dir, 100); //EMPURRAO E HITSTOP (NO MODO IMORTAL SO ISSO)
				morrer();
			}
		}
		sensor_explodir();
		exit;
	}
	
	//INIMIGO
	var _ini = instance_place(x, y, obj_inimigo);
	if(_ini != noone and _ini.vivo()) _ini.morrer_nocaute(dir, false);
	
	//BLOCO OU PEÇA (ATE O FANTASMA): QUEBRA TODOS QUE ENCOSTAR E CONTINUA VOANDO
	with(obj_peca) if(destruido_por == noone and place_meeting(x, y, other.id))
	{
		destruido_por = "sensor";
		instance_destroy();
		shakes(4, 1);
	}
	
	//PAREDE
	if(place_meeting(x, y, obj_block))
	{
		sensor_explodir();
		exit;
	}
}

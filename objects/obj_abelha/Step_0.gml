//PAUSADO: A ABELHA FICA PARADA
if(global.game_pause) exit;
timer++;
asa += .5;

//O ALVO SUMIU (QUEBROU, VOLTOU A CAIR...): PROCURA OUTRO
if(!instance_exists(alvo) or alvo.destruido_por != noone or !alvo.estou_parado) alvo = procurar_alvo();

if(alvo == noone)
{
	//SEM BLOCO NENHUM NA ARENA: FICA VOANDO EM VOLTA E DEPOIS DE UM TEMPO SOME
	sem_alvo++;
	vel_x = lerp(vel_x, sin(timer / 20) * .6, .05);
	vel_y = lerp(vel_y, cos(timer / 27) * .4, .05);
	if(sem_alvo > room_speed * 6)
	{
		efeito_morte_linha(x, y, cores.c_yellow);
		instance_destroy();
		exit;
	}
}
else
{
	//VOA ATE O BLOCO (VIRA AOS POUCOS, COMO UM INSETO)
	sem_alvo = 0;
	var _dir = point_direction(x, y, alvo.x, alvo.y);
	vel_x = lerp(vel_x, lengthdir_x(ABELHA_VEL, _dir), .08);
	vel_y = lerp(vel_y, lengthdir_y(ABELHA_VEL, _dir), .08);

	//CHEGOU: SE DESTROI E LEVA O BLOCO JUNTO (O BLOCO NAO DA PONTOS)
	if(point_distance(x, y, alvo.x, alvo.y) < 5)
	{
		with(alvo)
		{
			destruido_por = "abelha";
			instance_destroy();
		}
		efeito_morte_linha(x, y, cores.c_yellow);
		audio_play_sound(snd_peca_destroy, 1, false, .6, 0, 1.3);
		shakes(2, 1);
		instance_destroy();
		exit;
	}
}

//ANDA COM UM BALANÇO DE INSETO
x += vel_x;
y += vel_y + sin(timer / 4) * .35;
if(abs(vel_x) > .05) lado = sign(vel_x);

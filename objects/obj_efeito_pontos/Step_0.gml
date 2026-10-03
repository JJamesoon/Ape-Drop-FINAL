//O POP: CRESCE ATE O TAMANHO FINAL (MENOS NOS EFEITOS QUE TEM ESCALA PROPRIA)
if(modo != "anel" and modo != "estilhaco" and modo != "poeira" and modo != "tele") esc = lerp(esc, esc_final, .25);

switch(modo)
{
	#region MORTE DA IRMANDADE: ANEL QUE CRESCE
	case "anel":
		timer--;
		esc = 1 + (14 - timer) * .12;
		alpha = timer / 14;
		if(timer <= 0) instance_destroy();
		break;
	#endregion
	
	#region TELEPORTE: SO CONTA O TEMPO (O DESENHO FAZ TUDO)
	case "tele":
		if(atraso > 0) { atraso--; break; }
		timer_voo++;
		if(timer_voo >= TELE_DUR) instance_destroy();
		break;
	#endregion

	#region POEIRA (PULO E ATERRISSAGEM): SAI DE LADO E VAI SUMINDO
	case "poeira":
		x += lengthdir_x(vel_voo, dir_voo);
		y += velv;
		vel_voo *= .9;
		esc *= .94;
		timer--;
		alpha = min(1, timer / 10) * .8;
		if(timer <= 0) instance_destroy();
		break;
	#endregion
	
	#region MORTE DA IRMANDADE: MINI-BLOCO GIRANDO
	case "estilhaco":
		x += lengthdir_x(vel_voo, dir_voo);
		vel_voo *= .93;
		velv += .18;
		y += velv;
		ang += giro;
		timer--;
		if(timer < 10) alpha = timer / 10;
		if(timer <= 0) instance_destroy();
		break;
	#endregion
	
	#region BLOCO DA IRMANDADE: "10" NO LUGAR DO BLOCO E DEPOIS VOA PRO NUMERO DO CENTRO
	case "coletar":
		//O NUMERO DO CENTRO SUMIU (EX: OUTRA LINHA FECHOU): VAI DIRETO PRO SCORE
		if(!instance_exists(alvo) or alvo.modo != "coletor")
		{
			modo = "voar";
			exit;
		}
		timer_voo++;

		//FICA NO LUGAR DO BLOCO UM POUCO E DEPOIS SAI VOANDO
		if(timer_voo >= 24 + atraso)
		{
			var _dir = point_direction(x, y, alvo.x, alvo.y);
			dir_voo += angle_difference(_dir, dir_voo) * .2;
			vel_voo = min(vel_voo + .5, 10);
			x += lengthdir_x(vel_voo, dir_voo);
			y += lengthdir_y(vel_voo, dir_voo);

			//CHEGOU NO NUMERO DO CENTRO
			if(point_distance(x, y, alvo.x, alvo.y) < max(8, vel_voo) or timer_voo > room_speed * 3)
			{
				var _v = valor;
				with(alvo)
				{
					real_pendente = max(0, real_pendente - _v);
					esperando = max(0, esperando - 1);
					esc_pop = 1.3;
					timer_espera = 0;
				}
				audio_play_sound(snd_menu_select_02, 1, false, .6, 0, 1.2 + random(.2));
				instance_destroy();
			}
		}
		break;
	#endregion

	#region NUMERO DA LINHA NO CENTRO DA TELA
	case "coletor":
		esc_pop = lerp(esc_pop, 1, .2);

		//CONTA ATE O QUE JA CHEGOU (A LINHA ENTRA NA HORA, OS 10 DA IRMANDADE QUANDO CHEGAM)
		var _chegou = total_real - real_pendente;
		total_mostrado = lerp(total_mostrado, _chegou, .35);
		if(abs(total_mostrado - _chegou) < 1) total_mostrado = _chegou;
		mensagem = "+" + string(round(total_mostrado));

		switch(fase)
		{
			//ESPERANDO OS 10 DA IRMANDADE CHEGAREM (OU 5S NO MAXIMO). DEPOIS DE 0.4S SEM NADA CHEGAR, SEGURA
			case "recebendo":
				timer_vida++;
				if(timer_vida > room_speed * 5) esperando = 0;
				if(esperando <= 0) timer_espera++;
				if(timer_espera > room_speed * .4)
				{
					if(global.coletor == id) global.coletor = noone;
					fase = "segurando";
					timer_espera = 0;
				}
				break;

			//SEGURA O TOTAL UM POUCO E MANDA PRO SCORE
			case "segurando":
				timer_espera++;
				if(timer_espera > room_speed * .35)
				{
					modo = "voar";
					valor = total_real;
					mensagem = "+" + string(total_real);
					cor = c_yellow;
					timer_voo = 18; //JA SAI VOANDO
					vel_voo = 1;
					dir_voo = 90;
					esc = 1.8;
					esc_final = 1.2;
				}
				break;
		}
		break;
	#endregion

	#region PONTO VOANDO ATE O SCORE
	case "voar":
		if(!instance_exists(obj_borda))
		{
			modo = "texto";
			exit;
		}
		timer_voo++;
		//DESTINO: O SCORE DO PAINEL DA BORDA
		var _alvo_x = obj_borda.x + obj_borda.dx_hud + 217;
		var _alvo_y = obj_borda.y + 106;

		//NOS PRIMEIROS FRAMES SO SOBE UM POUCO
		if(timer_voo < 18)
		{
			y -= .6;
		}
		else
		{
			//DEPOIS CURVA ATE O SCORE, CADA VEZ MAIS RAPIDO E MENOR
			var _dir = point_direction(x, y, _alvo_x, _alvo_y);
			dir_voo += angle_difference(_dir, dir_voo) * .18;
			vel_voo = min(vel_voo + .45, 9);
			x += lengthdir_x(vel_voo, dir_voo);
			y += lengthdir_y(vel_voo, dir_voo);
			esc_final = max(.6, esc_final - .01);

			//CHEGOU NO PLACAR
			if(point_distance(x, y, _alvo_x, _alvo_y) < max(8, vel_voo) or timer_voo > room_speed * 3)
			{
				global.pontos_pendentes = max(0, global.pontos_pendentes - valor);
				with(obj_borda) score_esc = 1.35 + min(other.valor / 4000, .5); //TOTAL GRANDE = PULO MAIOR
				som_tocar(snd_menu_select_02, .1);
				instance_destroy();
			}
		}
		break;
	#endregion

	#region TEXTO QUE SOBE E SOME
	default:
		//SOBE FREANDO E SOME NO FIM
		y += velv;
		velv = lerp(velv, 0, .06);

		timer--;
		if(timer < 15) alpha -= .07;
		if(alpha <= 0) instance_destroy();
		break;
	#endregion
}

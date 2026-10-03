//PAUSADO: FICA PARADO
if(global.game_pause) exit;

//O BRILHO E O SQUASH/STRETCH VOLTAM AO NORMAL (MENOS NO AMASSADO, QUE FICA ACHATADO)
if(estado != "aviso") alpha_fog = max(0, alpha_fog - .08);
if(estado != "amassado")
{
	esc_x = lerp(esc_x, 1, .2);
	esc_y = lerp(esc_y, 1, .2);
}
cab_bump = lerp(cab_bump, 0, .25); //CABEÇADA DO CABEÇUDO VOLTANDO

//BOMBA: O PAVIO QUEIMA DEPOIS QUE ELA PISA NO CHAO. NO FIM, PULSA COM TIC-TAC CADA VEZ MAIS RAPIDO E EXPLODE
if(bomba and vivo() and estado != "aviso" and estado != "caindo")
{
	bomba_timer--;
	if(bomba_timer < BOMBA_AVISO)
	{
		bomba_tic--;
		if(bomba_tic <= 0)
		{
			audio_play_sound(snd_tic, 1, false, .7, 0, 1 + .8 * (1 - bomba_timer / BOMBA_AVISO));
			bomba_tic = bomba_timer < room_speed ? 6 : 14;
		}
	}
	if(bomba_timer <= 0)
	{
		explodir();
		exit;
	}
}

//MAQUINA DE ESTADOS DO INIMIGO
switch(estado)
{
	#region AVISO: TREME NO LUGAR ONDE NASCEU ANTES DE CAIR
	case "aviso":
		timer++;
		shake_x = (timer div 2) mod 2 ? 1 : -1;
		alpha_fog = (timer div 4) mod 2 ? .7 : 0;
		if(timer >= INIMIGO_AVISO)
		{
			estado = "caindo";
			shake_x = 0;
			alpha_fog = 0;
		}
		break;
	#endregion

	#region CAINDO DIRETO
	case "caindo":
		velv = min(velv + INIMIGO_GRAV, INIMIGO_QUEDA_MAX);
		if(mover_y(velv)) pousar();
		break;
	#endregion

	#region BROTANDO: AS PERNINHAS CRESCEM E O CORPO SOBE
	case "brotando":
		timer++;
		pernas = min(INIMIGO_PERNAS, floor(timer / INIMIGO_BROTAR * (INIMIGO_PERNAS + 1)));
		gravidade();
		if(timer >= INIMIGO_BROTAR + 8) estado = "andando";
		break;
	#endregion

	#region ANDANDO DE UM LADO PRO OUTRO
	case "andando":
		gravidade();

		//PRESO ENTRE 2 BLOCOS: NAO TEM PRA ONDE ANDAR (FICAVA VIRANDO DE UM LADO PRO OUTRO). O CABEÇUDO NUNCA FICA PRESO:
		//ELE EMPURRA/QUEBRA O BLOCO DA FRENTE
		if(!cabecudo and velv == 0 and preso())
		{
			estado = "preso";
			timer = 0;
			break;
		}

		//BATEU EM ALGO (BLOCO, PEÇA, PAREDE OU OUTRO INIMIGO): DA MEIA-VOLTA. O CABEÇUDO DA CABEÇADA (CABECUDO_ANDAR)
		if(cabecudo) cabecudo_andar();
		else if(mover_x(dir * INIMIGO_VEL)) dir *= -1;
		if(velv == 0) passo += .15;

		//AGACHA QUANDO TEM ALGO LOGO EM CIMA (O CORPO NAO ENTRA NO BLOCO DE CIMA)
		var _alvo = solido(x, y - INIMIGO_PERNAS) ? 0 : INIMIGO_PERNAS;
		if(pernas < _alvo) pernas++;
		else if(pernas > _alvo) pernas--;
		break;
	#endregion

	#region PRESO: FICA PARADO, RECOLHE AS PERNAS E VIRA UM BLOCO NORMAL (SE ABRIR UM LADO, VOLTA A ANDAR)
	case "preso":
		gravidade();
		if(!preso())
		{
			estado = "andando";
			shake_x = 0;
			break;
		}
		timer++;
		if(timer mod 5 == 0 and pernas > 0) pernas--;
		if(timer > INIMIGO_PRESO - 12) shake_x = (timer div 2) mod 2 ? 1 : -1;
		if(timer >= INIMIGO_PRESO and !bomba) //A BOMBA NAO VIRA BLOCO: FICA PRESA ATE O PAVIO ACABAR
		{
			virar_bloco();
			exit; //O BLOCO NOVO TA NO LUGAR DELE: NAO PODE CAIR NO "ESMAGADO" LA EMBAIXO
		}
		break;
	#endregion

	#region MORTES
	case "amassado":
		//AMASSADO: FICA NO CHAO UM POUCO E VAI SUMINDO
		timer++;
		if(timer > 24) alpha -= .1;
		if(alpha <= 0) instance_destroy();
		break;

	case "nocaute":
		//NOCAUTE: CAI COM GRAVIDADE ATE SAIR DA TELA
		velv += GRAVID;
		x += velh;
		y += velv;
		if(y > room_height + 48) instance_destroy();
		break;
	#endregion
}

//ESMAGADO: UMA PEÇA OU BLOCO ENTROU NO LUGAR DELE (CAIU EM CIMA, FOI TELEPORTADA OU EMPURRADA PELO SOCO)
if(vivo() and (place_meeting(x, y, obj_peca) or place_meeting(x, y, obj_block)))
{
	if(bomba) { explodir(); exit; } //A BOMBA ESMAGADA EXPLODE NA HORA
	morrer_nocaute(choose(-1, 1), false);
}

//VIVO: VE SE ENCOSTOU NO PLAYER
if(vivo()) checar_player();
